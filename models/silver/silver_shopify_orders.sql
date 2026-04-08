{{
  config(
    materialized = 'incremental',
    unique_key = 'ORDER_ID'
    )
}}

select
    ORDER_ID,
    DATE AS ORDER_DATE,
    CASE
        WHEN SESSION_ID = '-' OR SESSION_ID IS NULL THEN 'MISSING_SESSION'
        ELSE SESSION_ID
    END AS SESSION_ID,
    TOTAL_REVENUE,
    CASE
       WHEN SESSION_ID = '-' OR SESSION_ID IS NULL THEN'Unattributed'
       ELSE 'Attributed' 
    END AS ATTRIBUTION_STATUS
   
from
   {{ ref('bronze_shopify_orders') }} 
    
    WHERE TOTAL_REVENUE > 0


{% if is_incremental() %}
  AND DATE >= coalesce((select max(ORDER_DATE) from {{ this }}), '1900-01-01')

{% endif %} 

