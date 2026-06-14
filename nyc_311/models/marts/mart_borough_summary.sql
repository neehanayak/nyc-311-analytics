{{ config(materialized='table') }}

with complaints as (

    select * from {{ ref('fct_complaints') }}
    where borough is not null

),

summary as (

    select
        borough,
        DATE_TRUNC('month', created_at)                             as month,
        COUNT(*)                                                    as total_complaints,
        AVG(resolution_days)                                        as avg_resolution_days,
        SUM(CASE WHEN sla_breached THEN 1 ELSE 0 END)              as total_sla_breaches,
        ROUND(
            SUM(CASE WHEN sla_breached THEN 1 ELSE 0 END)
            / NULLIF(COUNT(*), 0) * 100,
            2
        )                                                           as sla_breach_pct

    from complaints
    group by 1, 2
    order by borough, month

)

select * from summary
