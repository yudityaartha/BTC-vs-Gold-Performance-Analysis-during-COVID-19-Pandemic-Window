#  BTC vs Gold: Data Pipeline Breakdown

This file explains how raw Kaggle CSV data was transformed into structured insights using SQL, PostgreSQL, and Tableau.

## Automated Data Pipelines
I host my PostgreSQL database on Railway, so whenever I add or modify SQL tables (e.g. new queries, metrics, or asset tables), those changes flow automatically through the following chain:
  1. **Railway‑hosted PostgreSQL** – centralized, always‑on database
  2. **Coefficient integration** – live sync from PostgreSQL into Google Sheets
  3. **Tableau Public** – connects directly to the Google Sheet, so any upstream SQL changes instantly refresh every dashboard and story point

This setup means I can iterate on my SQL logic or add new tables, and the updated data propagates end‑to‑end—no manual exports—keeping my Tableau dashboards always up to date.

---

## Step 1: Source Datasets

- BTC: [Bitcoin Historical Dataset](https://www.kaggle.com/datasets/novandraanugrah/bitcoin-historical-datasets-2018-2024)
- Gold: [Gold Price Dataset](https://www.kaggle.com/datasets/novandraanugrah/xauusd-gold-price-historical-data-2004-2024)
I downloaded both datasets from the link above

---

## Step 2: Preprocessing

- Perform data wrangling and quick glimpse on the datasets
- Ensure the content is standardized, e.g.: column names, number formats and etc.
- Verified consistent time granularity (daily)

---

## Step 3: PostgreSQL Setup

- Create tables columns and empty tables in PostgreSQL.
Columns name are matched to the steps performed on step 2
- Imported data into PostgreSQL
- Created 2 base tables:
  - `btc_usdt`
  - `xau_usdt`
- Perform left join these 2 tables on dates

---

## Step 4: SQL Queries Engineering

All metrics computed using PostgreSQL window functions:

- Normalized Price
- 7-Day Rolling Average & Volatility
- Daily % Change
- Daily % Change Z-Score
- Price Quartile Bucketing
- Volatility Z-score
- Volatility Regime
- Momentum Regime Classification
- Trend Status (vs 7D MA - 7D Rolling Average)

Main tables created:

- `btc_vs_gold`: raw combination + base metrics
- Perform Union All to pivot btc_vs_gold to create `asset_daily_metrics`
- `asset_daily_metrics`: enriched + labeled dataset for visualization

Full SQL query: [`sql/btc_gold_analysis.sql`](SQL_Queries.sql)

---

## Step 5: Cloud Hosting

- Used [Railway.app](https://railway.app) to host the PostgreSQL database
- PostgreSQL cloud database is connected to Google Sheet using Coeffecient
- Enabled live connections from Google Sheet to Tableau

---

## Step 7: Google Sheets & Coeffecient Extension

- Exported sample slices for inspection
- Used for metric sanity checks

---

## Step 6: Tableau Dashboard

- Built multi-layer dashboard:
  - Normalized performance
  - Rolling volatility vs Z-score
  - Momentum regime (based on z-score)
  - Trend status
  - 7 Days moving average vs price movement

- Applied filters: asset, time, volatility regime, trend status

---

## Update Plan

- Future improvement: support real-time connection with API-driven BTC/Gold prices
- Might add Sharpe Ratio and drawdown metrics in the next iteration

