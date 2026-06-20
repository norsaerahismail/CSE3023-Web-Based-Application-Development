package com.moonbae.model;

import java.sql.Date;

/**
 * Model: Prediction
 * Mewakili ramalan kitaran haid seterusnya.
 */
public class Prediction {
    private int    predictionID;
    private int    userID;
    private Date   predictedStartDate;
    private Date   predictedEndDate;

    // ── Constructor ─────────────────────────────────────────
    public Prediction() {}

    public Prediction(int userID, Date predictedStartDate, Date predictedEndDate) {
        this.userID              = userID;
        this.predictedStartDate  = predictedStartDate;
        this.predictedEndDate    = predictedEndDate;
    }

    // ── Helper: kira baki hari sebelum haid bermula ─────────
    public int getDaysUntilPeriod() {
        if (predictedStartDate == null) return -1;
        long today = System.currentTimeMillis();
        long diff  = predictedStartDate.getTime() - today;
        return (int)(diff / (1000 * 60 * 60 * 24));
    }

    // ── Getters & Setters ────────────────────────────────────
    public int  getPredictionID()          { return predictionID; }
    public void setPredictionID(int id)    { this.predictionID = id; }

    public int  getUserID()                { return userID; }
    public void setUserID(int userID)      { this.userID = userID; }

    public Date getPredictedStartDate()    { return predictedStartDate; }
    public void setPredictedStartDate(Date d) { this.predictedStartDate = d; }

    public Date getPredictedEndDate()      { return predictedEndDate; }
    public void setPredictedEndDate(Date d)   { this.predictedEndDate = d; }
}
