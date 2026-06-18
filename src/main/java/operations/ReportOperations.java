package operations;

import java.util.List;

import implementor.ReportDAO;
import model.Report;
import model.StatusTimeline;
import model.WorkerSummary;
import model.StatusCount;
import model.DeptReportCount;
import model.DepartmentInfo;
import model.RoleCount;
import model.DeptResolution;
import model.UserRow;

public class ReportOperations {

    ReportDAO dao = new ReportDAO();

    // CREATE REPORT
    public int createReport(Report r, List<String> imagePaths) {
        int reportId = dao.saveReport(r);
        if (reportId > 0) {
            dao.saveImages(reportId, imagePaths);
        }
        return reportId;
    }

    // CITIZEN: MY REPORTS
    public List<Report> getCitizenReports(int citizenId) {
        return dao.getReportsByCitizen(citizenId);
    }

    // VIEW SINGLE REPORT
    public Report getReportDetails(int reportId) {
        return dao.getReportById(reportId);
    }

    // VIEW REPORT IMAGES
    public List<String> getReportImages(int reportId) {
        return dao.getReportImages(reportId);
    }

    // Authority dashboard
    public List<Report> getDepartmentReports(int deptId) {
        return dao.getReportsByDepartment(deptId);
    }

    public List<WorkerSummary> getWorkersByDepartment(Integer deptId) {
        if (deptId == null) return new java.util.ArrayList<>();
        return dao.getWorkersByDepartment(deptId);
    }

    // Update status
    public void changeReportStatus(int reportId, String status, int authorityId, String comment) {
        dao.updateReportStatus(reportId, status, authorityId, comment);
    }

    // Status timeline
    public List<StatusTimeline> getReportTimeline(int reportId) {
        return dao.getReportTimeline(reportId);
    }

    public void assignWorker(int reportId, int workerId, int authorityId) {
        dao.assignWorker(reportId, workerId, authorityId);
    }

    // Worker dashboard
    public List<Report> getWorkerReports(int workerId) {
        return dao.getWorkerReports(workerId);
    }

    // Worker progress
    public void workerProgressUpdate(int reportId, String status, int workerId) {
        dao.updateWorkerProgress(reportId, status, workerId);
    }

    // Save after images
    public void saveAfterImages(int reportId, List<String> imagePaths) {
        dao.saveAfterWorkImages(reportId, imagePaths);
    }

    public void workerComplete(int reportId, int workerId) {
        dao.workerMarkCompleted(reportId, workerId);
    }

    // Authority view
    public List<String> getAfterImagesForAuthority(int reportId) {
        return dao.getAfterImagesForAuthority(reportId);
    }

    // Citizen view
    public List<String> getAfterImagesForCitizen(int reportId) {
        return dao.getAfterImagesForCitizen(reportId);
    }

    // APPROVE
    public void authorityApprove(int reportId, int authorityId, String comment) {
        dao.authorityApprove(reportId, authorityId, comment);
    }

    // REJECT
    public void authorityReject(int reportId, int authorityId, String comment) {
        dao.authorityReject(reportId, authorityId, comment);
    }

    public String getLatestRejectionComment(int reportId) {
        return dao.getLatestRejectionComment(reportId);
    }

    // ADMIN methods
    public List<Report> getAllReports()                  { return dao.getAllReports(); }
    public List<StatusCount> getReportStatusCounts()     { return dao.getReportStatusCounts(); }
    public List<DeptReportCount> getReportsByDeptCount() { return dao.getReportsByDeptCount(); }
    public List<UserRow> getAllUsers()                   { return dao.getAllUsers(); }
    public boolean deleteUser(int id)                    { return dao.deleteUser(id); }
    public List<DepartmentInfo> getAllDepartments()      { return dao.getAllDepartments(); }

    public void reassignReport(int reportId, int deptId, int adminId) {
        dao.reassignReport(reportId, deptId, adminId);
    }

    public List<RoleCount> getUserCountsByRole()         { return dao.getUserCountsByRole(); }
    public List<DeptResolution> getAvgResolutionTimeByDept() {
        return dao.getAvgResolutionTimeByDept();
    }

    public double getAvgResolutionHoursForDept(int deptId) {
        return dao.getAvgResolutionHoursForDept(deptId);
    }

    // Helper: Convert hours → "~2 days 3 hrs" format
    public static String formatResolutionTime(double hours) {
        if (hours <= 0) return "No data yet";
        if (hours < 1)  return "Less than 1 hour";
        if (hours < 24) return "~" + (int) hours + " hour" + (hours >= 2 ? "s" : "");

        int days     = (int) (hours / 24);
        int remHours = (int) (hours % 24);

        if (remHours == 0) return "~" + days + " day" + (days > 1 ? "s" : "");
        return "~" + days + " day" + (days > 1 ? "s" : "") + " " + remHours + " hr";
    }
}
