-- ============================================================
-- MoonBae: Period Tracker - Database Schema
-- Database: moonbae_db
-- Versi: 1.0
-- ============================================================

-- Cipta dan guna database
CREATE DATABASE IF NOT EXISTS moonbae_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE moonbae_db;

-- ============================================================
-- JADUAL 1: users
-- Menyimpan maklumat akaun pengguna
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    userID      INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    email       VARCHAR(100) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,          -- Simpan password yang di-hash (SHA-256)
    createdAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- JADUAL 2: profiles
-- Menyimpan maklumat profil peribadi pengguna
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
    profileID   INT AUTO_INCREMENT PRIMARY KEY,
    userID      INT          NOT NULL UNIQUE,
    name        VARCHAR(100) NOT NULL,
    birthDate   DATE,
    cycleLength INT          NOT NULL DEFAULT 28, -- Panjang kitaran dalam hari
    CONSTRAINT fk_profile_user FOREIGN KEY (userID)
        REFERENCES users(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- JADUAL 3: period_logs
-- Menyimpan rekod haid pengguna
-- ============================================================
CREATE TABLE IF NOT EXISTS period_logs (
    dataID        INT AUTO_INCREMENT PRIMARY KEY,
    userID        INT          NOT NULL,
    startDate     DATE         NOT NULL,
    endDate       DATE,
    bloodFlowType ENUM('Light','Medium','Heavy','Spotting') DEFAULT 'Medium',
    symptoms      VARCHAR(500),                  -- Disimpan sebagai CSV: "Cramps,Headache"
    notes         TEXT,
    createdAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_user FOREIGN KEY (userID)
        REFERENCES users(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- JADUAL 4: predictions
-- Menyimpan ramalan kitaran seterusnya
-- ============================================================
CREATE TABLE IF NOT EXISTS predictions (
    predictionID        INT AUTO_INCREMENT PRIMARY KEY,
    userID              INT  NOT NULL,
    predictedStartDate  DATE NOT NULL,
    predictedEndDate    DATE NOT NULL,
    generatedAt         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pred_user FOREIGN KEY (userID)
        REFERENCES users(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- JADUAL 5: reminders
-- Menyimpan peringatan yang dijana oleh sistem
-- ============================================================
CREATE TABLE IF NOT EXISTS reminders (
    reminderID    INT AUTO_INCREMENT PRIMARY KEY,
    userID        INT          NOT NULL,
    reminderDate  DATE         NOT NULL,
    reminderText  VARCHAR(255) NOT NULL,
    status        ENUM('active','dismissed') DEFAULT 'active',
    createdAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rem_user FOREIGN KEY (userID)
        REFERENCES users(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- DATA UJIAN (Sample Data) - Boleh dipadam sebelum production
-- ============================================================
-- Pengguna contoh (password: 'password123' dalam SHA-256)
INSERT INTO users (username, email, password) VALUES
('saerah', 'saerah@email.com', SHA2('password123', 256)),
('natasya', 'natasya@email.com', SHA2('password123', 256));

-- Profil contoh
INSERT INTO profiles (userID, name, birthDate, cycleLength) VALUES
(1, 'Nor Saerah Binti Ismail', '2002-05-15', 28),
(2, 'Nor Ain Natasya', '2001-11-20', 30);

-- Log haid contoh untuk user 1
INSERT INTO period_logs (userID, startDate, endDate, bloodFlowType, symptoms, notes) VALUES
(1, '2026-02-03', '2026-02-08', 'Medium', 'Cramps', 'Normal cycle'),
(1, '2026-03-02', '2026-03-06', 'Heavy',  'Mood Swings,Fatigue', 'Slightly heavy this month'),
(1, '2026-03-30', '2026-04-04', 'Medium', 'Cramps,Headache', NULL);

COMMIT;
