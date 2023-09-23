# Week 2 Project:


## Part 1:

 - **Question 1**: What is our user repeat rate? Repeat Rate = Users who purchased 2 or more times / users who purchased.
 
    **Answer :**
    Among all orders placed up to the moment the repeat rate is 76.1%

**Query :**  
```sql  
    SELECT AVG(CASE WHEN count_orders >= 2 THEN 1 ELSE 0 END) AS rate_return 
    FROM DEV_DB.DBT_BURJACK86GMAILCOM.FACT_USERS_ORDERS
```
  
 - **Question 2:** 
    What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?
    
    **Answer :**  
    I believe that users' first review of the product and time to delivery the product the could help to answer those questions. I would add users' first review since it is not available.
    
 - **Question 3:** Why did you organize the models in the way you did?
    
    **Answer :**  
    The models were organized in a way that users could readily identify the purpose of the table and also to separate models according to the company's busiess model organization (tihe different folders in marts).



## Part 2:

 - **Question 1**: What assumptions are you making about each model? (i.e. why are you adding each test?)
    
    **Answer :**
    In every table that has a unique primary key I made tests for uniqueness and not_null. These tests are important to guarantee consistency, for example, make sure that clients or orders are not duplicated in the platform.

## Part 3:

 - **Question 2**: Which products had their inventory change from week 1 to week 2? 
    
    **Answer :**
    On the table below you can the products that had their inventory changed. In addition, the current inventory (INVENTORY) and how much it changed (INV_CHANGE) are also available.

    |NAME               | INVENTORY  | INV_CHANGE |
    |-------------------|------------|------------|
    |Pothos             |   20       |  -20       |
    |Philodendron       |   25       |  -26       |
    |Monstera           |   64       |  -13       |
    |String of pearls   |   10       |  -48       |


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

