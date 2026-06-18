package controller;

import java.io.IOException;
import utils.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.User;
import operations.UserOperations;

@WebServlet("/auth")
public class AuthController extends HttpServlet {

    UserOperations ops = new UserOperations();

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        /* ================= REGISTER ================= */
        if ("register".equals(action)) {

            User u = new User();
            u.setName(req.getParameter("name"));
            u.setEmail(req.getParameter("email"));
            u.setPhone(req.getParameter("phone"));
            u.setPassword(req.getParameter("password"));

            // Safe role_id parsing — hardcoded to 2 (Citizen) from register.jsp
            // but kept flexible here in case admin creates accounts too
            String roleParam = req.getParameter("role_id");
            if (roleParam != null && !roleParam.isEmpty()) {
                u.setRoleId(Integer.parseInt(roleParam));
            } else {
                u.setRoleId(2); // default: Citizen
            }

            // Safe dept_id parsing
            String deptParam = req.getParameter("dept_id");
            if (deptParam != null && !deptParam.isEmpty()) {
                u.setDeptId(Integer.parseInt(deptParam));
            } else {
                u.setDeptId(null);
            }

            u.setAddress(req.getParameter("address"));

            // Generate 6-digit OTP
            int otp = (int) (Math.random() * 900000) + 100000;

            // Store in session
            HttpSession session = req.getSession();
            session.setAttribute("otp",            otp);
            session.setAttribute("otpGeneratedAt", System.currentTimeMillis());
            session.setAttribute("tempUser",        u);

            EmailUtil.sendOTP(u.getEmail(), otp);

            resp.sendRedirect("verify-otp.jsp");
            return;
        }

        /* ================= RESEND OTP ================= */
        if ("resendOtp".equals(action)) {

            HttpSession session = req.getSession();
            User tempUser = (User) session.getAttribute("tempUser");

            // If session lost, send back to register
            if (tempUser == null) {
                resp.sendRedirect("register.jsp");
                return;
            }

            // Generate NEW OTP — overwrites old one, old OTP now invalid
            int newOtp = (int) (Math.random() * 900000) + 100000;

            session.setAttribute("otp",            newOtp);
            session.setAttribute("otpGeneratedAt", System.currentTimeMillis());

            EmailUtil.sendOTP(tempUser.getEmail(), newOtp);

            resp.sendRedirect("verify-otp.jsp?resent=true");
            return;
        }

        /* ================= LOGIN ================= */
        if ("login".equals(action)) {

            String email    = req.getParameter("email");
            String password = req.getParameter("password");
            int    roleId   = Integer.parseInt(req.getParameter("role_id"));

            User u = ops.login(email, password, roleId);

            if (u != null) {

                HttpSession session = req.getSession();
                session.setAttribute("user", u);

                switch (roleId) {
                    case 1: resp.sendRedirect("admin/dashboard.jsp");     break;
                    case 2: resp.sendRedirect("citizen/dashboard.jsp");   break;
                    case 3: resp.sendRedirect("authority/dashboard.jsp"); break;
                    case 4: resp.sendRedirect("worker/dashboard.jsp");    break;
                    default: resp.sendRedirect("login.jsp?error=true");
                }
                return;
            }

            resp.sendRedirect("login.jsp?error=true");
            return;
        }

        // If unknown action
        resp.sendRedirect("login.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("logout".equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // fallback
        res.sendRedirect(req.getContextPath() + "/login.jsp");
    }
}
