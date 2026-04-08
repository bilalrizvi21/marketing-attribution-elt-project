select
  CAMPAIGN_ID,
  DATE,
  {{ standardize_text('CAMPAIGN_NAME') }} AS CAMPAIGN_NAME,
  {{ map_utm_source('PLATFORM') }} AS PLATFORM,
  SPEND,
  CLICKS,
  ROUND( (SPEND / NULLIF(CLICKS, 0)), 2) AS COST_PER_CLICK

from
  {{ ref('bronze_ad_spend') }}