with source as (
    -- Reference the raw facilities table in Bronze
    select * from {{ source('bronze', 'facilities') }}
),

renamed as (
    select
        -- 1. Primary Key
        facility_id,

        -- 2. Facility Details
        trim(facility_name) as facility_name,
        trim(location) as location_name,

        -- 3. Categorization: Standardizing 'Hospital' vs 'Clinic'
        upper(type) as facility_type,

        -- 4. Audit Metadata
        cast(extracted_at_timestamp as timestamp) as ingestion_timestamp

    from source
)

select * from renamed
