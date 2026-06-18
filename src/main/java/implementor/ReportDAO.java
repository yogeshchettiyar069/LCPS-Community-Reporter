package implementor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import db_config.DBConnection;
import model.Report;
import model.StatusTimeline;
import model.WorkerSummary;
import model.StatusCount;
import model.DeptReportCount;
import model.DepartmentInfo;
import model.RoleCount;
import model.DeptResolution;
import model.UserRow;

public class ReportDAO {

    public int saveReport(Report r) {

        String sql = "INSERT INTO reports "
                   + "(title, description, severity, status, latitude, longitude, citizen_id, assigned_dept_id) "
                   + "VALUES (?,?,?,?,?,?,?,?)";

        String logSql = "INSERT INTO report_status_log "
                      + "(report_id, status, updated_by, comment) "
                      + "VALUES (?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, r.getTitle());
            ps.setString(2, r.getDescription());
            ps.setString(3, r.getSeverity());
            ps.setString(4, "Pending");
            ps.setDouble(5, r.getLatitude());
            ps.setDouble(6, r.getLongitude());
            ps.setInt(7, r.getCitizenId());
            ps.setInt(8, r.getDeptId());

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int reportId = rs.getInt(1);

                    try (PreparedStatement ps2 = con.prepareStatement(logSql)) {
                        ps2.setInt(1, reportId);
                        ps2.setString(2, "Pending");
                        ps2.setInt(3, r.getCitizenId());
                        ps2.setString(4, "Report created by citizen");
                        ps2.executeUpdate();
                    }

                    return reportId;
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to save report", e);
        }

