package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

import model.User;
import operations.ReportOperations;

@WebServlet("/authority-review")
public class AuthorityReviewController extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        User authority = (User) req.getSession().getAttribute("user");

        if (authority == null || authority.getRoleId() != 3) {
            resp.sendRedirect("login.jsp");
            return;
        }

        int reportId = Integer.parseInt(req.getParameter("reportId"));
        String action = req.getParameter("action");
        String comment = req.getParameter("comment");

        ReportOperations ops = new ReportOperations();

        // ✅ APPROVE
        if ("approve".equals(action)) {

            ops.authorityApprove(reportId, authority.getUserId(), comment);

        }

        // ❌ REJECT
        if ("reject".equals(action)) {

            ops.authorityReject(reportId, authority.getUserId(), comment);

        }

        resp.sendRedirect("authority/dashboard.jsp");
    }
}