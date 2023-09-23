{{
  config(
    materialized='table'
  )
}}

WITH
    page_views AS (
        SELECT event_id, session_id, user_id, created_at, product_id
        FROM {{ ref("stg_postgres__events") }}
        WHERE event_type = 'page_view'
    ),

    products AS (
        SELECT product_id
                , name AS product_name
        FROM {{ ref("stg_postgres__products") }}
    ),

    products_added_to_cart_during_session AS (
        SELECT DISTINCT session_id, product_id
        FROM {{ ref("stg_postgres__events") }}
        WHERE event_type = 'add_to_cart'
    ),

    session_time AS (
        SELECT session_id
        , MIN(created_at) AS seesion_start_time
        , MAX(created_at) AS seesion_end_time
        , DATEDIFF(second, MIN(created_at), MAX(created_at))/60 AS session_time_min
        FROM {{ ref("stg_postgres__events") }}
        GROUP BY session_id
        ORDER BY session_time_min
    ),

    quantities_purchased_by_user AS (
        SELECT user_id, product_id, qty_purchased
        FROM {{ ref("users_products_qty") }}
    )

SELECT
    page_views.event_id
    , page_views.session_id
    , page_views.user_id
    , page_views.created_at
    , page_views.product_id
    , products.product_name
    , CASE WHEN products_added_to_cart_during_session.product_id IS NOT NULL THEN 1 ELSE 0
        END AS added_to_cart_during_session
    , quantities_purchased_by_user.qty_purchased
    , session_time.session_time_min
FROM page_views
LEFT JOIN products USING (product_id)
LEFT JOIN products_added_to_cart_during_session USING (session_id, product_id)
LEFT JOIN session_time USING (session_id)
LEFT JOIN quantities_purchased_by_user USING (user_id, product_id)