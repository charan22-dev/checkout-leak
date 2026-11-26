-- What is missing, hidden by Google's obfuscation, or suspicious?
SELECT
  COUNT(*)                                                         AS total_events,
  COUNTIF(device.category IS NULL OR device.category = '')         AS device_missing,
  COUNTIF(traffic_source.medium IN ('<Other>', '(data deleted)'))  AS medium_obfuscated,
  COUNTIF(geo.country IN ('(not set)', ''))                        AS country_unknown,
  COUNTIF((SELECT value.int_value FROM UNNEST(event_params)
           WHERE key = 'ga_session_id') IS NULL)                   AS events_without_session_id,
  COUNTIF(event_name = 'purchase')                                 AS purchase_events,
  COUNTIF(event_name = 'purchase'
          AND ecommerce.purchase_revenue_in_usd IS NULL)           AS purchases_without_revenue,
  COUNTIF(event_name = 'purchase'
          AND ecommerce.transaction_id = '(not set)')              AS purchases_without_txn_id,
  COUNT(DISTINCT IF(event_name = 'purchase',
                    ecommerce.transaction_id, NULL))               AS distinct_transactions
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