        return 0;
    }

    public void saveImages(int reportId, List<String> imagePaths) {

        String sql = "INSERT INTO report_images (report_id, image_path, image_type) VALUES (?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            for (String path : imagePaths) {
                ps.setInt(1, reportId);
                ps.setString(2, path);
                ps.setString(3, "BEFORE");
                ps.addBatch();
            }
            ps.executeBatch();

        } catch (Exception e) {
            throw new RuntimeException("Failed to save report images", e);
        }
    }

    public List<Report> getReportsByCitizen(int citizenId) {

        List<Report> reports = new ArrayList<>();

        String sql =
            "SELECT r.report_id, r.title, r.status, r.created_at, d.dept_name "
          + "FROM reports r "
          + "LEFT JOIN departments d ON r.assigned_dept_id = d.dept_id "
          + "WHERE r.citizen_id = ? "
          + "ORDER BY r.created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, citizenId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Report r = new Report();
                    r.setReportId(rs.getInt("report_id"));
                    r.setTitle(rs.getString("title"));
                    r.setStatus(rs.getString("status"));
                    r.setDeptName(rs.getString("dept_name"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    reports.add(r);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load citizen reports", e);
        }

        return reports;
    }

    // Fetch single report details
    public Report getReportById(int reportId) {

        String sql = "SELECT r.*, d.dept_name, u.name AS citizen_name "
                   + "FROM reports r "
                   + "LEFT JOIN departments d ON r.assigned_dept_id = d.dept_id "
                   + "LEFT JOIN users u ON r.citizen_id = u.user_id "
                   + "WHERE r.report_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, reportId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Report r = new Report();
                    r.setReportId(rs.getInt("report_id"));
                    r.setTitle(rs.getString("title"));
                    r.setDescription(rs.getString("description"));
                    r.setSeverity(rs.getString("severity"));
                    r.setStatus(rs.getString("status"));
                    r.setLatitude(rs.getDouble("latitude"));
                    r.setLongitude(rs.getDouble("longitude"));
                    r.setCitizenId(rs.getInt("citizen_id"));
                    r.setDeptId(rs.getInt("assigned_dept_id"));
                    r.setDeptName(rs.getString("dept_name"));
                    r.setCitizenName(rs.getString("citizen_name"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    return r;
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load report " + reportId, e);
        }

        return null;
    }

    // Fetch BEFORE images of report
    public List<String> getReportImages(int reportId) {
        return getImagePaths(reportId,
            "SELECT image_path FROM report_images "
          + "WHERE report_id = ? AND image_type = 'BEFORE'");
    }

    // Authority can see all AFTER images (no status restriction)
    public List<String> getAfterImagesForAuthority(int reportId) {
        return getImagePaths(reportId,
            "SELECT image_path FROM report_images "
          + "WHERE report_id = ? AND image_type = 'AFTER'");
    }

    // Citizen sees AFTER images only when report is resolved
    public List<String> getAfterImagesForCitizen(int reportId) {
        return getImagePaths(reportId,
            "SELECT image_path FROM report_images "
          + "WHERE report_id = ? AND image_type = 'AFTER' "
          + "AND report_id IN (SELECT report_id FROM reports WHERE status = 'Resolved')");
    }

    private List<String> getImagePaths(int reportId, String sql) {

        List<String> paths = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, reportId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    paths.add(rs.getString("image_path"));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load images for report " + reportId, e);
        }

        return paths;
    }

    // Authority: reports for department
    public List<Report> getReportsByDepartment(int deptId) {

        List<Report> reports = new ArrayList<>();

        String sql = "SELECT r.report_id, r.title, r.status, r.created_at, "
                   + "u.name AS citizen_name "
                   + "FROM reports r "
                   + "JOIN users u ON r.citizen_id = u.user_id "
                   + "WHERE r.assigned_dept_id = ? "
                   + "ORDER BY r.created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, deptId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Report r = new Report();
                    r.setReportId(rs.getInt("report_id"));
                    r.setTitle(rs.getString("title"));
                    r.setStatus(rs.getString("status"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    r.setCitizenName(rs.getString("citizen_name"));
                    reports.add(r);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load department reports", e);
        }

        return reports;
    }

    // Update report status
    public void updateReportStatus(int reportId, String status, int authorityId, String comment) {

        String updateSql = "UPDATE reports SET status = ? WHERE report_id = ?";
        String logSql = "INSERT INTO report_status_log "
                      + "(report_id, status, updated_by, comment) "
                      + "VALUES (?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps1 = con.prepareStatement(updateSql);
             PreparedStatement ps2 = con.prepareStatement(logSql)) {

            ps1.setString(1, status);
            ps1.setInt(2, reportId);
            ps1.executeUpdate();

            ps2.setInt(1, reportId);
            ps2.setString(2, status);
            ps2.setInt(3, authorityId);
            ps2.setString(4, comment);
            ps2.executeUpdate();

        } catch (Exception e) {
            throw new RuntimeException("Failed to update report status", e);
        }
    }

    // Fetch status timeline of a report
    public List<StatusTimeline> getReportTimeline(int reportId) {

        List<StatusTimeline> timeline = new ArrayList<>();

        String sql = "SELECT l.status, l.updated_at, u.name AS updated_by "
                   + "FROM report_status_log l "
                   + "JOIN users u ON l.updated_by = u.user_id "
                   + "WHERE l.report_id = ? "
                   + "ORDER BY l.updated_at ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, reportId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StatusTimeline t = new StatusTimeline();
                    t.setStatus(rs.getString("status"));
                    t.setUpdatedAt(rs.getTimestamp("updated_at"));
                    t.setUpdatedBy(rs.getString("updated_by"));
                    timeline.add(t);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load report timeline", e);
        }

        return timeline;
    }

    public void assignWorker(int reportId, int workerId, int authorityId) {

        String updateSql =
            "UPDATE reports SET assigned_worker_id = ?, status = 'Assigned' WHERE report_id = ?";
        String logSql =
            "INSERT INTO report_status_log (report_id, status, updated_by, comment) VALUES (?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps1 = con.prepareStatement(updateSql);
             PreparedStatement ps2 = con.prepareStatement(logSql)) {

            ps1.setInt(1, workerId);
            ps1.setInt(2, reportId);
            ps1.executeUpdate();

            ps2.setInt(1, reportId);
            ps2.setString(2, "Assigned");
            ps2.setInt(3, authorityId);
            ps2.setString(4, "Worker assigned by authority");
            ps2.executeUpdate();

        } catch (Exception e) {
            throw new RuntimeException("Failed to assign worker", e);
        }
    }

    // Fetch all workers of a department
    public List<WorkerSummary> getWorkersByDepartment(int deptId) {

        List<WorkerSummary> workers = new ArrayList<>();

        String sql = "SELECT user_id, name FROM users WHERE role_id = 4 AND dept_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, deptId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WorkerSummary w = new WorkerSummary();
                    w.setUserId(rs.getInt("user_id"));
                    w.setName(rs.getString("name"));
                    workers.add(w);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load workers for department " + deptId, e);
        }

        return workers;
    }

    // Worker: reports assigned to worker
    public List<Report> getWorkerReports(int workerId) {

        List<Report> reports = new ArrayList<>();

        String sql = "SELECT r.report_id, r.title, r.description, r.status, r.severity, r.created_at, "
                   + "d.dept_name "
                   + "FROM reports r "
                   + "LEFT JOIN departments d ON r.assigned_dept_id = d.dept_id "
                   + "WHERE r.assigned_worker_id = ? "
                   + "ORDER BY r.created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, workerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Report r = new Report();
                    r.setReportId(rs.getInt("report_id"));
                    r.setTitle(rs.getString("title"));
                    r.setDescription(rs.getString("description"));
                    r.setStatus(rs.getString("status"));
                    r.setSeverity(rs.getString("severity"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    r.setDeptName(rs.getString("dept_name"));
                    reports.add(r);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load worker reports", e);
        }

        return reports;
    }

    // Worker progress update
    public void updateWorkerProgress(int reportId, String status, int workerId) {

        String updateSql = "UPDATE reports SET status=? WHERE report_id=?";
        String logSql = "INSERT INTO report_status_log (report_id, status, updated_by, comment) VALUES (?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps1 = con.prepareStatement(updateSql);
             PreparedStatement ps2 = con.prepareStatement(logSql)) {

            ps1.setString(1, status);
            ps1.setInt(2, reportId);
            ps1.executeUpdate();

            ps2.setInt(1, reportId);
            ps2.setString(2, status);
            ps2.setInt(3, workerId);
            ps2.setString(4, "Worker update");
            ps2.executeUpdate();

        } catch (Exception e) {
            throw new RuntimeException("Failed to update worker progress", e);
        }
    }

    // Save AFTER images
    public void saveAfterWorkImages(int reportId, List<String> imagePaths) {

        String sql = "INSERT INTO report_images (report_id, image_path, image_type) VALUES (?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            for (String path : imagePaths) {
                ps.setInt(1, reportId);
                ps.setString(2, path);
                ps.setString(3, "AFTER");
                ps.addBatch();
            }
            ps.executeBatch();

        } catch (Exception e) {
            throw new RuntimeException("Failed to save after-work images", e);
        }
    }

    public void workerMarkCompleted(int reportId, int workerId) {

        String updateSql = "UPDATE reports SET status = ? WHERE report_id = ?";
        String logSql = "INSERT INTO report_status_log (report_id, status, updated_by, comment) VALUES (?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps1 = con.prepareStatement(updateSql);
             PreparedStatement ps2 = con.prepareStatement(logSql)) {

            ps1.setString(1, "Work Completed (Pending Approval)");
            ps1.setInt(2, reportId);
            ps1.executeUpdate();

            ps2.setInt(1, reportId);
            ps2.setString(2, "Work Completed (Pending Approval)");
            ps2.setInt(3, workerId);
            ps2.setString(4, "Worker submitted completion proof");
            ps2.executeUpdate();

        } catch (Exception e) {
            throw new RuntimeException("Failed to mark work completed", e);
        }
    }

    public void authorityApprove(int reportId, int authorityId, String comment) {

        String updateSql = "UPDATE reports SET status = 'Resolved' WHERE report_id = ?";
        String logSql = "INSERT INTO report_status_log (report_id, status, updated_by, comment) VALUES (?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps1 = con.prepareStatement(updateSql);
             PreparedStatement ps2 = con.prepareStatement(logSql)) {

            ps1.setInt(1, reportId);
            ps1.executeUpdate();

            ps2.setInt(1, reportId);
            ps2.setString(2, "Resolved");
            ps2.setInt(3, authorityId);
            ps2.setString(4, comment != null && !comment.isEmpty() ? comment : "Approved by authority");
            ps2.executeUpdate();

        } catch (Exception e) {
            throw new RuntimeException("Failed to approve report", e);
        }
    }

    public void authorityReject(int reportId, int authorityId, String comment) {

        String updateSql = "UPDATE reports SET status = 'Rework Required' WHERE report_id = ?";
        String logSql = "INSERT INTO report_status_log (report_id, status, updated_by, comment) VALUES (?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps1 = con.prepareStatement(updateSql);
             PreparedStatement ps2 = con.prepareStatement(logSql)) {

            ps1.setInt(1, reportId);
            ps1.executeUpdate();

            ps2.setInt(1, reportId);
            ps2.setString(2, "Rework Required");
            ps2.setInt(3, authorityId);
            ps2.setString(4, comment != null && !comment.isEmpty() ? comment : "Work rejected by authority");
            ps2.executeUpdate();

        } catch (Exception e) {
            throw new RuntimeException("Failed to reject report", e);
        }
    }

    public String getLatestRejectionComment(int reportId) {

        String sql = "SELECT comment FROM report_status_log "
                   + "WHERE report_id = ? AND status = 'Rework Required' "
                   + "ORDER BY updated_at DESC LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, reportId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("comment");
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load rejection comment", e);
        }

        return null;
    }

    // ADMIN: All reports system-wide
    public List<Report> getAllReports() {

        List<Report> reports = new ArrayList<>();

        String sql = "SELECT r.report_id, r.title, r.description, r.status, r.severity, r.assigned_dept_id, r.created_at, "
                   + "d.dept_name, u.name AS citizen_name "
                   + "FROM reports r "
                   + "LEFT JOIN departments d ON r.assigned_dept_id = d.dept_id "
                   + "LEFT JOIN users u ON r.citizen_id = u.user_id "
                   + "ORDER BY r.created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Report r = new Report();
                r.setReportId(rs.getInt("report_id"));
                r.setTitle(rs.getString("title"));
                r.setDescription(rs.getString("description"));
                r.setStatus(rs.getString("status"));
                r.setSeverity(rs.getString("severity"));
                r.setDeptId(rs.getInt("assigned_dept_id"));
                r.setDeptName(rs.getString("dept_name"));
                r.setCitizenName(rs.getString("citizen_name"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                reports.add(r);
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load all reports", e);
        }

        return reports;
    }

    // ADMIN: Report counts per status
    public List<StatusCount> getReportStatusCounts() {

        List<StatusCount> counts = new ArrayList<>();
        String sql = "SELECT status, COUNT(*) AS total FROM reports GROUP BY status";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                StatusCount c = new StatusCount();
                c.setStatus(rs.getString("status"));
                c.setTotal(rs.getInt("total"));
                counts.add(c);
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load report status counts", e);
        }

        return counts;
    }

    // ADMIN: Report counts per department
    public List<DeptReportCount> getReportsByDeptCount() {

        List<DeptReportCount> counts = new ArrayList<>();
        String sql = """
                SELECT
                MIN(d.dept_id)   AS dept_id,
                d.dept_name,
                COUNT(r.report_id) AS total_reports
            FROM departments d
            LEFT JOIN reports r ON r.assigned_dept_id = d.dept_id
            GROUP BY d.dept_name
            ORDER BY total_reports DESC
        """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                DeptReportCount c = new DeptReportCount();
                c.setDeptId(rs.getInt("dept_id"));
                c.setDeptName(rs.getString("dept_name"));
                c.setTotalReports(rs.getInt("total_reports"));
                counts.add(c);
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load reports-by-department counts", e);
        }

        return counts;
    }

    // ADMIN: All users
    public List<UserRow> getAllUsers() {

        List<UserRow> users = new ArrayList<>();
        String sql = "SELECT u.user_id, u.name, u.email, u.phone, u.created_at, "
                   + "r.role_name, d.dept_name "
                   + "FROM users u "
                   + "JOIN roles r ON u.role_id = r.role_id "
                   + "LEFT JOIN departments d ON u.dept_id = d.dept_id "
                   + "ORDER BY u.created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                UserRow u = new UserRow();
                u.setUserId(rs.getInt("user_id"));
                u.setName(rs.getString("name"));
                u.setEmail(rs.getString("email"));
                u.setPhone(rs.getString("phone"));
                u.setRoleName(rs.getString("role_name"));
                u.setDeptName(rs.getString("dept_name"));
                u.setCreatedAt(rs.getTimestamp("created_at"));
                users.add(u);
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load users", e);
        }

        return users;
    }

    // ADMIN: Delete user
    public boolean deleteUser(int userId) {

        String sql = "DELETE FROM users WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new RuntimeException("Failed to delete user " + userId, e);
        }
    }

    // ADMIN: All departments
    public List<DepartmentInfo> getAllDepartments() {

        List<DepartmentInfo> depts = new ArrayList<>();
        String sql = """
                SELECT
                MIN(d.dept_id)     AS dept_id,
                d.dept_name,
                MIN(d.created_at)  AS created_at,
                COUNT(r.report_id) AS total_reports
            FROM departments d
            LEFT JOIN reports r ON r.assigned_dept_id = d.dept_id
            GROUP BY d.dept_name
            ORDER BY MIN(d.dept_id)
        """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                DepartmentInfo d = new DepartmentInfo();
                d.setDeptId(rs.getInt("dept_id"));
                d.setDeptName(rs.getString("dept_name"));
                d.setCreatedAt(rs.getTimestamp("created_at"));
                d.setTotalReports(rs.getInt("total_reports"));
                depts.add(d);
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load departments", e);
        }

        return depts;
    }

    // ADMIN: Reassign report to different dept
    public void reassignReport(int reportId, int newDeptId, int adminId) {

        String updateSql = "UPDATE reports SET assigned_dept_id = ? WHERE report_id = ?";
        String logSql    = "INSERT INTO report_status_log "
                         + "(report_id, status, updated_by, comment) VALUES (?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps1 = con.prepareStatement(updateSql);
             PreparedStatement ps2 = con.prepareStatement(logSql)) {

            ps1.setInt(1, newDeptId);
            ps1.setInt(2, reportId);
            ps1.executeUpdate();

            ps2.setInt(1, reportId);
            ps2.setString(2, "Reassigned");
            ps2.setInt(3, adminId);
            ps2.setString(4, "Report reassigned by Admin");
            ps2.executeUpdate();

        } catch (Exception e) {
            throw new RuntimeException("Failed to reassign report", e);
        }
    }

    // ADMIN: Total user counts by role
    public List<RoleCount> getUserCountsByRole() {

        List<RoleCount> counts = new ArrayList<>();
        String sql = "SELECT r.role_name, COUNT(u.user_id) AS total "
                   + "FROM roles r "
                   + "LEFT JOIN users u ON r.role_id = u.role_id "
                   + "GROUP BY r.role_id, r.role_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoleCount c = new RoleCount();
                c.setRoleName(rs.getString("role_name"));
                c.setTotal(rs.getInt("total"));
                counts.add(c);
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load user counts by role", e);
        }

        return counts;
    }

    // Resolution time predictor — avg hours per department
    public List<DeptResolution> getAvgResolutionTimeByDept() {

        List<DeptResolution> rows = new ArrayList<>();
        String sql =
            "SELECT d.dept_id, d.dept_name, " +
            "COUNT(r.report_id) AS total_resolved, " +
            "ROUND(AVG(TIMESTAMPDIFF(HOUR, r.created_at, l.resolved_at)), 1) AS avg_hours " +
            "FROM departments d " +
            "JOIN reports r ON d.dept_id = r.assigned_dept_id " +
            "JOIN ( " +
            "    SELECT report_id, MAX(updated_at) AS resolved_at " +
            "    FROM report_status_log " +
            "    WHERE status = 'Resolved' " +
            "    GROUP BY report_id " +
            ") l ON r.report_id = l.report_id " +
            "WHERE r.status = 'Resolved' " +
            "GROUP BY d.dept_id, d.dept_name " +
            "ORDER BY avg_hours ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                DeptResolution d = new DeptResolution();
                d.setDeptId(rs.getInt("dept_id"));
                d.setDeptName(rs.getString("dept_name"));
                d.setTotalResolved(rs.getInt("total_resolved"));
                d.setAvgHours(rs.getDouble("avg_hours"));
                rows.add(d);
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load resolution times", e);
        }

        return rows;
    }

    // Get avg hours for ONE specific department (used on citizen view-report page)
    public double getAvgResolutionHoursForDept(int deptId) {

        String sql =
            "SELECT ROUND(AVG(TIMESTAMPDIFF(HOUR, r.created_at, l.resolved_at)), 1) AS avg_hours " +
            "FROM reports r " +
            "JOIN ( " +
            "    SELECT report_id, MAX(updated_at) AS resolved_at " +
            "    FROM report_status_log " +
            "    WHERE status = 'Resolved' " +
            "    GROUP BY report_id " +
            ") l ON r.report_id = l.report_id " +
            "WHERE r.status = 'Resolved' " +
            "AND r.assigned_dept_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, deptId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("avg_hours");
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Failed to load avg resolution hours", e);
        }

        return -1; // -1 means no data yet
    }
}
