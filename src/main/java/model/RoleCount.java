package model;

/** Number of users for a given role (admin dashboard breakdown). */
public class RoleCount {

    private String roleName;
    private int total;

    public String getRoleName() {
        return roleName;
    }
    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public int getTotal() {
        return total;
    }
    public void setTotal(int total) {
        this.total = total;
    }
}
