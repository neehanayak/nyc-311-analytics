with source as (

    select * from {{ source('raw', 'stg_311_raw') }}

),

renamed as (

    select
        UNIQUE_KEY                                                                         as unique_key,

        -- Cast date strings to timestamps.
        -- CREATED_DATE is always populated; CLOSED_DATE is nullable so we
        -- coerce empty strings to NULL before casting to avoid a type error.
        TRY_TO_TIMESTAMP(CREATED_DATE, 'MM/DD/YYYY HH12:MI:SS AM')                        as created_at,
        TRY_TO_TIMESTAMP(NULLIF(CLOSED_DATE, ''), 'MM/DD/YYYY HH12:MI:SS AM')             as closed_at,

        AGENCY                                                                             as agency,
        AGENCY_NAME                                                                        as agency_name,

        -- Column names with parentheses must be double-quoted to be valid SQL identifiers
        "PROBLEM_(FORMERLY_COMPLAINT_TYPE)"                                                as complaint_type,
        "PROBLEM_DETAIL_(FORMERLY_DESCRIPTOR)"                                             as descriptor,

        LOCATION_TYPE                                                                      as location_type,
        INCIDENT_ZIP                                                                       as incident_zip,
        BOROUGH                                                                            as borough,

        -- Coordinates arrive as strings; rows with no location have empty
        -- strings rather than NULLs, so TRY_TO_DOUBLE returns NULL safely.
        TRY_TO_DOUBLE(LATITUDE)                                                            as latitude,
        TRY_TO_DOUBLE(LONGITUDE)                                                           as longitude,

        STATUS                                                                             as status

    from source

)

select * from renamed
