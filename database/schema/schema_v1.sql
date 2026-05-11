-- =============================================================================
-- PROJECT      : Expense Tracker System
-- DATABASE     : expense_tracker_system
-- RDBMS TARGET : MySQL 8.0+ (InnoDB) with PostgreSQL-compatible annotations
-- MILESTONE    : M1 (ERD) + M2 (Normalization)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS expense_tracker_system
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE expense_tracker_system;

DROP TABLE IF EXISTS budgets;
DROP TABLE IF EXISTS income_records;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id       INT            NOT NULL AUTO_INCREMENT,
    username      VARCHAR(64)    NOT NULL,
    email         VARCHAR(255)   NOT NULL,
    password_hash VARCHAR(255)   NOT NULL,

    CONSTRAINT pk_users          PRIMARY KEY (user_id),
    CONSTRAINT uq_users_username UNIQUE      (username),
    CONSTRAINT uq_users_email    UNIQUE      (email)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Root entity — one row per registered user account.';

CREATE TABLE categories (
    category_id   INT            NOT NULL AUTO_INCREMENT,
    user_id       INT            NOT NULL,
    category_name VARCHAR(128)   NOT NULL,
    type          VARCHAR(10)    NOT NULL,

    CONSTRAINT pk_categories PRIMARY KEY (category_id),
    CONSTRAINT uq_categories_user_name UNIQUE (user_id, category_name),
    CONSTRAINT chk_categories_type CHECK (type IN ('INCOME', 'EXPENSE')),
    CONSTRAINT fk_categories_user FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='User-defined expense/income category labels. One namespace per user.';

CREATE INDEX idx_categories_user_id
    ON categories (user_id);

CREATE TABLE expenses (
    expense_id    INT            NOT NULL AUTO_INCREMENT,
    user_id       INT            NOT NULL,
    category_id   INT            NOT NULL,
    amount        DECIMAL(10,2)  NOT NULL,
    description   TEXT           NULL,
    expense_date  DATE           NOT NULL,

    CONSTRAINT pk_expenses PRIMARY KEY (expense_id),
    CONSTRAINT chk_expenses_amount CHECK (amount > 0),
    CONSTRAINT fk_expenses_user FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_expenses_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ledger of expense transactions. Category FK is RESTRICT to guard history.';

CREATE INDEX idx_expenses_user_id ON expenses (user_id);
CREATE INDEX idx_expenses_category_id ON expenses (category_id);

CREATE TABLE income_records (
    income_id     INT            NOT NULL AUTO_INCREMENT,
    user_id       INT            NOT NULL,
    source_name   VARCHAR(128)   NOT NULL,
    amount        DECIMAL(10,2)  NOT NULL,
    income_date   DATE           NOT NULL,
    notes         TEXT           NULL,

    CONSTRAINT pk_income_records PRIMARY KEY (income_id),
    CONSTRAINT chk_income_amount CHECK (amount > 0),
    CONSTRAINT fk_income_records_user FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ledger of income transactions belonging to a user.';

CREATE INDEX idx_income_records_user_id
    ON income_records (user_id);

CREATE TABLE budgets (
    budget_id     INT            NOT NULL AUTO_INCREMENT,
    user_id       INT            NOT NULL,
    category_id   INT            NOT NULL,
    amount        DECIMAL(10,2)  NOT NULL,
    period        VARCHAR(16)    NOT NULL,

    CONSTRAINT pk_budgets PRIMARY KEY (budget_id),
    CONSTRAINT uq_budgets_category_id UNIQUE (category_id),
    CONSTRAINT chk_budgets_amount CHECK (amount > 0),
    CONSTRAINT chk_budgets_period CHECK (period IN ('DAILY', 'WEEKLY', 'MONTHLY', 'ANNUAL')),
    CONSTRAINT fk_budgets_user FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_budgets_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Per-category spending limits. user_id retained for query efficiency.';

CREATE INDEX idx_budgets_user_id
    ON budgets (user_id);
