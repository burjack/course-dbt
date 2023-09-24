{{
  config(
    materialized='table'
  )
}}

SELECT product_id
  , product_name
  , COUNT(PRODUCT_NAME) AS view_count
  , SUM(ADDED_TO_CART_DURING_SESSION) AS added_to_cart
  , AVG(session_time_min) AS avg_session_min
FROM {{ ref("fact_page_views") }}
GROUP BY product_id, product_name
