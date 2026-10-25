package com.example.corporatecommute;

import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

import com.example.corporatecommute.models.User;
import com.example.corporatecommute.viewmodels.AuthViewModel;
import com.google.android.material.button.MaterialButton;

public class HomeActivity extends AppCompatActivity {

    private TextView tvWelcomeUser, tvUserEmail;
    private MaterialButton btnLogout;
    private AuthViewModel authViewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        authViewModel = AuthViewModel.getInstance();

        tvWelcomeUser = findViewById(R.id.tvWelcomeUser);
        tvUserEmail = findViewById(R.id.tvUserEmail);
        btnLogout = findViewById(R.id.btnLogout);

        User currentUser = authViewModel.getCurrentUser();
        if (currentUser != null) {
            tvWelcomeUser.setText("Welcome, " + currentUser.getName() + "!");
            tvUserEmail.setText(currentUser.getEmail());
        } else {
            tvWelcomeUser.setText("Welcome, Commuter!");
            tvUserEmail.setText("");
        }

        btnLogout.setOnClickListener(v -> {
            authViewModel.logout();
            Intent intent = new Intent(HomeActivity.this, MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            finish();
        });
    }
}
