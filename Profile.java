package com.moonbae.model;

import java.sql.Date;

/**
 * Model: Profile
 * Mewakili profil peribadi pengguna.
 */
public class Profile {
    private int    profileID;
    private int    userID;
    private String name;
    private Date   birthDate;
    private int    cycleLength;   // Panjang kitaran purata dalam hari

    // ── Constructor ─────────────────────────────────────────
    public Profile() {}

    public Profile(int userID, String name, int cycleLength) {
        this.userID      = userID;
        this.name        = name;
        this.cycleLength = cycleLength;
    }

    // ── Getters & Setters ────────────────────────────────────
    public int    getProfileID()   { return profileID; }
    public void   setProfileID(int profileID) { this.profileID = profileID; }

    public int    getUserID()      { return userID; }
    public void   setUserID(int userID) { this.userID = userID; }

    public String getName()        { return name; }
    public void   setName(String name) { this.name = name; }

    public Date   getBirthDate()   { return birthDate; }
    public void   setBirthDate(Date birthDate) { this.birthDate = birthDate; }

    public int    getCycleLength() { return cycleLength; }
    public void   setCycleLength(int cycleLength) { this.cycleLength = cycleLength; }
}
