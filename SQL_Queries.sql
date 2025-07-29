DROP TABLE IF EXISTS btc_vs_gold;
CREATE table btc_vs_gold AS(
SELECT 
  /* These to analyze BTC */
  btc.date,
  btc.close_price AS btc_close_price,
  ROUND((btc.close_price / FIRST_VALUE(btc.close_price) OVER (ORDER BY btc.date)) * 100,2) AS btc_normalized_price,
  ROUND(AVG(btc.close_price) OVER (ORDER BY btc.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS btc_rolling_avg_7d,
  ROUND(STDDEV(btc.close_price) OVER (ORDER BY btc.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS btc_rolling_volatility_7d,
  ROUND(LAG(btc.close_price) OVER (ORDER BY btc.date),2) AS btc_previous_close,
  
  /* daily percentage changes => (close price - prev close price) : prev close price */
  ROUND(((btc.close_price - LAG(btc.close_price) OVER (ORDER BY btc.date)) 
      / LAG(btc.close_price) OVER (ORDER BY btc.date)) * 100,2) AS btc_daily_pct_change,
  
  NTILE(4) OVER (ORDER BY btc.close_price) AS btc_price_quartile,
  
  /* These to analyze Gold */
  xau.close_price AS xau_close_price,
  ROUND((xau.close_price / FIRST_VALUE(xau.close_price) OVER (ORDER BY xau.date)) * 100,2) AS xau_normalized_price,
  ROUND(AVG(xau.close_price) OVER (ORDER BY xau.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS xau_rolling_avg_7d,
  ROUND(STDDEV(xau.close_price) OVER (ORDER BY xau.date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS xau_rolling_volatility_7d,
  ROUND(LAG(xau.close_price) OVER (ORDER BY xau.date),2) AS xau_previous_close,
  
  ROUND(((xau.close_price - LAG(xau.close_price) OVER (ORDER BY xau.date)) 
      / LAG(xau.close_price) OVER (ORDER BY xau.date)) * 100,2) AS xau_daily_pct_change,
  
  NTILE(4) OVER (ORDER BY xau.close_price) AS xau_price_quartile

/* Join btc dataset with gold dataset */ 
FROM btc_usdt AS btc
LEFT JOIN xau_usdt AS xau ON btc.date=xau.date
WHERE btc.date BETWEEN '2020-01-01' AND '2023-12-31'
ORDER BY btc.date
);

DROP TABLE IF EXISTS asset_daily_metrics;
CREATE TABLE asset_daily_metrics AS
SELECT 
  /* These to perform additional analysis on BTC */
  'BTC' AS asset,
  date,
  btc_close_price AS close_price,
  btc_normalized_price AS normalized_price,
  btc_rolling_avg_7d AS rolling_avg_7d,
  btc_rolling_volatility_7d AS rolling_volatility_7d,
  ROUND(btc_rolling_volatility_7d / btc_rolling_avg_7d * 100,2) AS perc_volatility,
  
  /*Volatility ZScore = (7D rolling volatility -  avg 7D rolling volatility) : STDDEV 7D rolling volatility */
  ROUND((btc_rolling_volatility_7d - AVG(btc_rolling_volatility_7d) OVER ()) 
      / STDDEV(btc_rolling_volatility_7d) OVER (), 2) AS volatility_zscore,   
  btc_previous_close AS previous_close,
  btc_daily_pct_change AS daily_pct_change,
  btc_price_quartile AS price_quartile,

  /* Label volatility zscore into low, mid and high */
    CASE 
    WHEN ROUND((btc_rolling_volatility_7d - AVG(btc_rolling_volatility_7d) OVER ()) 
              / STDDEV(btc_rolling_volatility_7d) OVER (), 2) <= -0.5 THEN 'Low Volatility'
    WHEN ROUND((btc_rolling_volatility_7d - AVG(btc_rolling_volatility_7d) OVER ()) 
              / STDDEV(btc_rolling_volatility_7d) OVER (), 2) BETWEEN -0.5 AND 0.5 THEN 'Mid Volatility'
    ELSE 'High Volatility'
  END AS volatility_regime, 
  
  /* Calculate daily pct change zscore */
  ROUND((btc_daily_pct_change - AVG(btc_daily_pct_change) OVER ()) 
  	/ STDDEV(btc_daily_pct_change) OVER (), 2) AS pct_change_zscore,  
	  
  /* Categorize daily percentage zscore */
	CASE 
		WHEN ROUND((btc_daily_pct_change - AVG(btc_daily_pct_change) OVER ()) 
  	/ STDDEV(btc_daily_pct_change) OVER (), 2) IS NULL THEN NULL
		WHEN ROUND((btc_daily_pct_change - AVG(btc_daily_pct_change) OVER ()) 
  	/ STDDEV(btc_daily_pct_change) OVER (), 2) <= -1.5 THEN 'Strong Bearish'
		WHEN ROUND((btc_daily_pct_change - AVG(btc_daily_pct_change) OVER ()) 
  	/ STDDEV(btc_daily_pct_change) OVER (), 2) BETWEEN -1.5 AND -0.5 THEN 'Bearish'
		WHEN ROUND((btc_daily_pct_change - AVG(btc_daily_pct_change) OVER ()) 
  	/ STDDEV(btc_daily_pct_change) OVER (), 2) BETWEEN -0.5 AND 0.5 THEN 'Sideways'
		WHEN ROUND((btc_daily_pct_change - AVG(btc_daily_pct_change) OVER ()) 
  	/ STDDEV(btc_daily_pct_change) OVER (), 2) BETWEEN 0.5 AND 1.5 THEN 'Bullish'
		ELSE 'Strong Bullish'
	END AS momentum_regime,

  
  /*close price > 7D rolling avg => Above Trend, 
  equal means at trend, 
  close price < 7D rolling avg => Below Trend */
  CASE 
    WHEN btc_close_price IS NULL OR btc_rolling_avg_7d IS NULL THEN NULL
    WHEN btc_close_price > btc_rolling_avg_7d THEN 'Above Trend'
    WHEN btc_close_price < btc_rolling_avg_7d THEN 'Below Trend'
    ELSE 'At Trend'
  END AS trend_status,

  EXTRACT(YEAR FROM date) AS year,
  ROW_NUMBER() OVER (PARTITION BY 'BTC' ORDER BY date) AS row_id
FROM btc_vs_gold

UNION ALL 
SELECT 
  /* These to perform additional analysis on Gold */
  'Gold' AS asset,
  date,
  xau_close_price AS close_price,
  xau_normalized_price AS normalized_price,
  xau_rolling_avg_7d AS rolling_avg_7d,
  xau_rolling_volatility_7d AS rolling_volatility_7d,
  ROUND(xau_rolling_volatility_7d / xau_rolling_avg_7d * 100,2) AS perc_volatility,
  
  /*Volatility ZScore = (7D rolling volatility -  avg 7D rolling volatility) : STDDEV 7D rolling volatility */
  ROUND((xau_rolling_volatility_7d - AVG(xau_rolling_volatility_7d) OVER ()) 
      / STDDEV(xau_rolling_volatility_7d) OVER (), 2) AS volatility_zscore,   
  xau_previous_close AS previous_close,
  xau_daily_pct_change AS daily_pct_change,
  xau_price_quartile AS price_quartile,
  
  /* Label volatility zscore into low, mid and high */
    CASE 
    WHEN ROUND((xau_rolling_volatility_7d - AVG(xau_rolling_volatility_7d) OVER ()) 
              / STDDEV(xau_rolling_volatility_7d) OVER (), 2) <= -0.5 THEN 'Low Volatility'
    WHEN ROUND((xau_rolling_volatility_7d - AVG(xau_rolling_volatility_7d) OVER ()) 
              / STDDEV(xau_rolling_volatility_7d) OVER (), 2) BETWEEN -0.5 AND 0.5 THEN 'Mid Volatility'
    ELSE 'High Volatility'
  END AS volatility_regime, 
 
  /* Calculate daily pct change zscore */
  ROUND((xau_daily_pct_change - AVG(xau_daily_pct_change) OVER ()) 
  	/ STDDEV(xau_daily_pct_change) OVER (), 2) AS pct_change_zscore,  
	  
  /* Categorize daily percentage zscore */
	CASE 
		WHEN ROUND((xau_daily_pct_change - AVG(xau_daily_pct_change) OVER ()) 
  	/ STDDEV(xau_daily_pct_change) OVER (), 2) IS NULL THEN NULL
		WHEN ROUND((xau_daily_pct_change - AVG(xau_daily_pct_change) OVER ()) 
  	/ STDDEV(xau_daily_pct_change) OVER (), 2) <= -1.5 THEN 'Strong Bearish'
		WHEN ROUND((xau_daily_pct_change - AVG(xau_daily_pct_change) OVER ()) 
  	/ STDDEV(xau_daily_pct_change) OVER (), 2) BETWEEN -1.5 AND -0.5 THEN 'Bearish'
		WHEN ROUND((xau_daily_pct_change - AVG(xau_daily_pct_change) OVER ()) 
  	/ STDDEV(xau_daily_pct_change) OVER (), 2) BETWEEN -0.5 AND 0.5 THEN 'Sideways'
		WHEN ROUND((xau_daily_pct_change - AVG(xau_daily_pct_change) OVER ()) 
  	/ STDDEV(xau_daily_pct_change) OVER (), 2) BETWEEN 0.5 AND 1.5 THEN 'Bullish'
		ELSE 'Strong Bullish'
	END AS momentum_regime,
  
  /*close price > 7D rolling avg => Above Trend, 
  equal means at trend, 
  close price < 7D rolling avg => Below Trend */
  CASE 
    WHEN xau_close_price IS NULL OR xau_rolling_avg_7d IS NULL THEN NULL
    WHEN xau_close_price > xau_rolling_avg_7d THEN 'Above Trend'
    WHEN xau_close_price < xau_rolling_avg_7d THEN 'Below Trend'
    ELSE 'At Trend'
  END AS trend_status,

  EXTRACT(YEAR FROM date) AS year,
  ROW_NUMBER() OVER (PARTITION BY 'Gold' ORDER BY date) AS row_id
FROM btc_vs_gold;
