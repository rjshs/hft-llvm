// This function contains atomic operations that are:
// - NECESSARY in environments where stats are read from other threads
//   (e.g., backtesting / monitoring / simulations)
// - UNNECESSARY in production when we run a pinned, single-threaded engine

// This function contains atomic operations that are:
// - NECESSARY in environments where stats are read from other threads
//   (e.g., backtesting / monitoring / simulations)
// - UNNECESSARY in production when we run a pinned, single-threaded engine

#include <cstdint>
#include <atomic>
#include <array>
#include <array>
#include <vector>
#include <algorithm>
#include <algorithm>
#include <random>
#include <chrono>
#include <iostream>
#include <cstring>
#include <cassert>

//=============================================================================
// CONFIGURATION
//=============================================================================

namespace config {
    // Book depth - typical for equity/futures markets
    constexpr int MAX_PRICE_LEVELS = 256;
    
    // Maximum orders per price level (for pre-allocation)
    constexpr int MAX_ORDERS_PER_LEVEL = 64;
    
    // Benchmark parameters
    constexpr int NUM_MESSAGES = 10'000'000;
    constexpr int NUM_SYMBOLS = 1;  // Single symbol for simplicity
    
    // Price tick size (e.g., $0.01 for equities)
    constexpr double TICK_SIZE = 0.01;
    
    // Reference price for the book
    constexpr double REFERENCE_PRICE = 100.00;
}

//=============================================================================
// Analytics
//=============================================================================
struct [[clang::annotate("hft_struct")]] LevelAnalytics {
    // ---------------- HOT FIELDS (hit every message) -----------------
    double mid_imbalance;      // imbalance around best prices
    double queue_pressure;     // bid/ask queue pressure indicator
    double micro_volatility;   // very fast volatility estimate

    // ---------------- SEMI-HOT FIELDS (updated occasionally) --------
    double short_term_alpha;   // derived from recent imbalance
    double last_price_move;    // tick movement sign / size
    uint64_t last_update_ts_ns;

    // ---------------- COLD FIELDS (ML feature matrices, slow stats) --
    double ewma_depth;         // slow-moving depth estimate
    double ewma_spread;        // slow-moving spread estimate
    double variance_estimate;  // slow volatility estimate
    double kurtosis_estimate;  // tail-risk measure

    // Very cold: huge rolling feature buffer for ML inference
    double feature_buffer[2048];    // NEVER touched in hot loop

    // Extremely cold: placeholder for long-term stats
    uint64_t long_horizon_stats[2048];
};

LevelAnalytics bidAnalytics[config::MAX_PRICE_LEVELS];
LevelAnalytics askAnalytics[config::MAX_PRICE_LEVELS];

//=============================================================================
// TYPE DEFINITIONS
//=============================================================================

using Price = int64_t;      // Price in ticks (fixed-point, avoids FP issues)
using Quantity = int32_t;   // Order quantity
using OrderId = uint64_t;   // Unique order identifier
using Timestamp = uint64_t; // Nanoseconds since epoch

// Convert double price to tick representation
inline Price priceToTicks(double price) {
    return static_cast<Price>(price / config::TICK_SIZE + 0.5);
}

// Convert ticks back to double (for display only)
inline double ticksToPrice(Price ticks) {
    return ticks * config::TICK_SIZE;
}

//=============================================================================
// MARKET DATA MESSAGE TYPES
// These mirror real exchange feed formats (e.g., ITCH, PITCH, OPRA)
//=============================================================================

enum class MessageType : uint8_t {
    ADD = 'A',      // New order added to book
    CANCEL = 'X',   // Order canceled
    MODIFY = 'M',   // Order modified (price/size change)
    EXECUTE = 'E',  // Order executed (trade occurred)
    CLEAR = 'C'     // Clear book (trading halt, etc.)
};

enum class Side : uint8_t {
    BID = 'B',
    ASK = 'S'
};

// Packed message structure - mirrors network protocol format
struct __attribute__((packed)) MarketDataMessage {
    MessageType type;
    Side side;
    uint16_t _padding;
    OrderId order_id;
    Price price;          // In ticks
    Quantity quantity;
    Timestamp exchange_ts; // Exchange timestamp
    Timestamp local_ts;    // Local receive timestamp
};

