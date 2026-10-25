package com.example.corporatecommute.viewmodels;

import com.example.corporatecommute.models.User;

public class AuthViewModel {
    private static AuthViewModel instance;
    private User currentUser;
    private boolean isAuthenticated = false;

    private AuthViewModel() {}

    public static synchronized AuthViewModel getInstance() {
        if (instance == null) {
            instance = new AuthViewModel();
        }
        return instance;
    }

    public boolean isRegistrationValid(String name, String email, String password, String phoneNumber) {
        return name != null && !name.trim().isEmpty() &&
               email != null && email.contains("@") &&
               password != null && password.length() >= 6 &&
               phoneNumber != null && !phoneNumber.trim().isEmpty();
    }

    public boolean isLoginValid(String email, String password) {
        return email != null && email.contains("@") &&
               password != null && password.length() >= 6;
    }

    public User register(String name, String email, String password, String phoneNumber) {
        if (!isRegistrationValid(name, email, password, phoneNumber)) {
            return null;
        }
        User newUser = new User(
            name.trim(),
            email.trim().toLowerCase(),
            phoneNumber.trim()
        );
        this.currentUser = newUser;
        this.isAuthenticated = true;
        return newUser;
    }

    public User login(String email, String password) {
        if (!isLoginValid(email, password)) {
            return null;
        }
        User user = new User(
            "Commuter",
            email.trim().toLowerCase(),
            ""
        );
        this.currentUser = user;
        this.isAuthenticated = true;
        return user;
    }

    public void logout() {
        this.currentUser = null;
        this.isAuthenticated = false;
    }

    public User getCurrentUser() {
        return currentUser;
    }

    public boolean isAuthenticated() {
        return isAuthenticated;
    }
}
