-- Are purchase events duplicated (same transaction_id logged more than once)?
SELECT
  COUNT(*)                       AS txn_ids_logged_more_than_once,
  SUM(n - 1)                     AS extra_duplicate_events,
  ROUND(SUM(extra_revenue), 2)   AS revenue_double_counted_usd
FROM (
  SELECT ecommerce.transaction_id,
         COUNT(*) AS n,
         SUM(ecommerce.purchase_revenue_in_usd) - MAX(ecommerce.purchase_revenue_in_usd) AS extra_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase' AND ecommerce.transaction_id != '(not set)'
  GROUP BY 1
  HAVING COUNT(*) > 1
);