static_assert(sizeof(MarketDataMessage) == 40, "Message size mismatch");

//=============================================================================
// ORDER REPRESENTATION
//=============================================================================

struct Order {
    OrderId id;
    Quantity quantity;
    Timestamp timestamp;  // For time priority
    
    Order() : id(0), quantity(0), timestamp(0) {}
    Order(OrderId id_, Quantity qty, Timestamp ts) 
        : id(id_), quantity(qty), timestamp(ts) {}
};

//=============================================================================
// PRICE LEVEL
// Represents all orders at a single price point with FIFO queue
//=============================================================================

struct PriceLevel {
    Price price;
    Quantity total_quantity;  // Sum of all order quantities
    int order_count;
    std::array<Order, config::MAX_ORDERS_PER_LEVEL> orders;
    
    PriceLevel() : price(0), total_quantity(0), order_count(0) {}
    
    void clear() {
        price = 0;
        total_quantity = 0;
        order_count = 0;
    }
    
    bool addOrder(OrderId id, Quantity qty, Timestamp ts) {
        if (order_count >= config::MAX_ORDERS_PER_LEVEL) {
            return false;  // Level full
        }
        orders[order_count++] = Order(id, qty, ts);
        total_quantity += qty;
        return true;
    }
    
    bool removeOrder(OrderId id, Quantity qty) {
        for (int i = 0; i < order_count; ++i) {
            if (orders[i].id == id) {
                total_quantity -= std::min(qty, orders[i].quantity);
                orders[i].quantity -= qty;
                if (orders[i].quantity <= 0) {
                    // Remove order by shifting
                    for (int j = i; j < order_count - 1; ++j) {
                        orders[j] = orders[j + 1];
                    }
                    --order_count;
                }
                return true;
            }
        }
        return false;  // Order not found
    }
};

//=============================================================================
// BOOK STATISTICS
// Tracked atomically for thread-safe access in backtesting
//=============================================================================

struct alignas(64) BookStatistics {
    // Message counters
    std::atomic<uint64_t> messages_processed{0};
    std::atomic<uint64_t> add_count{0};
    std::atomic<uint64_t> cancel_count{0};
    std::atomic<uint64_t> modify_count{0};
    std::atomic<uint64_t> execute_count{0};
    
    // Error counters
    std::atomic<uint64_t> invalid_messages{0};
    std::atomic<uint64_t> book_full_errors{0};
    std::atomic<uint64_t> order_not_found{0};
    
    // Trading statistics
    std::atomic<uint64_t> total_volume{0};
    std::atomic<int64_t> net_volume{0};  // Buy volume - sell volume
    
    // Sequence tracking
    std::atomic<uint64_t> sequence_number{0};
    std::atomic<uint64_t> last_exchange_ts{0};
    std::atomic<uint64_t> last_local_ts{0};
    
    // Latency tracking (exchange to local)
    std::atomic<uint64_t> max_latency_ns{0};
    std::atomic<uint64_t> latency_sum{0};
    
    // Book state
    std::atomic<int64_t> best_bid{0};
    std::atomic<int64_t> best_ask{0};
    std::atomic<int64_t> spread{0};
    
    void reset() {
        messages_processed.store(0);
        add_count.store(0);
        cancel_count.store(0);
        modify_count.store(0);
        execute_count.store(0);
        invalid_messages.store(0);
        book_full_errors.store(0);
        order_not_found.store(0);
        total_volume.store(0);
        net_volume.store(0);
        sequence_number.store(0);
        last_exchange_ts.store(0);
        last_local_ts.store(0);
        max_latency_ns.store(0);
        latency_sum.store(0);
        best_bid.store(0);
        best_ask.store(0);
        spread.store(0);
    }
};

//=============================================================================
// ORDER BOOK - One Side (Bid or Ask)
//=============================================================================

class BookSide {
public:
    explicit BookSide(bool is_bid) : is_bid_(is_bid), num_levels_(0) {}
    
    void clear() {
        num_levels_ = 0;
        for (auto& level : levels_) {
            level.clear();
        }
    }
    
    // Get best price (highest bid or lowest ask)
    Price bestPrice() const {
        if (num_levels_ == 0) return 0;
        return levels_[0].price;
    }
    
