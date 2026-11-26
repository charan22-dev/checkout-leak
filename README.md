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

## Validation log
| Check | Expected | Result |
|---|---|---|
| Raw events on 2021-01-31 | 26,489 | ✅ matches raw table |

## Status
🚧 In progress: Day 1 (setup + problem statement)
