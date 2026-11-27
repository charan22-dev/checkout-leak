# Checkout Leak Finder

**Business question:** Which step of the purchase funnel loses the most revenue, for which users, and what is fixing it worth per quarter?

**Decision it informs:** Which single checkout fix the Head of E-commerce should test next sprint.

**Data source:** Google Analytics 4 raw event export for the Google Merchandise Store (`bigquery-public-data.ga4_obfuscated_sample_ecommerce`, 1 Nov 2020 – 31 Jan 2021).

**Success metric:** Checkout-to-purchase conversion rate, measured per session.

## Metric definitions
- **Session:** `user_pseudo_id` + `ga_session_id`.
- **Funnel steps (per session, in order):** `view_item` → `add_to_cart` → `begin_checkout` → `add_shipping_info` → `add_payment_info` → `purchase`.
- **Step conversion:** sessions reaching step N ÷ sessions reaching step N−1.
- **Revenue:** sum of `ecommerce.purchase_revenue_in_usd` on `purchase` events.

## Data limits
The dataset is obfuscated by Google: some values are replaced with placeholders such as `<Other>`, so absolute numbers are indicative. The method transfers directly to any company using GA4, including Indian D2C and e-commerce brands.

## Data quality findings (profiling, Day 1)
Source queries and outputs: `sql/00_profiling/`

| Finding | Size | How I handle it |
|---|---|---|
| Duplicate purchase events (same `transaction_id` logged more than once) | 326 orders, 335 extra events, **$22,148 revenue double-counted** | Deduplicate to one row per `transaction_id` in the dbt model |
| Purchases with `transaction_id = '(not set)'` | 883 of 5,692 purchase events (15.5%) | Keep (revenue is present) but they can't be deduplicated; flagged |
| Traffic medium hidden (`<Other>` / `(data deleted)`) | 911,399 events (21.2%) | Channel splits are indicative only; device is the primary segment |
| Country unknown | 32,208 events (0.75%) | Minor; reported as "Unknown" |
| `add_shipping_info` reached by 9,714 of 9,715 checkout users | 99.99% pass-through | Likely auto-fired, so not treated as a real drop-off step |
| Device category and `ga_session_id` missing | 0 events | No action; session model is safe |

## Validation log
| Check | Expected | Result |
|---|---|---|
| Raw events on 2021-01-31 | 26,489 | ✅ matches raw table |
| Date range vs Google docs | 1 Nov 2020 – 31 Jan 2021, 92 days | ✅ 92 days |
| Total events / users | ~4.3M (Google docs) | ✅ 4,295,584 events, 270,154 users |
| `stg_events` rows = raw − duplicate purchases | 4,295,584 − 335 = 4,295,249 | ✅ dbt test passes |
| One row per order in `stg_events` | 0 duplicate `transaction_id` | ✅ dbt `unique` test passes |

## Status
🚧 In progress: Day 1 done (setup, problem statement, profiling). Day 2: dbt staging model built and tested. Next: session model + funnel mart