    // Get total quantity at best price
    Quantity bestQuantity() const {
        if (num_levels_ == 0) return 0;
        return levels_[0].total_quantity;
    }
    
    // Add order at price level
    bool addOrder(Price price, OrderId id, Quantity qty, Timestamp ts) {
        int idx = findOrCreateLevel(price);
        if (idx < 0) return false;
        return levels_[idx].addOrder(id, qty, ts);
    }
    
    // Remove order from price level
    bool removeOrder(Price price, OrderId id, Quantity qty) {
        int idx = findLevel(price);
        if (idx < 0) return false;
        
        bool result = levels_[idx].removeOrder(id, qty);
        
        // Remove empty levels
        if (levels_[idx].order_count == 0) {
            removeLevel(idx);
        }
        
        return result;
    }
    
    // Get depth at a specific level (0 = best)
    std::pair<Price, Quantity> getLevel(int depth) const {
        if (depth >= num_levels_) {
            return {0, 0};
        }
        return {levels_[depth].price, levels_[depth].total_quantity};
    }

private:
    int findLevel(Price price) const {
        for (int i = 0; i < num_levels_; ++i) {
            if (levels_[i].price == price) return i;
        }
        return -1;
    }
    
    int findOrCreateLevel(Price price) {
        // Find insertion point maintaining sort order
        // Bids: highest price first (descending)
        // Asks: lowest price first (ascending)
        int insert_pos = 0;
        for (int i = 0; i < num_levels_; ++i) {
            if (levels_[i].price == price) {
                return i;  // Level exists
            }
            if (is_bid_) {
                if (levels_[i].price > price) insert_pos = i + 1;
            } else {
                if (levels_[i].price < price) insert_pos = i + 1;
            }
        }
        
        if (num_levels_ >= config::MAX_PRICE_LEVELS) {
            return -1;  // Book full
        }
        
        // Shift levels to make room
        for (int i = num_levels_; i > insert_pos; --i) {
            levels_[i] = levels_[i - 1];
        }
        
        levels_[insert_pos].clear();
        levels_[insert_pos].price = price;
        ++num_levels_;
        
        return insert_pos;
    }
    
    void removeLevel(int idx) {
        for (int i = idx; i < num_levels_ - 1; ++i) {
            levels_[i] = levels_[i + 1];
        }
        levels_[num_levels_ - 1].clear();
        --num_levels_;
    }
    
    bool is_bid_;
    int num_levels_;
    std::array<PriceLevel, config::MAX_PRICE_LEVELS> levels_;
};

//=============================================================================
// FULL ORDER BOOK
//=============================================================================

class OrderBook {
public:
    OrderBook() : bids_(true), asks_(false) {}
    
    void clear() {
        bids_.clear();
        asks_.clear();
    }
    
    BookSide& bids() { return bids_; }
    BookSide& asks() { return asks_; }
    const BookSide& bids() const { return bids_; }
    const BookSide& asks() const { return asks_; }
    
    Price bestBid() const { return bids_.bestPrice(); }
    Price bestAsk() const { return asks_.bestPrice(); }
    Price spread() const { 
        Price bid = bestBid();
        Price ask = bestAsk();
        if (bid == 0 || ask == 0) return 0;
        return ask - bid;
    }
    
    Price midPrice() const {
        Price bid = bestBid();
        Price ask = bestAsk();
        if (bid == 0 || ask == 0) return 0;
        return (bid + ask) / 2;
    }

private:
    BookSide bids_;
    BookSide asks_;
};

void onAnalyticsUpdate(const MarketDataMessage& msg);

//=============================================================================
// MARKET DATA HANDLER
// Core message processing engine - this is the HOT PATH
//=============================================================================
class MarketDataHandler {
public:
    MarketDataHandler() {
        stats_.reset();
        book_.clear();
    }
    
    //=========================================================================
    // MAIN HOT PATH - Called for every market data message
    //
    // This function contains atomic operations that are:
    // - NECESSARY in backtesting (multiple threads process data)
    // - UNNECESSARY in production (single-threaded, pinned core)
    //
    // Our compiler pass elides these atomics in production builds.
    //=========================================================================
    
