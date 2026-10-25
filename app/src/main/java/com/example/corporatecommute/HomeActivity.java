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
    private MaterialButton btnPostRide, btnLogout;
    private AuthViewModel authViewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        authViewModel = AuthViewModel.getInstance();

        tvWelcomeUser = findViewById(R.id.tvWelcomeUser);
        tvUserEmail = findViewById(R.id.tvUserEmail);
        btnPostRide = findViewById(R.id.btnPostRide);
        btnLogout = findViewById(R.id.btnLogout);

        authViewModel.getCurrentUserData(user -> {
            if (user != null) {
                tvWelcomeUser.setText(getString(R.string.welcome_user_format, user.getName()));
                tvUserEmail.setText(user.getEmail());
            } else {
                tvWelcomeUser.setText(R.string.welcome_default);
                tvUserEmail.setText("");
            }
        });

        btnPostRide.setOnClickListener(v -> {
            Intent intent = new Intent(HomeActivity.this, CreateRideActivity.class);
            startActivity(intent);
        });

        btnLogout.setOnClickListener(v -> {
            authViewModel.logout();
            Intent intent = new Intent(HomeActivity.this, MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            finish();
        });
    }
}
