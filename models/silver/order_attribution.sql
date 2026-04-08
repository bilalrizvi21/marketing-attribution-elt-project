{{
  config(
    materialized = 'incremental',
    unique_key = 'ORDER_ID'
    )
}}

WITH raw_orders AS (
    SELECT * FROM {{ ref('bronze_shopify_orders') }}
),

web_sessions AS (
    SELECT * FROM {{ ref('silver_web_events') }}
)

SELECT
    o.ORDER_ID,
    o.DATE,
    o.TOTAL_REVENUE,
    COALESCE(s.SESSION_ID, 'MISSING_SESSION') AS SESSION_ID,
    COALESCE(s.UTM_CAMPAIGN_ID, 'UNATTRIBUTED') AS CAMPAIGN_ID,
    COALESCE(s.UTM_SOURCE, 'organic') AS PLATFORM
FROM raw_orders o
LEFT JOIN web_sessions s 
    ON o.SESSION_ID = s.SESSION_ID


QUALIFY ROW_NUMBER() OVER (
    PARTITION BY o.ORDER_ID 
    ORDER BY o.DATE DESC
) = 1

{% if is_incremental() %}
  AND o.DATE >= (SELECT MAX(DATE) FROM {{ this }})
{% endif %}