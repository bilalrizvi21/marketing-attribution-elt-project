{{
  config(
    materialized = 'incremental',
    unique_key = 'SESSION_ID'
    )
}}

SELECT
    TRIM(SESSION_ID) AS SESSION_ID, -- THE FIX: Removes hidden spaces
    DATE AS EVENT_DATE,
    {{ map_utm_source('UTM_SOURCE') }} AS UTM_SOURCE,
    UTM_CAMPAIGN_ID,
    CASE 
        WHEN UTM_CAMPAIGN_ID IS NULL OR UTM_CAMPAIGN_ID = 'none' THEN 'Organic'
        ELSE 'Paid' 
    END AS TRAFFIC_TYPE
FROM {{ ref('bronze_web_events') }}

WHERE SESSION_ID IS NOT NULL 

{% if is_incremental() %}
  AND DATE >= coalesce((select max(EVENT_DATE) from {{ this }}), '1900-01-01')
{% endif %} 


QUALIFY ROW_NUMBER() OVER (PARTITION BY TRIM(SESSION_ID) ORDER BY EVENT_DATE ASC) = 1