package com.moonbae.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model: PeriodLog
 * Mewakili satu rekod haid pengguna.
 */
public class PeriodLog {
    private int       dataID;
    private int       userID;
    private Date      startDate;
    private Date      endDate;
    private String    bloodFlowType;  // Light | Medium | Heavy | Spotting
    private String    symptoms;       // CSV: "Cramps,Headache,Fatigue"
    private String    notes;
    private Timestamp createdAt;

    // ── Constructor ─────────────────────────────────────────
    public PeriodLog() {}

    // ── Helper: kira tempoh dalam hari ──────────────────────
    public int getDuration() {
        if (startDate == null || endDate == null) return 0;
        long diff = endDate.getTime() - startDate.getTime();
        return (int)(diff / (1000 * 60 * 60 * 24)) + 1; // inklusif
    }

    // ── Helper: pecah symptoms kepada array ─────────────────
    public String[] getSymptomsArray() {
        if (symptoms == null || symptoms.isEmpty()) return new String[0];
        return symptoms.split(",");
    }

    // ── Getters & Setters ────────────────────────────────────
    public int       getDataID()       { return dataID; }
    public void      setDataID(int dataID) { this.dataID = dataID; }

    public int       getUserID()       { return userID; }
    public void      setUserID(int userID) { this.userID = userID; }

    public Date      getStartDate()    { return startDate; }
    public void      setStartDate(Date startDate) { this.startDate = startDate; }

    public Date      getEndDate()      { return endDate; }
    public void      setEndDate(Date endDate) { this.endDate = endDate; }

    public String    getBloodFlowType(){ return bloodFlowType; }
    public void      setBloodFlowType(String bloodFlowType) { this.bloodFlowType = bloodFlowType; }

    public String    getSymptoms()     { return symptoms; }
    public void      setSymptoms(String symptoms) { this.symptoms = symptoms; }

    public String    getNotes()        { return notes; }
    public void      setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt()    { return createdAt; }
    public void      setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
