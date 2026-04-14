with source as (
    select * from {{ ref('snsh_patients') }}
    where dbt_valid_to is null  -- This ensures you only pull the CURRENT active version
),

renamed as (
    select
        -- 1. Primary Key
        patient_id,

        -- 2. Demographics & Cleaning
        coalesce(
            trim(full_name), 
            trim(concat(coalesce(first_name, ''), ' ', coalesce(last_name, '')))
        ) as patient_name,

        upper(coalesce(gender, 'UNKNOWN')) as gender,
        cast(date_of_birth as date) as birth_date,
        
        -- Calculated Field: Age (Great for Healthcare Analytics)
        datediff('year', cast(date_of_birth as date), current_date()) as patient_age,

        -- 3. Registration Logic (Changed from created_at to created_date)
        cast(created_date as date) as registration_date,
        year(cast(created_date as date)) as registration_year,
        monthname(cast(created_date as date)) as registration_month,
        -- 4. Final Robust Insurance Standardization
        case 
            when upper(insurance) LIKE '% A' 
              or upper(insurance) LIKE '%_A' 
              or upper(insurance) = 'A' then 'PLAN A'
            
            when upper(insurance) LIKE '% B' 
              or upper(insurance) LIKE '%_B' 
              or upper(insurance) = 'B' then 'PLAN B'
            
            when upper(insurance) LIKE '% C' 
              or upper(insurance) LIKE '%_C' 
              or upper(insurance) = 'C' then 'PLAN C'
            
            else 'UNKNOWN'
        end as insurance_plan,

        -- 5. Audit Metadata
        cast(extracted_at_timestamp as timestamp) as ingestion_timestamp

    from source
)

select * from renamed
