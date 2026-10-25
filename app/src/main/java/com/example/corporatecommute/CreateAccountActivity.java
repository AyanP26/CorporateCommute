package com.example.corporatecommute;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

import com.example.corporatecommute.models.User;
import com.example.corporatecommute.viewmodels.AuthViewModel;
import com.google.android.material.button.MaterialButton;

public class CreateAccountActivity extends AppCompatActivity {

    private EditText etName, etEmail, etPassword, etPhone;
    private TextView tvError;
    private MaterialButton btnSubmit;
    private AuthViewModel authViewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_account);

        authViewModel = AuthViewModel.getInstance();

        etName = findViewById(R.id.etName);
        etEmail = findViewById(R.id.etEmail);
        etPassword = findViewById(R.id.etPassword);
        etPhone = findViewById(R.id.etPhone);
        tvError = findViewById(R.id.tvError);
        btnSubmit = findViewById(R.id.btnSubmit);

        btnSubmit.setOnClickListener(v -> performRegistration());
    }

    private void performRegistration() {
        String name = etName.getText().toString().trim();
        String email = etEmail.getText().toString().trim();
        String password = etPassword.getText().toString();
        String phone = etPhone.getText().toString().trim();

        if (!authViewModel.isRegistrationValid(name, email, password, phone)) {
            tvError.setText(R.string.error_registration);
            tvError.setVisibility(View.VISIBLE);
            return;
        }

        tvError.setVisibility(View.GONE);
        btnSubmit.setEnabled(false);
        btnSubmit.setText(R.string.submitting);

        authViewModel.register(name, email, password, phone, new AuthViewModel.AuthCallback() {
            @Override
            public void onSuccess(User user) {
                Intent intent = new Intent(CreateAccountActivity.this, HomeActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                startActivity(intent);
                finish();
            }

            @Override
            public void onError(String errorMessage) {
                btnSubmit.setEnabled(true);
                btnSubmit.setText(R.string.submit_button);
                tvError.setText(errorMessage);
                tvError.setVisibility(View.VISIBLE);
            }
        });
    }
}
