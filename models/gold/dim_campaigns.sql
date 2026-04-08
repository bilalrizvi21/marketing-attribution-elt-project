with all_campaign_sources as 
(
    SELECT DISTINCT 
        UTM_CAMPAIGN_ID AS CAMPAIGN_ID, 
        UTM_SOURCE AS PLATFORM 
    FROM {{ ref('silver_web_events') }}
    
    UNION -- Using UNION (not ALL) removes duplicates between the two sources

    SELECT DISTINCT 
        CAMPAIGN_ID, 
        PLATFORM 
    FROM {{ ref('silver_ad_spend') }}

    UNION

    -- MANUALLY ADD THE "IDENTITY" ROWS
    SELECT 'none' AS CAMPAIGN_ID, 'organic' AS PLATFORM
    UNION
    SELECT 'UNATTRIBUTED' AS CAMPAIGN_ID, 'organic' AS PLATFORM
)

  SELECT
      CAMPAIGN_ID,
      PLATFORM,
      -- Fixing the PLATFORM_NAME logic for these special cases
      CASE 
          WHEN CAMPAIGN_ID = 'none' THEN 'Organic Search'
          WHEN CAMPAIGN_ID = 'UNATTRIBUTED' THEN 'Unattributed Orders'
          ELSE LOWER(INITCAP(PLATFORM)) 
      END AS PLATFORM_NAME,
      CASE 
          WHEN LOWER(PLATFORM) IN ('facebook', 'instagram', 'tiktok') THEN 'Social'
          WHEN LOWER(PLATFORM) IN ('google', 'bing') THEN 'Search'
          WHEN CAMPAIGN_ID = 'none' THEN 'Organic'
          WHEN CAMPAIGN_ID = 'UNATTRIBUTED' THEN 'Direct/Unknown'
          ELSE 'Other'
      END AS CHANNEL_GROUP
  FROM
  all_campaign_sources
  WHERE CAMPAIGN_ID IS NOT NULL