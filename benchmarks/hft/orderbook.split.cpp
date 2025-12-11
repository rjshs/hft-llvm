#include <cstdint>
#include <atomic>
#include <vector>
#include <random>
#include <cmath>
#include <stddef.h>
#include <chrono>
#include <iostream>

static constexpr int MAX_LEVELS = 4096;

// Same message & enums as before
enum class MsgType : uint8_t {
    Add,
    Cancel,
    Modify
};

struct Message {
    MsgType type;
    bool    is_bid;
    int32_t level;
    int32_t delta_size;
    double  price;
};

// ------------------------------------------------------------
// HOT / COLD SPLIT
// ------------------------------------------------------------

// Hot subset: only fields used in the critical path
struct [[clang::annotate("hft_struct_hot")]] HotLevel {
    double  price;        // price for current level
    int32_t size;         // total quantity resting at current price
    int32_t order_count;  // how many individual orders makeup size
};

// Cold subset: analytics / metadata used rarely
struct [[clang::annotate("hft_struct_cold")]] ColdLevel {
    uint64_t last_update_ts_ns; // when current level was last touched (ns)
    uint32_t venue_id;          // id of venue or exchange this level comes from
    uint32_t padding;           // alignment/padding

    double   ewma_spread;       // some analytics
    double   ewma_depth;        // analytics
    double   variance_estimate;
    double   volatility_bucket;

    uint64_t slow_stats[8];     // fake heavy stats
};

// Global book storage: SoA by hot/cold
HotLevel  bids_hot[MAX_LEVELS];
ColdLevel bids_cold[MAX_LEVELS];

HotLevel  asks_hot[MAX_LEVELS];
ColdLevel asks_cold[MAX_LEVELS];

// Sequence number (still atomic to mirror your original)
std::atomic<uint64_t> seq_no;

// ------------------------------------------------------------
// Engine using split layout
// ------------------------------------------------------------
struct Engine {
    Engine() {
        seq_no.store(0, std::memory_order_relaxed);

        for (int i = 0; i < MAX_LEVELS; i++) {
            // Initialize hot levels
            bids_hot[i].price       = 100.0 - i * 0.01;
            asks_hot[i].price       = 100.0 + i * 0.01;

            bids_hot[i].size        = 0;
            asks_hot[i].size        = 0;

            bids_hot[i].order_count = 0;
            asks_hot[i].order_count = 0;

            // Initialize cold levels
            bids_cold[i].last_update_ts_ns = 0;
            asks_cold[i].last_update_ts_ns = 0;

            bids_cold[i].venue_id = 1;
            asks_cold[i].venue_id = 2;

            bids_cold[i].padding  = 0;
            asks_cold[i].padding  = 0;

            bids_cold[i].ewma_spread       = 0.0;
            asks_cold[i].ewma_spread       = 0.0;

            bids_cold[i].ewma_depth        = 0.0;
            asks_cold[i].ewma_depth        = 0.0;

            bids_cold[i].variance_estimate = 0.0;
            asks_cold[i].variance_estimate = 0.0;

            bids_cold[i].volatility_bucket = 0.0;
            asks_cold[i].volatility_bucket = 0.0;

            for (int j = 0; j < 8; j++) {
                bids_cold[i].slow_stats[j] = 0;
                asks_cold[i].slow_stats[j] = 0;
            }
        }
    }

    inline void on_message(const Message &m) {
        // HOT PATH: only touches HotLevel arrays + seq_no
        HotLevel *side_hot = m.is_bid ? bids_hot : asks_hot;
        auto &lvl = side_hot[m.level];

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
        seq_no.fetch_add(1, std::memory_order_relaxed);

        // NOTE: No cold fields touched here
    }

    inline void refresh_cold_fields(int level, bool is_bid) {
        // SLOW PATH: only touches ColdLevel arrays
        ColdLevel *side_cold = is_bid ? bids_cold : asks_cold;
        auto &lvl = side_cold[level];

        lvl.last_update_ts_ns += 1;
        lvl.ewma_spread           += 0.0001;
        lvl.ewma_depth            += 0.0002;
        lvl.variance_estimate     += 0.00005;
        lvl.volatility_bucket     += 0.00001;
        lvl.slow_stats[level % 8] += 1;
    }
};

// ------------------------------------------------------------
// Main — same traffic pattern as your original benchmark
// ------------------------------------------------------------
int main() {
    constexpr int N_MESSAGES = 5'000'000; // big enough to stress hot loop
    Engine engine;

    std::vector<Message> msgs;
    msgs.reserve(N_MESSAGES);

    std::mt19937_64 rng(12345);
    std::uniform_int_distribution<int> level_dist(0, MAX_LEVELS - 1);
    std::uniform_int_distribution<int> size_dist(1, 100);
    std::uniform_real_distribution<double> price_dist(99.5, 100.5);
    std::uniform_int_distribution<int> type_dist(0, 2);
    std::bernoulli_distribution side_dist(0.5);

    for (int i = 0; i < N_MESSAGES; ++i) {
        Message m;
        m.type       = static_cast<MsgType>(type_dist(rng));
        m.is_bid     = side_dist(rng);
        m.level      = level_dist(rng);
        m.delta_size = size_dist(rng);
        m.price      = price_dist(rng);
        msgs.push_back(m);
    }

    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < N_MESSAGES; i++) {
        const auto &m = msgs[i];
        engine.on_message(m);

        // Rare cold analytics: same pattern as baseline
        if ((i & 0x3FFF) == 0) {
            engine.refresh_cold_fields(m.level, m.is_bid);
        }
    }
    auto end = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double> elapsed = end - start;
    double msgs_per_sec = N_MESSAGES / elapsed.count();
    std::cout << "Processed " << N_MESSAGES << " messages in "
              << elapsed.count() << " s (" << msgs_per_sec << " msg/s)\n";

    std::cout << "Final seq_no = " << seq_no.load() << "\n";
    return 0;
}
