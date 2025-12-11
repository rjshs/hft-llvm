#include <cstdint>
#include <atomic>
#include <vector>
#include <random>
#include <cmath>
#include <chrono>
#include <iostream>

struct [[clang::annotate("hft_struct")]] OrderBookLevel {
    // hot
    double price; // price for current level
    int32_t size; // total quantity resting at current price
    int32_t order_count; // how many individual orders makeup size

    // cold
    uint64_t last_update_ts_ns; // when current level was last touched (ns)
    uint32_t venue_id; // id of venue or exchange this level comes from
    uint32_t padding; // alignment/padding to get a nice memory layout
};

struct OrderBook {
    static constexpr int MAX_LEVELS = 64;
    OrderBookLevel bids[MAX_LEVELS];
    OrderBookLevel asks[MAX_LEVELS];

    std::atomic<uint64_t> seq_no;
};

enum class MsgType:uint8_t {
    Add,
    Cancel,
    Modify
};

struct Message {
    MsgType type;
    bool is_bid;
    int32_t level;
    int32_t delta_size;
    double price;
};

struct Engine {
    OrderBook ob;

    Engine() {
        ob.seq_no.store(0, std::memory_order_relaxed);

        for (int i = 0; i < OrderBook::MAX_LEVELS; i++) {
            ob.bids[i].price = 100.0 - i * 0.01;
            ob.asks[i].price = 100.0 + i * 0.01;
            ob.bids[i].size = 0;
            ob.asks[i].size = 0;
            ob.bids[i].order_count = 0;
            ob.asks[i].order_count = 0;
        }
    }

    inline void on_message(const Message &m) {
        OrderBookLevel *side = m.is_bid ? ob.bids : ob.asks;
        auto &lvl = side[m.level];

        switch (m.type) {
        case MsgType::Add:
            lvl.price = m.price;
            lvl.size += m.delta_size;
            ++lvl.order_count;
            break;
        case MsgType::Cancel:
            lvl.size -= m.delta_size;
            if (lvl.size < 0) lvl.size = 0;
            if (lvl.order_count > 0) --lvl.order_count;
            break;
        case MsgType::Modify:
            lvl.size += m.delta_size;
            lvl.price = m.price;
            break;
        }

        // "Concurrency-friendly" but single-threaded in practice
        ob.seq_no.fetch_add(1, std::memory_order_relaxed);
        lvl.last_update_ts_ns += 1;
    }
};

int main() {
    constexpr int N_MESSAGES = 5'000'000; // big enough to stress hot loop
    Engine engine;

    std::vector<Message> msgs;
    msgs.reserve(N_MESSAGES);

    std::mt19937_64 rng(12345);
    std::uniform_int_distribution<int> level_dist(0, OrderBook::MAX_LEVELS - 1);
    std::uniform_int_distribution<int> size_dist(1, 100);
    std::uniform_real_distribution<double> price_dist(99.5, 100.5);
    std::uniform_int_distribution<int> type_dist(0, 2);
    std::bernoulli_distribution side_dist(0.5);

    for (int i = 0; i < N_MESSAGES; ++i) {
        Message m;
        m.type = static_cast<MsgType>(type_dist(rng));
        m.is_bid = side_dist(rng);
        m.level = level_dist(rng);
        m.delta_size = size_dist(rng);
        m.price = price_dist(rng);
        msgs.push_back(m);
    }

    auto start = std::chrono::high_resolution_clock::now();
    for (const auto &m : msgs) {
        engine.on_message(m);
    }
    auto end = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double> elapsed = end - start;
    double msgs_per_sec = N_MESSAGES / elapsed.count();
    std::cout << "Processed " << N_MESSAGES << " messages in "
              << elapsed.count() << " s (" << msgs_per_sec << " msg/s)\n";

    // Prevent optimizer from throwing everything away
    std::cout << "Final seq_no = " << engine.ob.seq_no.load() << "\n";
    return 0;
}