{{ config(materialized='table') }}

with complaints as (

    select * from {{ ref('stg_complaints') }}
    where created_at is not null

),

final as (

    select
        unique_key,
        created_at,
        closed_at,
        agency,
        agency_name,
        complaint_type,
        descriptor,
        location_type,
        incident_zip,
        borough,
        latitude,
        longitude,
        status,

        DATEDIFF('day', created_at, closed_at)              as resolution_days,
        DATEDIFF('day', created_at, closed_at) > 30         as sla_breached,
        closed_at is null                                    as is_open

    from complaints

)

select * from final
