CREATE TABLE IF NOT EXISTS roboadvisor_recommendations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    profile_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    summary TEXT NULL,
    suitable_fund_styles_json JSON NULL,
    indicative_allocation_json JSON NULL,
    warnings_json JSON NULL,
    next_steps_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_rr_profile_id (profile_id),
    KEY idx_rr_user_id (user_id),
    CONSTRAINT fk_rr_profile FOREIGN KEY (profile_id) REFERENCES roboadvisor_profiles(id)
);
