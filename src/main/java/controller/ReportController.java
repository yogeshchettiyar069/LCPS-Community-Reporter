package controller;

import java.io.File;
import java.io.IOException;
import java.util.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.Report;
import model.User;
import operations.ReportOperations;

@WebServlet("/report")
@MultipartConfig
public class ReportController extends HttpServlet {

    ReportOperations ops = new ReportOperations();

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || user.getRoleId() != 2) {
            resp.sendRedirect("login.jsp");
            return;
        }

        Report r = new Report();
        r.setTitle(req.getParameter("title"));
        r.setDescription(req.getParameter("description"));
        r.setSeverity(req.getParameter("severity"));
        r.setLatitude(Double.parseDouble(req.getParameter("latitude")));
        r.setLongitude(Double.parseDouble(req.getParameter("longitude")));
        r.setCitizenId(user.getUserId());
        r.setDeptId(Integer.parseInt(req.getParameter("dept_id")));

        String uploadPath = getServletContext().getRealPath("") +
                File.separator + "uploads" + File.separator + "reports";

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        List<String> imagePaths = new ArrayList<>();

        for (Part part : req.getParts()) {
            if (part.getName().equals("images") && part.getSize() > 0) {

                String fileName = System.currentTimeMillis() + "_" + part.getSubmittedFileName();
                String fullPath = uploadPath + File.separator + fileName;

                part.write(fullPath);

                imagePaths.add("uploads/reports/" + fileName);
            }
        }

        ops.createReport(r, imagePaths);

        resp.sendRedirect("citizen/dashboard.jsp?reported=true");
    }
}
