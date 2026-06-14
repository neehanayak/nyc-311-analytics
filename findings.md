# NYC 311 Analytics — Findings

## Borough Resolution Times

| Borough | Avg Resolution Days | SLA Breach % |
|---|---|---|
| Manhattan | 129.6 | 13.0% |
| Brooklyn | 57.9 | 13.9% |
| Unspecified | 57.2 | 22.5% |
| Queens | 19.7 | 7.3% |
| Staten Island | 14.1 | 7.2% |
| Bronx | 8.0 | 5.2% |

## Top Complaint Types

| Complaint Type | Total Complaints | Avg Resolution Days |
|---|---|---|
| Illegal Parking | 709,032 | 0.2 |
| Noise - Residential | 640,032 | 0.3 |
| HEAT/HOT WATER | 345,738 | 1.9 |

## Data Quality Issues Found

- **5,684 null boroughs** — complaints spanning multiple boroughs or citywide; handled with `severity: warn` in schema.yml
- **4 corrupted timestamps** — malformed values like `04/28/2020 03:45:00 P{`; fixed by switching to `TRY_TO_TIMESTAMP` in stg_complaints.sql
- **5 null agency names** — source records missing agency; handled with `severity: warn` in schema.yml
- **Undocumented status values** — `Assigned`, `Started`, `Unspecified` were absent from the original accepted_values list; added to schema.yml
