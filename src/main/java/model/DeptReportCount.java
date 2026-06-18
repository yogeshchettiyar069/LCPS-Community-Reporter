package model;

/** Report count for a single department (admin "reports by department" bars). */
public class DeptReportCount {

    private int deptId;
    private String deptName;
    private int totalReports;

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

    public int getTotalReports() {
        return totalReports;
    }
    public void setTotalReports(int totalReports) {
        this.totalReports = totalReports;
    }
}
