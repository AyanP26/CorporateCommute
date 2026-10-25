package com.example.corporatecommute;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

import com.example.corporatecommute.models.User;
import com.example.corporatecommute.viewmodels.AuthViewModel;
import com.google.android.material.button.MaterialButton;

public class LoginActivity extends AppCompatActivity {

    private EditText etEmail, etPassword;
    private TextView tvError;
    private MaterialButton btnLogin;
    private AuthViewModel authViewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        authViewModel = AuthViewModel.getInstance();

        etEmail = findViewById(R.id.etEmail);
        etPassword = findViewById(R.id.etPassword);
        tvError = findViewById(R.id.tvError);
        btnLogin = findViewById(R.id.btnLogin);

        btnLogin.setOnClickListener(v -> performLogin());
    }

    private void performLogin() {
        String email = etEmail.getText().toString().trim();
        String password = etPassword.getText().toString();

        if (!authViewModel.isLoginValid(email, password)) {
            tvError.setText(R.string.error_login);
            tvError.setVisibility(View.VISIBLE);
            return;
        }

        tvError.setVisibility(View.GONE);
        btnLogin.setEnabled(false);
        btnLogin.setText(R.string.logging_in);

        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            User user = authViewModel.login(email, password);
            if (user != null) {
                Intent intent = new Intent(LoginActivity.this, HomeActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                startActivity(intent);
                finish();
            } else {
                btnLogin.setEnabled(true);
                btnLogin.setText(R.string.login_button);
                tvError.setText(R.string.error_login);
                tvError.setVisibility(View.VISIBLE);
            }
        }, 500);
    }
}
