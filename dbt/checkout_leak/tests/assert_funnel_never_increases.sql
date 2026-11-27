-- A funnel step can never have more sessions than the step before it.
select * from {{ ref('mart_funnel_daily') }}
where view_item_sessions      > sessions
   or add_to_cart_sessions    > view_item_sessions
   or begin_checkout_sessions > add_to_cart_sessions
   or add_shipping_sessions   > begin_checkout_sessions
   or add_payment_sessions    > add_shipping_sessions
   or purchase_sessions       > add_payment_sessions
