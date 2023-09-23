{{
  config(
    materialized='table'
  )
}}

SELECT 
    orders.user_id
    , items.product_id
    , sum(items.quantity) AS qty_purchased
FROM {{ ref("stg_postgres__orders") }} AS orders
LEFT JOIN {{ ref("stg_postgres__order_items") }} AS items ON (items.order_id = orders.order_id)
GROUP BY ALL