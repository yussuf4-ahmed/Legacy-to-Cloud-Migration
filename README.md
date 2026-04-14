# Legacy to Cloud Migration Case Study

## The Business Challenge

The PulseCore healthcare network was struggling with a legacy PostgreSQL database that had become a "data silo." Business analysts could not perform cross-facility reporting, and historical changes (such as patient insurance updates) were being overwritten, leading to inaccurate financial auditing.

**Key Pain Points:**
- **Data Integrity:** The legacy system lacked proper data validation and consistency checks, leading to inaccurate and unreliable reporting.
- **Historical Data Loss:** The legacy system did not track changes over time, so any updates to patient information would overwrite previous values, causing issues for compliance and auditing.
- **Performance Issues:** Complex joins across large tables in the legacy RDBMS were leading to slow query performance, frustrating analysts and delaying insights.

## The Solution

I engineered a robust end-to-end ELT (Extract, Load, Transform) pipeline to migrate data into Snowflake and model it for high-performance BI.

### Key Achievements

- **Data Integrity:** Achieved zero data loss by implementing pre- and post-migration validation scripts that performed row-count and checksum comparisons.
- **Performance:** Boosted reporting speed by 30% by optimizing Snowflake clustering keys and refactoring legacy SQL into modular dbt models.
- **Historical Tracking:** Implemented SCD Type 2 logic using dbt snapshots to maintain an accurate audit trail of historical changes.

## Project Data Architecture Flow

### Data Architecture Diagram

*[Insert your data architecture diagram image here]*

**Key Layers:**
- **Bronze (Raw):** 1:1 copies of legacy tables (Patients, Doctors, Encounters, Facilities).
- **Silver (Staging):** Data cleaning, type casting, and SCD Type 2 (Snapshots) for history.
- **Gold (Marts):** Final Dimensional Model (Fact and Dimension tables) ready for BI consumption.

### Data Flow Diagram

*[Insert your data flow diagram image here]*

## Technical Breakdown

| Component | Technology | Implementation Detail |
|-----------|------------|------------------------|
| Warehouse | Snowflake | Scalable compute/storage separation. |
| Orchestration | Python | Batch extraction scripts. |
| Transformation | dbt (Core) | Reusable macros and snapshots. |

### Data Modeling Diagram

*[Insert your data modeling diagram image here]*

## Project Structure
legacy_to_snowflake_migration/
├── scripts/ # Extraction & Validation Layer
│ ├── migrate_users.py # Postgres -> Snowflake Orchestrator
│ └── validation.py # Row-count & Checksum checks
├── dbt_migration/ # Transformation Layer
│ ├── models/
│ │ ├── staging/ # Silver Layer: Cleaning & Macros
│ │ └── marts/ # Gold Layer: Star Schema/Dimensions
│ ├── snapshots/ # SCD Type 2 Historical tracking
│ ├── dbt_project.yml
│ └── profiles.yml
├── .env # Local Credentials (ignored by git)
├── .gitignore
├── requirement.txt # Environment dependencies
└── README.md
