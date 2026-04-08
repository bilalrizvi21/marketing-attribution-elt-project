{% macro standardize_text(column_name) %}
    TRIM(LOWER({{ column_name }}))
{% endmacro %}