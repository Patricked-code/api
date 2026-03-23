CREATE TABLE IF NOT EXISTS roboadvisor_questionnaires (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(100) NOT NULL,
    label VARCHAR(255) NOT NULL,
    version VARCHAR(50) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_roboadvisor_questionnaires_code_version (code, version)
);

CREATE TABLE IF NOT EXISTS roboadvisor_questionnaire_answers (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    questionnaire_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    session_id VARCHAR(120) NULL,
    horizon_years INT NULL,
    max_drawdown_tolerance INT NULL,
    loss_reaction_score INT NULL,
    income_stability_score INT NULL,
    liquidity_need_score INT NULL,
    investment_experience_score INT NULL,
    payload_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_rqa_questionnaire_id (questionnaire_id),
    KEY idx_rqa_user_id (user_id),
    CONSTRAINT fk_rqa_questionnaire FOREIGN KEY (questionnaire_id) REFERENCES roboadvisor_questionnaires(id)
);

CREATE TABLE IF NOT EXISTS roboadvisor_profiles (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    answer_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    profile_code VARCHAR(50) NOT NULL,
    profile_label VARCHAR(120) NOT NULL,
    score INT NOT NULL,
    target_equity_range VARCHAR(30) NULL,
    target_fixed_income_range VARCHAR(30) NULL,
    target_liquidity_range VARCHAR(30) NULL,
    recommendation_json JSON NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_rp_answer_id (answer_id),
    KEY idx_rp_user_id (user_id),
    KEY idx_rp_profile_code (profile_code),
    CONSTRAINT fk_rp_answer FOREIGN KEY (answer_id) REFERENCES roboadvisor_questionnaire_answers(id)
);
