-- Every session in stg_events must appear exactly once in the mart totals.
with stg  as (select count(distinct session_key) as n from {{ ref('stg_events') }}),
     mart as (select sum(sessions) as n from {{ ref('mart_funnel_daily') }})
select * from stg, mart where stg.n != mart.n
