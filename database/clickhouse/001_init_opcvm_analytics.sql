CREATE DATABASE IF NOT EXISTS opcvm_analytics;

CREATE TABLE IF NOT EXISTS opcvm_analytics.fund_navs_daily
(
    fund_id UInt32,
    fund_name String,
    valuation_date Date,
    nav_local Float64,
    nav_usd Float64,
    nav_eur Float64,
    adjusted_nav_local Float64,
    adjusted_nav_usd Float64,
    adjusted_nav_eur Float64,
    dividend_local Float64,
    dividend_usd Float64,
    dividend_eur Float64,
    benchmark_name String,
    benchmark_value_local Float64,
    benchmark_value_usd Float64,
    benchmark_value_eur Float64,
    aum_local Float64,
    aum_usd Float64,
    aum_eur Float64,
    subscription_price Float64,
    redemption_price Float64,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(valuation_date)
ORDER BY (fund_id, valuation_date);

CREATE TABLE IF NOT EXISTS opcvm_analytics.portfolio_positions_daily
(
    portfolio_id UInt32,
    user_id UInt32,
    fund_id UInt32,
    valuation_date Date,
    quantity Float64,
    market_value Float64,
    average_cost Float64,
    cash_balance Float64,
    currency String,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(valuation_date)
ORDER BY (portfolio_id, valuation_date, fund_id);

CREATE TABLE IF NOT EXISTS opcvm_analytics.fund_performance_monthly
(
    fund_id UInt32,
    fund_name String,
    month Date,
    return_mtd Float64,
    return_ytd Float64,
    volatility_1y Float64,
    drawdown Float64,
    sharpe Float64,
    sortino Float64,
    calmar Float64,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(month)
ORDER BY (fund_id, month);
