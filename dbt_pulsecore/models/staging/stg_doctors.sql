with source as (
    select * from {{ source('bronze', 'doctors') }}
),

renamed as (
    select
        -- 1. Primary Key
        doctor_id,

        -- 2. Name & Specialty
        trim(doctor_name) as doctor_name,
        upper(specialization) as specialization,

        -- 3. Experience Metrics
        experience_years,

        -- 4. Derived Logic: Categorizing Doctors by Seniority
        case 
            when experience_years < 5 then 'JUNIOR'
            when experience_years between 5 and 15 then 'INTERMEDIATE'
            when experience_years > 15 then 'SENIOR'
            else 'UNKNOWN'
        end as seniority_level,

        -- 5. Audit Metadata
        cast(extracted_at_timestamp as timestamp) as ingestion_timestamp

    from source
)

select * from renamed
