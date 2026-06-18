package implementor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Types;

import db_config.DBConnection;
import model.User;

public class UserDAO {

    // REGISTER
    public boolean registerUser(User u) {

        String sql = "INSERT INTO users "
                   + "(name,email,phone,password,role_id,dept_id,address) "
                   + "VALUES (?,?,?,?,?,?,?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPhone());
            ps.setString(4, u.getPassword());
            ps.setInt(5, u.getRoleId());

            if (u.getDeptId() == null) {
                ps.setNull(6, Types.INTEGER);
            } else {
                ps.setInt(6, u.getDeptId());
            }

            ps.setString(7, u.getAddress());

            return ps.executeUpdate() > 0;

        } catch (SQLIntegrityConstraintViolationException dup) {
            // Duplicate email / constraint violation — let the caller show a friendly message
            return false;
        } catch (Exception e) {
            throw new RuntimeException("Failed to register user", e);
        }
    }

    // LOGIN
    public User loginUser(String email, String password, int roleId) {

        String sql = "SELECT user_id, name, email, role_id, dept_id, address "
                   + "FROM users WHERE email=? AND password=? AND role_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim());
            ps.setString(2, password.trim());
            ps.setInt(3, roleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setName(rs.getString("name"));
                    u.setEmail(rs.getString("email"));
                    u.setRoleId(rs.getInt("role_id"));
                    u.setAddress(rs.getString("address"));
                    u.setDeptId(rs.getObject("dept_id", Integer.class));
                    return u;
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Login query failed", e);
        }

        return null;
    }
}
