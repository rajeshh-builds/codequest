package com.codequest.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Submission implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private int missionId;
    private boolean correct;
    private Timestamp submittedAt;
    private String missionTitle;
    private String category;
    private int xpReward;

    public Submission() {}

    public Submission(int id, int userId, int missionId, boolean correct, Timestamp submittedAt) {
        this.id = id;
        this.userId = userId;
        this.missionId = missionId;
        this.correct = correct;
        this.submittedAt = submittedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getMissionId() { return missionId; }
    public void setMissionId(int missionId) { this.missionId = missionId; }

    public boolean isCorrect() { return correct; }
    public void setCorrect(boolean correct) { this.correct = correct; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public String getMissionTitle() { return missionTitle; }
    public void setMissionTitle(String missionTitle) { this.missionTitle = missionTitle; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public int getXpReward() { return xpReward; }
    public void setXpReward(int xpReward) { this.xpReward = xpReward; }
}
