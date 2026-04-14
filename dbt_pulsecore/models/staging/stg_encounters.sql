with source as (
    select * from {{ source('bronze', 'encounters') }}
),

renamed as (
    select
        -- 1. Primary & Foreign Keys
        encounter_id,
        patient_id,
        doctor_id,
        facility_id,

        -- 2. Date Standardization: Handling the 3 different formats in your CSV
        coalesce(
            try_to_date(encounter_date, 'YYYY-MM-DD'),
            try_to_date(encounter_date, 'MM/DD/YYYY'),
            try_to_date(encounter_date, 'DD-MM-YYYY')
        ) as encounter_date,

        -- 3. Clinical Codes: Standardizing to uppercase
        upper(diagnosis_code) as diagnosis_code,
        upper(procedure_code) as procedure_code,

        -- 4. Financial Normalization: Filling the 50% missing costs
        -- We coalesce to 0 so calculations don't break, 
        -- but we'll flag these in the final dashboard.
        coalesce(total_cost, 0) as total_cost,
        coalesce(insurance_covered, 0) as insurance_covered,

        -- 5. Calculated Field: Simple derived metric
        (coalesce(total_cost, 0) - coalesce(insurance_covered, 0)) as out_of_pocket_cost,

        -- 6. Time Context
        year as encounter_year,
        month as encounter_month,
        cast(extracted_at_timestamp as timestamp) as ingestion_timestamp

    from source
)

select * from renamed
