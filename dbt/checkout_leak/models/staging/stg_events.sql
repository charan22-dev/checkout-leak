-- One row per GA4 event, flattened, with duplicate purchase events removed.
with src as (
  select
    parse_date('%Y%m%d', event_date)                                                   as event_date,
    timestamp_micros(event_timestamp)                                                  as event_ts,
    event_name,
    user_pseudo_id,
    (select value.int_value    from unnest(event_params) where key = 'ga_session_id')     as ga_session_id,
    (select value.int_value    from unnest(event_params) where key = 'ga_session_number') as session_number,
    (select value.string_value from unnest(event_params) where key = 'page_location')     as page_location,
    device.category                                                                    as device_category,
    geo.country                                                                        as country,
    traffic_source.medium                                                              as traffic_medium,
    traffic_source.source                                                              as traffic_source,
    ecommerce.transaction_id                                                           as transaction_id,
    ecommerce.purchase_revenue_in_usd                                                  as purchase_revenue_usd
  from {{ source('ga4', 'events') }}
),

flagged as (
  select
    *,
    concat(user_pseudo_id, '-', cast(ga_session_id as string))                        as session_key,
    event_name = 'purchase' and coalesce(transaction_id, '(not set)') != '(not set)'  as is_identified_purchase
  from src
),

-- Keep only the first event for each transaction_id (removes 335 duplicates found in profiling)
deduped_purchases as (
  select * from flagged
  where is_identified_purchase
  qualify row_number() over (partition by transaction_id order by event_ts) = 1
)

select * from flagged where not is_identified_purchase
union all
select * from deduped_purchases
