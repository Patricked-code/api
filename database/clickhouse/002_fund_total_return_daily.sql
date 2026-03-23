CREATE TABLE IF NOT EXISTS opcvm_analytics.fund_total_return_daily
(
    fund_id UInt32,
    fund_name String,
    valuation_date Date,
    nav_published Float64,
    dividend_local Float64,
    nav_total_return Float64,
    base_100_published Float64,
    base_100_total_return Float64,
    currency String DEFAULT 'XOF',
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(valuation_date)
ORDER BY (fund_id, valuation_date);