    __attribute__((noinline))  // Keep separate for profiling
    void onMessage(const MarketDataMessage& msg) {
        // ATOMIC: Sequence number for message ordering
        // Critical for detecting gaps in market data feed
        uint64_t seq = stats_.sequence_number.fetch_add(1);
        
        // ATOMIC: Track exchange and local timestamps
        stats_.last_exchange_ts.store(msg.exchange_ts);
        stats_.last_local_ts.store(msg.local_ts);
        
        // ATOMIC: Latency tracking
        if (msg.local_ts > msg.exchange_ts) {
            uint64_t latency = msg.local_ts - msg.exchange_ts;
            stats_.latency_sum.fetch_add(latency);
            
            // Track max latency (atomic max pattern)
            uint64_t current_max = stats_.max_latency_ns.load();
            while (latency > current_max) {
                if (stats_.max_latency_ns.compare_exchange_weak(current_max, latency)) {
                    break;
                }
            }
        }
        
        // Process message by type
        bool success = false;
        switch (msg.type) {
            case MessageType::ADD:
                success = handleAdd(msg);
                if (success) stats_.add_count.fetch_add(1);
                break;
                
            case MessageType::CANCEL:
                success = handleCancel(msg);
                if (success) stats_.cancel_count.fetch_add(1);
                break;
                
            case MessageType::MODIFY:
                success = handleModify(msg);
                if (success) stats_.modify_count.fetch_add(1);
                break;
                
            case MessageType::EXECUTE:
                success = handleExecute(msg);
                if (success) {
                    stats_.execute_count.fetch_add(1);
                    // Track volume
                    stats_.total_volume.fetch_add(msg.quantity);
                    if (msg.side == Side::BID) {
                        stats_.net_volume.fetch_add(msg.quantity);
                    } else {
                        stats_.net_volume.fetch_sub(msg.quantity);
                    }
                }
                break;
                
            case MessageType::CLEAR:
                book_.clear();
                success = true;
                break;
                
            default:
                stats_.invalid_messages.fetch_add(1);
                return;
        }
        
        if (!success) {
            stats_.order_not_found.fetch_add(1);
        }
        
        // Update BBO (Best Bid/Offer) atomically
        updateBBO();
        
        // ATOMIC: Message counter (for monitoring dashboards)
        stats_.messages_processed.fetch_add(1);

        onAnalyticsUpdate(msg);
    }
    
    // Access statistics (thread-safe reads)
    const BookStatistics& stats() const { return stats_; }
    
    // Access book (NOT thread-safe - only use from processing thread)
    const OrderBook& book() const { return book_; }

private:
    bool handleAdd(const MarketDataMessage& msg) {
        BookSide& side = (msg.side == Side::BID) ? book_.bids() : book_.asks();
        bool success = side.addOrder(msg.price, msg.order_id, msg.quantity, msg.exchange_ts);
        if (!success) {
            stats_.book_full_errors.fetch_add(1);
        }
        return success;
    }
    
    bool handleCancel(const MarketDataMessage& msg) {
        BookSide& side = (msg.side == Side::BID) ? book_.bids() : book_.asks();
        return side.removeOrder(msg.price, msg.order_id, msg.quantity);
    }
    
    bool handleModify(const MarketDataMessage& msg) {
        // Modify = Cancel + Add at new price/size
        BookSide& side = (msg.side == Side::BID) ? book_.bids() : book_.asks();
        // For simplicity, just update at same price
        // Real implementation would handle price changes
        return side.removeOrder(msg.price, msg.order_id, 0) &&
               side.addOrder(msg.price, msg.order_id, msg.quantity, msg.exchange_ts);
    }
    
    bool handleExecute(const MarketDataMessage& msg) {
        BookSide& side = (msg.side == Side::BID) ? book_.bids() : book_.asks();
        return side.removeOrder(msg.price, msg.order_id, msg.quantity);
    }
    
    void updateBBO() {
        // ATOMIC: Update best bid/ask/spread for monitoring
        Price bid = book_.bestBid();
        Price ask = book_.bestAsk();
        
        stats_.best_bid.store(bid);
        stats_.best_ask.store(ask);
        
        if (bid > 0 && ask > 0) {
            stats_.spread.store(ask - bid);
        }
    }
    
