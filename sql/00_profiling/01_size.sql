-- How big is the dataset, and does the date range match Google's documentation (1 Nov 2020 – 31 Jan 2021 = 92 days)?
SELECT
  COUNT(*)                       AS events,
  COUNT(DISTINCT user_pseudo_id) AS users,
  COUNT(DISTINCT event_date)     AS days,
  MIN(event_date)                AS first_day,
  MAX(event_date)                AS last_day
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
