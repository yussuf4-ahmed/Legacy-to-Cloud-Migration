{{ config(materialized='view') }}

with staging as (
    select * from {{ ref('stg_patients') }}
)

select
    -- 1. Surrogate Key (The "Gold" Standard for Joins)
    {{ dbt_utils.generate_surrogate_key(['patient_id']) }} as patient_key,

    -- 2. Natural Keys & IDs
    patient_id,

    -- 3. Patient Details
    patient_name,
    gender,
    birth_date,
    patient_age,

    -- 4. Registration Details (New Portfolio-Ready Columns)
    registration_date,
    registration_year,
    registration_month,

    -- 5. Insurance Information
    insurance_plan

from staging
