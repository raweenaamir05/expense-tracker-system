# Normalization Report — Expense Tracker System

## Overview
This document explains the normalization process applied to the Expense Tracker System database, following 1NF, 2NF, and 3NF (BCNF where applicable).

---

## Users Table
- Already in 3NF/BCNF
- All attributes depend only on primary key: user_id

---

## Categories Table
- 3NF achieved
- Composite uniqueness (user_id, category_name) prevents duplication per user

---

## Expenses Table
- 3NF/BCNF
- No transitive dependencies
- Foreign keys enforce relational integrity

---

## Income Records Table
- 3NF achieved
- All attributes depend only on income_id

---

## Budgets Table
- Mostly 3NF
- Contains controlled denormalization: user_id
- Reason:
  - Improves query performance
  - Avoids unnecessary JOINs
  - Supports row-level filtering

---

## Conclusion
The database is fully normalized to 3NF with one intentional denormalization in the budgets table for performance optimization.
