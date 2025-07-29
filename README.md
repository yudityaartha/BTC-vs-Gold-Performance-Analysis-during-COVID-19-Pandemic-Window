# BTC vs Gold Performance Analysis during COVID-19 Pandemic Window (Jan 2020 – Dec 2023) - Project Description
Sparked by Bitcoin’s recent all time high in July 2025, I compare 2 assets performance: BTC vs Gold. 
Why compare BTC and Gold? Because Gold is traditionally seen as the “safe haven,” while BTC is the rebellious new asset class. I want to test this narrative, especially during a time of global crisis. This project investigates volatility, momentum, and trend behavior across both assets using SQL, PostgreSQL, Tableau, and statistical reasoning.

---

## 🔍 Objectives

- Compare **risk-return dynamics** between BTC and Gold
- Detect market **volatility regimes**
- Categorize **momentum trends** and **price position relative to trend**
- Build an end-to-end mini analytics pipeline from raw CSV to interactive dashboard

---

## Dataset Sources

- 📉 [Bitcoin Historical Dataset (2018–2024)](https://www.kaggle.com/datasets/novandraanugrah/bitcoin-historical-datasets-2018-2024)
- 🪙 [Gold Price Historical Dataset (2004–2024)](https://www.kaggle.com/datasets/novandraanugrah/xauusd-gold-price-historical-data-2004-2024)

---

## Metrics Explained

| Metric Name               | Description                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| **Daily Percentage Changes** | close price - prev close price) / prev close price  * 100                |
| **Normalized Price**      | Price indexed to Jan 1, 2020 (base = 100)                                   |
| **Rolling Avg (7D)**      | 7-day moving average of close price                                         |
| **Rolling Volatility (7D)** | 7-day rolling standard deviation of close price                            |
| **% Volatility**          | Coefficient of Variation = Volatility / Avg Price * 100                     |
| **Volatility Z-score**    | Standardized volatility vs historical mean and std deviation of Rolling Volatility |
| **Daily Percentage Change Z-score**    | Standardized volatility vs historical mean and std deviation   |
| **Momentum Regime**       | Based on daily % change Z-score: Sideways, Bullish, Bearish, etc.           |
| **Trend Status**          | Whether price is above/below/at its 7-day rolling average                    |

---

## 🧪 Technologies Used

- **PostgreSQL** (Data storage + SQL queries)
- **SQL Queries** (Table Join, CASE-WHEN, Window Functions, Aggregation, Union)
- **Tableau Public** (Interactive dashboards)
- **Railway** (Database hosting)
- **Google Sheets** (data source connection to Tableau Public)

---

## 🔄 Pipeline Overview

See [`pipeline_steps.md`](pipeline/pipeline_steps.md) for a breakdown of how raw data becomes insight.

---

## Dashboards

Interactive Tableau dashboards available here (insert link to Tableau Public once published).

- Normalized Price
- Relative Volatility (Coefficient of Variance)
- Volatility Z-score
- Volatility Regime
- Momentum Regime
- Trend Status
- Daily Percent Change Z-score
- CLose price vs 7 Days Moving Average (Trend Status)

---

## Key Insights

- **Return Profile**: BTC grew ~9× from Jan 2020; Gold ~1.5×.
- **Volatility Risk**: BTC is significantly more volatile than Gold, especially during crisis.
- **Z-Score Behavior**: Gold, despite being less volatile, shows **higher Volatility Z-score spikes**, meaning it’s more reactive relative to its own history.
  Meanwhile BTC also react to the crisis, but BTC is already turbulent & chaotic by its nature.
- **Momentum** Both BTC and Gold spent most days sideways or mild (bullish or bearish) momentum regimes (~88% - 89% of total days), with estimated only ~10–12% of days show extreme moves (strong bullish or strong bearish).
While BTC’s daily percent change shows bigger volatility to Gold’s, its higher noise floor means fewer days cross our ‘strong’ thresholds. Whereas Gold, which normally very stable, flags ‘extreme’ strong moves slightly more often.
- **Trend Regime**: Each asset spent roughly 54% of days above its 7‑day rolling average, The real divergence lies in BTC’s capture explosive returns when “above trend” days but with high whipsaw risk. Whereas, gold’s are steadier and less prone to false breakouts.
---

## 📁 Repository Structure

```bash
btc-vs-gold-performance/
├── data/
│   ├── btc_usdt.csv
│   └── xau_usdt.csv
├── sql/
│   └── btc_gold_analysis.sql
├── dashboards/
│   └── tableau_screenshots/
├── pipeline/
│   └── pipeline_steps.md
└── README.md

