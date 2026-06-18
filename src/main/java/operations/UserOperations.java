package operations;

import implementor.UserDAO;
import model.User;

public class UserOperations {

    UserDAO dao = new UserDAO();

    public boolean register(User u) {
        return dao.registerUser(u);
    }

    public User login(String email, String password, int roleId) {
        return dao.loginUser(email, password, roleId);
    }

}
