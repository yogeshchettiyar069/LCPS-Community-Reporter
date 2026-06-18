package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import operations.ReportOperations;
import implementor.UserDAO;
import model.Report;

import java.io.IOException;

@WebServlet("/admin")
public class AdminController extends HttpServlet {

    ReportOperations ops = new ReportOperations();

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User admin = (User) session.getAttribute("user");

        if (admin == null || admin.getRoleId() != 1) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");

        // ===== DELETE USER =====
        if ("deleteUser".equals(action)) {
            int userId = Integer.parseInt(req.getParameter("user_id"));
            ops.deleteUser(userId);
            resp.sendRedirect("admin/users.jsp?deleted=true");
            return;
        }

        // ===== REASSIGN REPORT =====
        if ("reassign".equals(action)) {
            int reportId = Integer.parseInt(req.getParameter("report_id"));
            int newDeptId = Integer.parseInt(req.getParameter("dept_id"));
            ops.reassignReport(reportId, newDeptId, admin.getUserId());
            resp.sendRedirect("admin/all-reports.jsp?reassigned=true");
            return;
        }

        // ===== CREATE AUTHORITY / WORKER =====
        if ("createAuthority".equals(action)) {
            UserDAO userDao = new UserDAO();
            User u = new User();
            u.setName(req.getParameter("name"));
            u.setEmail(req.getParameter("email"));
            u.setPhone(req.getParameter("phone"));
            u.setPassword(req.getParameter("password"));
            u.setRoleId(Integer.parseInt(req.getParameter("role_id")));
            u.setAddress(req.getParameter("address"));

            String deptParam = req.getParameter("dept_id");
            if (deptParam != null && !deptParam.isEmpty()) {
                u.setDeptId(Integer.parseInt(deptParam));
            } else {
                u.setDeptId(null);
            }

            boolean created = userDao.registerUser(u);
            if (created) {
                resp.sendRedirect("admin/create-authority.jsp?success=true");
            } else {
                resp.sendRedirect("admin/create-authority.jsp?error=true");
            }
            return;
        }

        resp.sendRedirect("admin/dashboard.jsp");
    }
}
