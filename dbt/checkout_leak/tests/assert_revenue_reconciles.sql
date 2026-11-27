-- Revenue in the mart must equal purchase revenue in stg_events, to the cent.
with stg  as (select coalesce(sum(purchase_revenue_usd), 0) as r from {{ ref('stg_events') }} where event_name = 'purchase'),
     mart as (select sum(revenue_usd) as r from {{ ref('mart_funnel_daily') }})
select * from stg, mart where abs(stg.r - mart.r) > 0.01
