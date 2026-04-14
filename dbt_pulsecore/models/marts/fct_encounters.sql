{{ config(materialized='view') }}

with staging as (
    select * from {{ ref('stg_encounters') }}
)

select
    -- Unique ID for this specific row
    {{ dbt_utils.generate_surrogate_key(['encounter_id']) }} as encounter_key,
    
    -- Foreign Keys (Linking to our Dimensions)
    {{ dbt_utils.generate_surrogate_key(['patient_id']) }} as patient_key,
    {{ dbt_utils.generate_surrogate_key(['doctor_id']) }} as doctor_key,
    {{ dbt_utils.generate_surrogate_key(['facility_id']) }} as facility_key,
    
    -- Measures (The numbers we want to sum/average)
    total_cost,
    insurance_covered,
    out_of_pocket_cost,
    
    -- Dates (Context)
    encounter_date,
    encounter_year,
    encounter_month
from staging