    OrderBook book_;
    BookStatistics stats_;
};

//=============================================================================
// MESSAGE GENERATOR
// Creates realistic market data for benchmarking
//=============================================================================

class MessageGenerator {
public:
    explicit MessageGenerator(uint64_t seed = 42) : rng_(seed) {}
    
    std::vector<MarketDataMessage> generate(int count) {
        std::vector<MarketDataMessage> messages;
        messages.reserve(count);
        
        // Distribution for message types (realistic mix)
        // ~60% adds, ~25% cancels, ~10% modifies, ~5% executes
        std::discrete_distribution<int> type_dist({60, 25, 10, 5});
        std::bernoulli_distribution side_dist(0.5);
        std::uniform_int_distribution<int> price_offset(-50, 50);  // ticks from mid
        std::uniform_int_distribution<Quantity> qty_dist(1, 1000);
        
        Price mid_price = priceToTicks(config::REFERENCE_PRICE);
        uint64_t timestamp = 1000000000000ULL;  // 1 second in ns
        OrderId next_order_id = 1;
        
        for (int i = 0; i < count; ++i) {
            MarketDataMessage msg{};
            
            int type_idx = type_dist(rng_);
            switch (type_idx) {
                case 0: msg.type = MessageType::ADD; break;
                case 1: msg.type = MessageType::CANCEL; break;
                case 2: msg.type = MessageType::MODIFY; break;
                case 3: msg.type = MessageType::EXECUTE; break;
            }
            
            msg.side = side_dist(rng_) ? Side::BID : Side::ASK;
            
            // Generate price near mid
            int offset = price_offset(rng_);
            if (msg.side == Side::BID) {
                msg.price = mid_price - std::abs(offset);  // Bids below mid
            } else {
                msg.price = mid_price + std::abs(offset);  // Asks above mid
            }
            
            msg.quantity = qty_dist(rng_);
            msg.order_id = next_order_id++;
            
            // Timestamps with realistic ~100ns jitter
            msg.exchange_ts = timestamp;
            msg.local_ts = timestamp + 50 + (rng_() % 100);  // 50-150ns latency
            
            timestamp += 100;  // 100ns between messages (10M msg/sec)
            
            messages.push_back(msg);
        }
        
        return messages;
    }

private:
    std::mt19937_64 rng_;
};

//=============================================================================
// BENCHMARK HARNESS
//=============================================================================

void printStatistics(const BookStatistics& stats) {
    std::cout << "\n=== Book Statistics ===\n";
    std::cout << "Messages processed: " << stats.messages_processed.load() << "\n";
    std::cout << "  Adds:     " << stats.add_count.load() << "\n";
    std::cout << "  Cancels:  " << stats.cancel_count.load() << "\n";
    std::cout << "  Modifies: " << stats.modify_count.load() << "\n";
    std::cout << "  Executes: " << stats.execute_count.load() << "\n";
    std::cout << "\n";
    std::cout << "Errors:\n";
    std::cout << "  Invalid:    " << stats.invalid_messages.load() << "\n";
    std::cout << "  Book full:  " << stats.book_full_errors.load() << "\n";
    std::cout << "  Not found:  " << stats.order_not_found.load() << "\n";
    std::cout << "\n";
    std::cout << "Trading:\n";
    std::cout << "  Total volume: " << stats.total_volume.load() << "\n";
    std::cout << "  Net volume:   " << stats.net_volume.load() << "\n";
    std::cout << "\n";
    std::cout << "Book state:\n";
    std::cout << "  Best bid:  " << ticksToPrice(stats.best_bid.load()) << "\n";
    std::cout << "  Best ask:  " << ticksToPrice(stats.best_ask.load()) << "\n";
    std::cout << "  Spread:    " << stats.spread.load() << " ticks\n";
    std::cout << "\n";
    std::cout << "Latency:\n";
    uint64_t msgs = stats.messages_processed.load();
    if (msgs > 0) {
        std::cout << "  Avg: " << stats.latency_sum.load() / msgs << " ns\n";
    }
    std::cout << "  Max: " << stats.max_latency_ns.load() << " ns\n";
}

