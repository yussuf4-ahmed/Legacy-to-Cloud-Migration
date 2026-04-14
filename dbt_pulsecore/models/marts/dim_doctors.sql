{{ config(materialized='view') }}

with staging as (
    select * from {{ ref('stg_doctors') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['doctor_id']) }} as doctor_key,
    doctor_id,
    doctor_name,
    specialization,
    seniority_level
from staging
