# DATA DICTIONARY: UNIFIED MIGRATION MODEL

## Overview

This document provides the technical specifications and business descriptions for the finalized data tables within the Snowflake data warehouse. It outlines the schema mapping from the legacy source to the optimized cloud destination.

## DIM_PATIENTS

**Description:** Final business-ready dimension table. This table utilizes SCD Type 2 logic to maintain a full historical audit trail of patient attribute changes over time.

| Column | Data Type | Description |
|--------|-----------|-------------|
| PATIENT_KEY | VARCHAR | Primary Key. Unique surrogate key generated via HASH logic. |
| PATIENT_ID | INTEGER | Natural key migrated from the legacy PostgreSQL RDBMS. |
| FULL_NAME | VARCHAR | The patient's legal name, standardized and trimmed. |
| EMAIL | VARCHAR | Primary contact email address, converted to lowercase for consistency. |
| INSURANCE_PLAN | VARCHAR | Standardized insurance category (PLAN A, B, C, or UNKNOWN). |
| PATIENT_AGE | INTEGER | Derived attribute calculating age based on birth_date. |
| VALID_FROM | TIMESTAMP | The date and time when this specific version of the record became active. |
| VALID_TO | TIMESTAMP | The date and time when this record was superseded (NULL if current). |

## DIM_DOCTORS

**Description:** Dimension table containing standardized provider information to enable performance analysis and workload tracking by specialty.

| Column | Data Type | Description |
|--------|-----------|-------------|
| DOCTOR_KEY | VARCHAR | Primary Key. Unique surrogate key for medical providers. |
| DOCTOR_ID | INTEGER | Natural key migrated from the legacy PostgreSQL RDBMS. |
| DOCTOR_NAME | VARCHAR | The doctor's legal name, standardized and trimmed. |
| SPECIALIZATION | VARCHAR | The medical specialty of the doctor. |
| SENIORITY_LEVEL | VARCHAR | The level of experience or rank of the doctor. |

## DIM_FACILITIES

**Description:** Dimension table containing standardized facility information to enable location-based performance analysis and resource allocation.

| Column | Data Type | Description |
|--------|-----------|-------------|
| FACILITY_KEY | VARCHAR | Primary Key. Unique surrogate key for facilities. |
| FACILITY_ID | INTEGER | Natural key migrated from the legacy PostgreSQL RDBMS. |
| FACILITY_NAME | VARCHAR | The facility's legal name, standardized and trimmed. |
| LOCATION_NAME | VARCHAR | Location of the facility. |
| FACILITY_TYPE | VARCHAR | The type of facility (e.g., Hospital, Clinic, Urgent Care). |

## FCT_ENCOUNTERS

**Description:** Fact table containing standardized encounter information, with calculated measures for financial analysis and patient cost tracking. This table is designed to support high-performance analytical queries while maintaining referential integrity with the dimension tables.

| Column | Data Type | Description |
|--------|-----------|-------------|
| ENCOUNTER_KEY | VARCHAR | Primary Key. Unique surrogate key for encounters. |
| PATIENT_KEY | VARCHAR | Foreign Key referencing the patient dimension table. |
| DOCTOR_KEY | VARCHAR | Foreign Key referencing the doctor dimension table. |
| FACILITY_KEY | VARCHAR | Foreign Key referencing the facility dimension table. |
| TOTAL_COST | DECIMAL(10, 2) | The total costs associated with the encounter. |
| INSURANCE_COVERED | INTEGER | Insurance covered amount. |
| OUT_OF_POCKET_COST | DECIMAL(10, 2) | The amount the patient is responsible for paying. |
| ENCOUNTER_DATE | DATE | The date of the encounter. |
| ENCOUNTER_YEAR | DATE | The year of the encounter. |
| ENCOUNTER_MONTH | DATE | The month of the encounter. |

## Implementation Notes

- **Null Handling:** Fields that were empty in the legacy system have been converted to 'N/A' or appropriate defaults to ensure join integrity in BI tools.
- **Case Sensitivity:** All table and column names in the Gold layer follow Snowflake's standard uppercase convention to simplify SQL writing for analysts.
- **History Tracking:** Historical changes are captured via dbt snapshots based on the `updated_at` timestamp from the source system.
