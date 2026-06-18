package model;

/** Average resolution performance for a department (resolution predictor). */
public class DeptResolution {

    private int deptId;
    private String deptName;
    private int totalResolved;
    private double avgHours;

    public int getDeptId() {
        return deptId;
    }
    public void setDeptId(int deptId) {
        this.deptId = deptId;
    }

    public String getDeptName() {
        return deptName;
    }
    public void setDeptName(String deptName) {
        this.deptName = deptName;
    }

    public int getTotalResolved() {
        return totalResolved;
    }
    public void setTotalResolved(int totalResolved) {
        this.totalResolved = totalResolved;
    }

    public double getAvgHours() {
        return avgHours;
    }
    public void setAvgHours(double avgHours) {
        this.avgHours = avgHours;
    }
}
