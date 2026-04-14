# Data Generation Script for Legacy PostgreSQL RDBMS

pip install psycopg2 pandas faker sqlalchemy

from sqlalchemy import create_engine

engine = create_engine(
    "postgresql://postgres:5432@localhost:5432/pulsecore_legacy"
)

# =========================================
# SETUP
# =========================================
import pandas as pd
import random
from faker import Faker
from datetime import datetime

fake = Faker()
random.seed(42)

# =========================================
# 1. GENERATE PATIENTS (MESSY + TIME-AWARE)
# =========================================
patients = []

for i in range(1, 201):

    created_date = fake.date_between(
        start_date=date(2024, 1, 1),
        end_date=date(2025, 12, 31)
    )

    first = fake.first_name()
    last = fake.last_name()

    patients.append({
        "patient_id": i,

        # messy naming
        "full_name": random.choice([
            f"{first} {last}",
            f"{first}",
            f"{first[0]}. {last}",
            f"{last}, {first}",
            None
        ]),
        "first_name": first if random.random() > 0.2 else None,
        "last_name": last if random.random() > 0.2 else None,
        "gender": random.choice(["Male", "Female", None]),
        "date_of_birth": fake.date_of_birth(minimum_age=18, maximum_age=90),
        "insurance": random.choice(["Plan A", "Plan B", "A", "plan_c", None]),
        "phone": fake.phone_number() if random.random() > 0.3 else None,
        "email": fake.email() if random.random() > 0.3 else None,
        "created_date": created_date,
        "year": created_date.year
    })

df_patients = pd.DataFrame(patients)
df_patients.to_sql("patients", engine, schema="legacy", if_exists="append", index=False)


# =========================================
# 2. GENERATE DOCTORS
# =========================================
doctors = []

for i in range(1, 21):  # ~20 doctors
    doctors.append({
        "doctor_id": i,
        "doctor_name": fake.name(),
        "specialization": random.choice([
            "Cardiology", "Neurology", "General", "Pediatrics"
        ]),
        "experience_years": random.randint(1, 30)
    })

df_doctors = pd.DataFrame(doctors)
df_doctors.to_sql("doctors", engine, schema="legacy", if_exists="append", index=False)


# =========================================
# 3. GENERATE FACILITIES
# =========================================
facilities = []

for i in range(1, 9):  # ~8 facilities
    facilities.append({
        "facility_id": i,
        "facility_name": fake.company() + " Clinic",
        "location": fake.city(),
        "type": random.choice(["Hospital", "Clinic"])
    })

df_facilities = pd.DataFrame(facilities)
df_facilities.to_sql("facilities", engine, schema="legacy", if_exists="append", index=False)


# =========================================
# 4. GENERATE ENCOUNTERS (2 YEARS DAILY DATA)
# =========================================
start_date = datetime(2024, 1, 1)
end_date = datetime(2025, 12, 31)

date_range = pd.date_range(start=start_date, end=end_date)

# Get the current max encounter_id
result = pd.read_sql("SELECT COALESCE(MAX(encounter_id), 0) as max_id FROM legacy.encounters", engine)
current_max_id = result['max_id'].iloc[0]
encounter_id = current_max_id + 1
encounters = []

for date in date_range:
    daily_count = random.randint(3, 8) if date.year == 2024 else random.randint(5, 12)

    for _ in range(daily_count):
        encounters.append({
            "encounter_id": encounter_id,
            "patient_id": random.randint(1, 200),
            "doctor_id": random.randint(1, 20),
            "facility_id": random.randint(1, 8),
            "encounter_date": random.choice([
                date.strftime("%Y-%m-%d"),
                date.strftime("%d-%m-%Y"),
                date.strftime("%m/%d/%Y")
            ]),
            "diagnosis_code": random.choice(["D1", "D2", "D3"]),
            "procedure_code": random.choice(["P1", "P2", "P3"]),
            "total_cost": random.choice([random.randint(50, 1000), None]),
            "insurance_covered": random.randint(0, 500),
            "year": date.year,
            "month": date.month
        })
        encounter_id += 1

df_encounters = pd.DataFrame(encounters)

# Create 50 duplicate records with new IDs
duplicate_records = []
for i in range(50):
    template = df_encounters.sample(1).iloc[0].to_dict()
    template['encounter_id'] = encounter_id
    duplicate_records.append(template)
    encounter_id += 1

df_encounters = pd.concat([df_encounters, pd.DataFrame(duplicate_records)], ignore_index=True)

df_encounters.to_sql("encounters", engine, schema="legacy", if_exists="append", index=False)

# =========================================
# DONE
# =========================================
print("✅ Data generation complete!")
