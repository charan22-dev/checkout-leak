-- One row per session with funnel flags. A session that reached a later step counts as having passed all earlier steps.
with events as (
  select * from {{ ref('stg_events') }}
),

sessions as (
  select
    session_key,
    max(user_pseudo_id)                                     as user_pseudo_id,
    min(event_date)                                         as session_date,
    min(event_ts)                                           as session_start_ts,
    max(session_number)                                     as session_number,
    max(device_category)                                    as device_category,
    max(country)                                            as country,
    max(traffic_medium)                                     as first_user_medium,  -- GA4 export stores first-touch (user-level) source
    logical_or(event_name = 'view_item')                    as has_view_item,
    logical_or(event_name = 'add_to_cart')                  as has_add_to_cart,
    logical_or(event_name = 'begin_checkout')               as has_begin_checkout,
    logical_or(event_name = 'add_shipping_info')            as has_add_shipping_info,
    logical_or(event_name = 'add_payment_info')             as has_add_payment_info,
    logical_or(event_name = 'purchase')                     as has_purchase,
    countif(event_name = 'purchase')                        as purchase_events,
    coalesce(sum(if(event_name = 'purchase', purchase_revenue_usd, null)), 0) as revenue_usd
  from events
  group by session_key
)

select
  *,
  session_number = 1                                                                      as is_first_session,
  has_purchase                                                                            as reached_purchase,
  has_purchase or has_add_payment_info                                                    as reached_payment,
  has_purchase or has_add_payment_info or has_add_shipping_info                           as reached_shipping,
  has_purchase or has_add_payment_info or has_add_shipping_info or has_begin_checkout     as reached_checkout,
  has_purchase or has_add_payment_info or has_add_shipping_info or has_begin_checkout
    or has_add_to_cart                                                                    as reached_cart,
  has_purchase or has_add_payment_info or has_add_shipping_info or has_begin_checkout
    or has_add_to_cart or has_view_item                                                   as reached_view,
  has_purchase and not has_begin_checkout                                                 as purchase_skipped_checkout_event
from sessions