__attribute__((noinline))
void onAnalyticsUpdate(const MarketDataMessage& msg) {
    const int level = msg.price % config::MAX_PRICE_LEVELS;

    if (msg.side == Side::BID) {
        auto& lvl = bidAnalytics[level];

        // Hot fields
        lvl.mid_imbalance =
            lvl.mid_imbalance * 0.9 + (lvl.queue_pressure * 0.1);
        lvl.queue_pressure =
            (double)lvl.last_update_ts_ns * 0.001;
        lvl.micro_volatility =
            std::abs((int)msg.quantity - 50) * 0.02;

        // Hot loop across ALL BID levels
        double acc = 0.0;
        for (int i = 0; i < config::MAX_PRICE_LEVELS; ++i) {
            acc += bidAnalytics[i].mid_imbalance +
                   bidAnalytics[i].queue_pressure +
                   bidAnalytics[i].micro_volatility;
        }

        // Semi-hot fields
        lvl.short_term_alpha = acc * 1e-6;
        lvl.last_price_move = 1.0;
        lvl.last_update_ts_ns = msg.local_ts;

    } else {
        auto& lvl = askAnalytics[level];

        // Hot fields
        lvl.mid_imbalance =
            lvl.mid_imbalance * 0.9 + (lvl.queue_pressure * 0.1);
        lvl.queue_pressure =
            (double)lvl.last_update_ts_ns * 0.001;
        lvl.micro_volatility =
            std::abs((int)msg.quantity - 50) * 0.02;

        // Hot loop across ALL ASK levels
        double acc = 0.0;
        for (int i = 0; i < config::MAX_PRICE_LEVELS; ++i) {
            acc += askAnalytics[i].mid_imbalance +
                   askAnalytics[i].queue_pressure +
                   askAnalytics[i].micro_volatility;
        }

        // Semi-hot fields
        lvl.short_term_alpha = acc * 1e-6;
        lvl.last_price_move = -1.0;
        lvl.last_update_ts_ns = msg.local_ts;
    }
}

int main() {
    std::cout << "===========================================\n";
    std::cout << "HFT Order Book Engine - Atomic Elision Demo\n";
    std::cout << "===========================================\n";
    std::cout << "\n";
    std::cout << "Configuration:\n";
    std::cout << "  Messages:     " << config::NUM_MESSAGES << "\n";
    std::cout << "  Price levels: " << config::MAX_PRICE_LEVELS << "\n";
    std::cout << "  Tick size:    $" << config::TICK_SIZE << "\n";
    std::cout << "\n";
    
    // Initialize
    MarketDataHandler handler;
    MessageGenerator generator;
    
    std::cout << "Generating market data messages...\n";
    auto messages = generator.generate(config::NUM_MESSAGES);
    
    std::cout << "Processing messages...\n";
    
    // Benchmark
    std::cout << "===========================================\n";
    std::cout << "HFT Order Book Engine - Atomic Elision Demo\n";
    std::cout << "===========================================\n";
    std::cout << "\n";
    std::cout << "Configuration:\n";
    std::cout << "  Messages:     " << config::NUM_MESSAGES << "\n";
    std::cout << "  Price levels: " << config::MAX_PRICE_LEVELS << "\n";
    std::cout << "  Tick size:    $" << config::TICK_SIZE << "\n";
    std::cout << "\n";
    std::cout << "Processing messages...\n";
    
    // Benchmark
    auto start = std::chrono::high_resolution_clock::now();
    
    for (const auto& msg : messages) {
        handler.onMessage(msg);
    }

    auto end = std::chrono::high_resolution_clock::now();
    
    // Results
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
    double seconds = duration.count() / 1000.0;
    double msgs_per_sec = config::NUM_MESSAGES / seconds;
    double ns_per_msg = (duration.count() * 1e6) / config::NUM_MESSAGES;
    
    std::cout << "\n=== Performance Results ===\n";
    std::cout << "Time:       " << duration.count() << " ms\n";
    std::cout << "Throughput: " << msgs_per_sec / 1e6 << " M msgs/sec\n";
    std::cout << "Latency:    " << ns_per_msg << " ns/msg\n";
    
    // Print statistics to prevent DCE and verify correctness
    printStatistics(handler.stats());
    return 0;
}