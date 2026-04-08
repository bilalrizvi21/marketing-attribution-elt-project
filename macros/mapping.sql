{% macro map_utm_source(column_name) %}
    CASE 
        WHEN {{ column_name }} IN ('fb', 'facebook') THEN 'facebook'
        WHEN {{ column_name }} IN ('instagram', 'ig') THEN 'instagram'
        WHEN {{ column_name }} IN ('google', 'goog', 'g-ads', 'sem') THEN 'google'
        WHEN {{ column_name }} IN ('tiktok', 'tt') THEN 'tiktok'
        WHEN {{ column_name }} IS NULL OR {{ column_name }} = 'organic' THEN 'organic'
        ELSE 'other'
    END
{% endmacro %}