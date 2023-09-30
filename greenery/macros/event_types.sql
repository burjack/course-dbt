{%- macro event_types(table_name, column_name) -%}

{%-
set event_types = dbt_utils.get_column_values(
    table = ref(table_name)
    , column = column_name
)
-%}

{%- for event_type in event_types %}
, count(event_type = '{{ event_type}}' ) then
{%- endfor %}

{%- endmacro %}