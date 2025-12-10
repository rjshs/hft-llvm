#include <cstdint>
#include <atomic>

struct [[clang::annotate("hft_struct")]] OrderBookLevel {
    // hot
    double price;
    int32_t size;
    int32_t order_count;

    // cold
    uint64_t last_update_ts_ns;
    uint32_t venue_id;
    uint32_t padding;
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
}

struct Message {
    MsgType type;
    bool is_bid;
    int32_t level;
    int32_t delta_size;
    double price;
}

struct Engine {
    Oderbook ob;

    Engine() {
        ob.seq_no.store(0, std::memory_order_relaxed);
    }
}