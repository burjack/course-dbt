{{
  config(
    post_hook = 'grant select on {{ this }} to role REPORTING'
  )
}}

with fact_sessions_counts as (
select 
    session_id
    {{ event_types('stg_postgres__events', 'event_type') }}
from {{ ref("stg_postgres__events") }}
group by all
)

select *
from fact_sessions_counts