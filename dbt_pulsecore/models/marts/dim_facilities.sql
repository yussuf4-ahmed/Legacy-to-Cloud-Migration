{{ config(materialized='view') }}

with staging as (
    select * from {{ ref('stg_facilities') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['facility_id']) }} as facility_key,
    facility_id,
    facility_name,
    location_name,
    facility_type
from staging
