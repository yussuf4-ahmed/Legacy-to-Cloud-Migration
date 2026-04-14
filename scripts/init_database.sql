-- SQL Script to Initialize Legacy PostgreSQL Database with Required Schema
-- =========================================
-- 1. CREATE DATABASE
-- =========================================
CREATE DATABASE pulsecore_legacy;

-- =========================================
-- 2. CONNECT TO DATABASE
-- (In pgAdmin, manually select the DB after creation)
-- =========================================
-- After running the above:
-- 👉 Right-click pulsecore_legacy → Query Tool


-- =========================================
-- 3. CREATE SCHEMA
-- =========================================
CREATE SCHEMA IF NOT EXISTS legacy;

-- =========================================
-- 4. SET SEARCH PATH
-- =========================================
SET search_path TO legacy;

-- =========================================
-- 5. PATIENTS TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS patients (
    patient_id INT PRIMARY KEY,
    full_name TEXT,
    first_name TEXT,
    last_name TEXT,
    gender TEXT,
    date_of_birth DATE,
    insurance TEXT,
    phone TEXT,
    email TEXT,
    created_date DATE,
    year INT
);

-- =========================================
-- 6. DOCTORS TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name TEXT,
    specialization TEXT,
    experience_years INT
);

-- =========================================
-- 7. FACILITIES TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS facilities (
    facility_id INT PRIMARY KEY,
    facility_name TEXT,
    location TEXT,
    type TEXT
);

-- =========================================
-- 8. ENCOUNTERS TABLE (CORE TABLE)
-- =========================================
CREATE TABLE IF NOT EXISTS encounters (
    encounter_id INT PRIMARY KEY,

    patient_id INT,
    doctor_id INT,
    facility_id INT,

    encounter_date TEXT,  -- intentionally messy (to clean later)

    diagnosis_code TEXT,
    procedure_code TEXT,

    total_cost INT,
    insurance_covered INT,

    year INT,
    month INT,

    -- Foreign Keys
    CONSTRAINT fk_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    CONSTRAINT fk_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),

    CONSTRAINT fk_facility
        FOREIGN KEY (facility_id)
        REFERENCES facilities(facility_id)
);

-- =========================================
-- 9. OPTIONAL INDEXES (PERFORMANCE BOOST)
-- =========================================
CREATE INDEX IF NOT EXISTS idx_encounters_patient 
ON encounters(patient_id);

CREATE INDEX IF NOT EXISTS idx_encounters_date 
ON encounters(year, month);

-- =========================================
-- DONE
-- =========================================
            
