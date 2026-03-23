CREATE TABLE IF NOT EXISTS opcvm_analytics.roboadvisor_profile_events
(
    event_id UUID,
    user_id UInt32,
    profile_code String,
    profile_label String,
    score UInt16,
    horizon_years UInt16,
    max_drawdown_tolerance UInt16,
    liquidity_need_score UInt16,
    investment_experience_score UInt16,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(created_at)
ORDER BY (user_id, created_at, event_id);
