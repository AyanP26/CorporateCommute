package com.example.corporatecommute.viewmodels;

import com.example.corporatecommute.models.User;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;

public class AuthViewModel {
    private static AuthViewModel instance;
    private final FirebaseAuth mAuth;
    private final FirebaseFirestore db;
    private User currentUser;

    public interface AuthCallback {
        void onSuccess(User user);
        void onError(String errorMessage);
    }

    public interface UserFetchCallback {
        void onFetched(User user);
    }

    private AuthViewModel() {
        mAuth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();
    }

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

    public boolean isAuthenticated() {
        return mAuth.getCurrentUser() != null;
    }

    public void getCurrentUserData(UserFetchCallback callback) {
        FirebaseUser fbUser = mAuth.getCurrentUser();
        if (fbUser == null) {
            this.currentUser = null;
            callback.onFetched(null);
            return;
        }

        if (this.currentUser != null && this.currentUser.getId() != null && this.currentUser.getId().equals(fbUser.getUid())) {
            callback.onFetched(this.currentUser);
            return;
        }

        db.collection("users").document(fbUser.getUid()).get()
            .addOnSuccessListener(documentSnapshot -> {
                if (documentSnapshot.exists()) {
                    User user = documentSnapshot.toObject(User.class);
                    if (user != null) {
                        user.setId(fbUser.getUid());
                    }
                    this.currentUser = user;
                    callback.onFetched(user);
                } else {
                    User fallbackUser = new User(
                        fbUser.getUid(),
                        fbUser.getDisplayName() != null ? fbUser.getDisplayName() : "Commuter",
                        fbUser.getEmail() != null ? fbUser.getEmail() : "",
                        ""
                    );
                    this.currentUser = fallbackUser;
                    callback.onFetched(fallbackUser);
                }
            })
            .addOnFailureListener(e -> {
                User fallbackUser = new User(
                    fbUser.getUid(),
                    fbUser.getDisplayName() != null ? fbUser.getDisplayName() : "Commuter",
                    fbUser.getEmail() != null ? fbUser.getEmail() : "",
                    ""
                );
                this.currentUser = fallbackUser;
                callback.onFetched(fallbackUser);
            });
    }

    public void register(String name, String email, String password, String phoneNumber, AuthCallback callback) {
        if (!isRegistrationValid(name, email, password, phoneNumber)) {
            callback.onError("Please fill in all fields with valid information (password min 6 characters).");
            return;
        }

        String trimmedName = name.trim();
        String trimmedEmail = email.trim().toLowerCase();
        String trimmedPhone = phoneNumber.trim();

        mAuth.createUserWithEmailAndPassword(trimmedEmail, password)
            .addOnCompleteListener(task -> {
                if (task.isSuccessful() && mAuth.getCurrentUser() != null) {
                    String uid = mAuth.getCurrentUser().getUid();
                    User newUser = new User(uid, trimmedName, trimmedEmail, trimmedPhone);

                    db.collection("users").document(uid).set(newUser)
                        .addOnSuccessListener(aVoid -> {
                            this.currentUser = newUser;
                            callback.onSuccess(newUser);
                        })
                        .addOnFailureListener(e -> {
                            this.currentUser = newUser;
                            callback.onSuccess(newUser);
                        });
                } else {
                    String msg = task.getException() != null ? task.getException().getLocalizedMessage() : "Registration failed.";
                    callback.onError(msg);
                }
            });
    }

    public void login(String email, String password, AuthCallback callback) {
        if (!isLoginValid(email, password)) {
            callback.onError("Please enter a valid email and password.");
            return;
        }

        String trimmedEmail = email.trim().toLowerCase();

        mAuth.signInWithEmailAndPassword(trimmedEmail, password)
            .addOnCompleteListener(task -> {
                if (task.isSuccessful() && mAuth.getCurrentUser() != null) {
                    getCurrentUserData(callback::onSuccess);
                } else {
                    String msg = task.getException() != null ? task.getException().getLocalizedMessage() : "Authentication failed.";
                    callback.onError(msg);
                }
            });
    }

    public void logout() {
        mAuth.signOut();
        this.currentUser = null;
    }

    public User getCurrentUser() {
        return currentUser;
    }
}
