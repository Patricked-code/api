CREATE TABLE IF NOT EXISTS opcvm_analytics.fund_performance_periodic
(
    fund_id UInt32,
    fund_name String,
    period_code String,
    as_of_date Date,
    performance_value Float64,
    annualized_performance Float64,
    volatility Float64,
    drawdown Float64,
    sharpe Float64,
    sortino Float64,
    calmar Float64,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(as_of_date)
ORDER BY (fund_id, period_code, as_of_date);
