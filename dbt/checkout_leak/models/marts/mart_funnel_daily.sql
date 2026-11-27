-- Sessions reaching each funnel step, by day, device, first-touch medium and new vs returning.
select
  session_date,
  device_category,
  first_user_medium,
  is_first_session,
  count(*)                     as sessions,
  countif(reached_view)        as view_item_sessions,
  countif(reached_cart)        as add_to_cart_sessions,
  countif(reached_checkout)    as begin_checkout_sessions,
  countif(reached_shipping)    as add_shipping_sessions,
  countif(reached_payment)     as add_payment_sessions,
  countif(reached_purchase)    as purchase_sessions,
  sum(revenue_usd)             as revenue_usd
from {{ ref('int_sessions') }}
group by 1, 2, 3, 4
