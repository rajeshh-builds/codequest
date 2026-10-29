package com.codequest.model;

import java.io.Serializable;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String username;
    private String email;
    private String password;
    private int xp;
    private int level;
    private int rank;
    private int solvedMissions;

    public User() {}

    public User(int id, String username, String email, String password, int xp, int level) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.xp = xp;
        this.level = level;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public int getXp() { return xp; }
    public void setXp(int xp) { this.xp = xp; }

    public int getLevel() { return level; }
    public void setLevel(int level) { this.level = level; }

    public int getRank() { return rank; }
    public void setRank(int rank) { this.rank = rank; }

    public int getSolvedMissions() { return solvedMissions; }
    public void setSolvedMissions(int solvedMissions) { this.solvedMissions = solvedMissions; }

    /**
     * Calculates the XP needed for the next level: each level requires 100 * level XP
     */
    public int getXpForCurrentLevel() {
        return (level - 1) * 100;
    }

    public int getXpForNextLevel() {
        return level * 100;
    }

    public int getProgressPercentage() {
        int currentBase = getXpForCurrentLevel();
        int nextTarget = getXpForNextLevel();
        int progressXp = xp - currentBase;
        int diff = nextTarget - currentBase;
        if (diff <= 0) return 100;
        int pct = (progressXp * 100) / diff;
        if (pct < 0) return 0;
        if (pct > 100) return 100;
        return pct;
    }

    public String getTierTitle() {
        if (level >= 10) return "Cyber Overlord";
        if (level >= 7) return "Elite Architect";
        if (level >= 5) return "Code Adept";
        if (level >= 3) return "Byte Hunter";
        return "Novice Hacker";
    }
}
