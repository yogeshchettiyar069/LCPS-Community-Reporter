package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

import operations.ReportOperations;
import model.User;

@WebServlet("/assign-worker")
public class AssignWorkerController extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        User authority = (User) req.getSession().getAttribute("user");

        if (authority == null || authority.getRoleId() != 3) {
            resp.sendRedirect("login.jsp");
            return;
        }

        int reportId = Integer.parseInt(req.getParameter("reportId"));
        int workerId = Integer.parseInt(req.getParameter("workerId"));

        ReportOperations ops = new ReportOperations();
        ops.assignWorker(reportId, workerId, authority.getUserId());

        resp.sendRedirect("authority/dashboard.jsp");
    }
}
