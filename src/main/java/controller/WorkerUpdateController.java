package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;

import model.User;
import operations.ReportOperations;

@WebServlet("/worker-update")
@MultipartConfig
public class WorkerUpdateController extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        User worker = (User) req.getSession().getAttribute("user");

        if (worker == null || worker.getRoleId() != 4) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String reportIdStr = req.getParameter("reportId");
        String action = req.getParameter("action");   // ✅ SIMPLE & CORRECT

        if (reportIdStr == null || reportIdStr.isEmpty()) {
            resp.sendRedirect("worker/dashboard.jsp");
            return;
        }

        int reportId = Integer.parseInt(reportIdStr);

        ReportOperations ops = new ReportOperations();

        // ================= IN PROGRESS =================
        if ("progress".equals(action)) {

            ops.workerProgressUpdate(
                    reportId,
                    "In Progress",
                    worker.getUserId()
            );
        }

        // ================= COMPLETE =================
        else if ("complete".equals(action)) {

            List<String> imagePaths = new ArrayList<>();

            try {
                // Only here we use getParts()
                for (Part part : req.getParts()) {

                    if ("images".equals(part.getName()) && part.getSize() > 0) {

                        String fileName =
                                UUID.randomUUID() + "_" + part.getSubmittedFileName();

                        String uploadPath =
                                getServletContext().getRealPath("/") + "uploads/";

                        File dir = new File(uploadPath);
                        if (!dir.exists()) dir.mkdirs();

                        // save file
                        part.write(uploadPath + fileName);

                        imagePaths.add("uploads/" + fileName);
                    }
                }
            } catch (ServletException e) {
                throw new RuntimeException("Failed to read uploaded images", e);
            }

            // ✅ update status
            ops.workerComplete(reportId, worker.getUserId());

            // ✅ save AFTER images
            if (!imagePaths.isEmpty()) {
                ops.saveAfterImages(reportId, imagePaths);
            }
        }

        resp.sendRedirect("worker/dashboard.jsp");
    }
}
