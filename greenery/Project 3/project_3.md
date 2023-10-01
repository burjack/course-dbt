# Week 3 Project:

## Part 1:

 - **Question 1:** 
   What is our overall conversion rate?

    **Answer :**
    The overall conversion rate in Greenery is 62.5%

    **Query :**  
    ```sql  
    select round(sum(checkout)/count(session_id)*100, 1) as conversion_rate
    from DEV_DB.DBT_BURJACK86GMAILCOM.FACT_SESSIONS_COUNT
    ```

 - **Question 2:** 
    What is our conversion rate by product?
    
    **Answer :**  
    Table with conversion rate by product:


   |NAME|CONVERSION_RATE (%)|
   |:---|:---:|
   |String of pearls|60.9|
   |Arrow Head|55.6|
   |Cactus|54.5|
   |ZZ Plant|54.0|
   |Bamboo|53.7|
   |Rubber Plant|51.9|
   |Monstera|51.0|
   |Calathea Makoyana|50.9|
   |Fiddle Leaf Fig|50.0|
   |Majesty Palm|49.3|
   |Aloe Vera|49.2|
   |Devil's Ivy|48.9|
   |Philodendron|48.4|
   |Jade Plant|47.8|
   |Spider Plant|47.5|
   |Pilea Peperomioides|47.5|
   |Dragon Tree|46.8|
   |Money Tree|46.4|
   |Orchid|45.3|
   |Bird of Paradise|45.0|
   |Ficus|42.6|
   |Birds Nest Fern|42.3|
   |Pink Anthurium|41.9|
   |Boston Fern|41.3|
   |Alocasia Polly|41.2|
   |Peace Lily|40.9|
   |Ponytail Palm|40.0|
   |Snake Plant|39.7|
   |Angel Wings Begonia|39.3|
   |Pothos|34.4|


**Query :**  
```sql
with session_x_product_view as (

select events.session_id, events.product_id, products.name
from DEV_DB.DBT_BURJACK86GMAILCOM.STG_POSTGRES__EVENTS as events
left join DEV_DB.DBT_BURJACK86GMAILCOM.STG_POSTGRES__PRODUCTS as products on  events.product_id = products.product_id
where events.event_type = 'page_view'
group by events.session_id, events.product_id, products.name
)

, session_order_product as (
select events.session_id, events.order_id, items.product_id
from DEV_DB.DBT_BURJACK86GMAILCOM.STG_POSTGRES__EVENTS as events 
left join DEV_DB.DBT_BURJACK86GMAILCOM.STG_POSTGRES__ORDER_ITEMS as items on items.order_id = events.order_id
where events.order_id is not null
group by all

)

, sessions_prod as (
    select sessions_count.*, session_x_product_view.product_id, session_x_product_view.name 
    from DEV_DB.DBT_BURJACK86GMAILCOM.FACT_SESSIONS_COUNT as sessions_count
    left join session_x_product_view on sessions_count.session_id = session_x_product_view.session_id
)

, sessions_prod_coount as (
select sessions_prod.*, 
case when session_order_product.order_id is not null then 1 else 0 end as checkout_prod,
session_order_product.order_id
from sessions_prod 
left join session_order_product on sessions_prod.session_id = session_order_product.session_id
    and sessions_prod.product_id = session_order_product.product_id 
where 1=1
)

select name, round(sum(checkout_prod)/count(session_id)*100,1) as conversion_rate
from sessions_prod_coount
group by product_id, name
order by conversion_rate desc 
```

## Part 6:

 - **Question 1**: Which products had their inventory change from week 1 to week 2? 
    
    **Answer :**
    On the table below you can the products how much their inventory has changed from week 2 to week 3. In addition, the current inventory (INVENTORY) and how much it changed (INV_CHANGE) are also available.

   |NAME|INVENTORY|INV_CHANGE|
   |:----|:----:|:----:|
   |Pothos|0|-20|
   |Philodendron|15|-10|
   |Bamboo|44|-12|
   |ZZ Plant|53|-36|
   |Monstera|50|-14|
   |String of pearls|0|-10|



    **Query :**  
    ```sql  
    WITH change AS (
        SELECT *
        , inventory - lag(inventory) OVER(PARTITION BY PRODUCT_ID ORDER BY DBT_UPDATED_AT) AS inv_change
        , CASE WHEN ROW_NUMBER() OVER(PARTITION BY PRODUCT_ID ORDER BY DBT_UPDATED_AT DESC) = 1 THEN 1
        ELSE 0 END AS is_current
        FROM DEV_DB.DBT_BURJACK86GMAILCOM.INVENTORY_SNAPSHOT
        ORDER BY product_id, DBT_UPDATED_AT
    )

    SELECT name, inventory, INV_CHANGE
    FROM change
    WHERE 1=1
    AND is_current = 1
    AND INV_CHANGE IS NOT NULL
    AND INV_CHANGE <> 0
    ORDER BY product_id, DBT_UPDATED_AT
    ```