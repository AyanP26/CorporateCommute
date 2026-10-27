package com.example.corporatecommute;

import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

import com.example.corporatecommute.models.Ride;
import com.example.corporatecommute.models.User;
import com.example.corporatecommute.viewmodels.AuthViewModel;
import com.google.android.material.button.MaterialButton;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.Calendar;
import java.util.Locale;

public class CreateRideActivity extends AppCompatActivity {

    private EditText etPickup, etDestination, etDate, etTime, etSeats, etNotes;
    private TextView tvError;
    private MaterialButton btnPostRide;
    private AuthViewModel authViewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_ride);

        authViewModel = AuthViewModel.getInstance();

        etPickup = findViewById(R.id.etPickup);
        etDestination = findViewById(R.id.etDestination);
        etDate = findViewById(R.id.etDate);
        etTime = findViewById(R.id.etTime);
        etSeats = findViewById(R.id.etSeats);
        etNotes = findViewById(R.id.etNotes);
        tvError = findViewById(R.id.tvError);
        btnPostRide = findViewById(R.id.btnPostRide);

        setupDateAndTimePickers();

        btnPostRide.setOnClickListener(v -> performPostRide());
    }

    private void setupDateAndTimePickers() {
        etDate.setOnClickListener(v -> {
            Calendar c = Calendar.getInstance();
            int year = c.get(Calendar.YEAR);
            int month = c.get(Calendar.MONTH);
            int day = c.get(Calendar.DAY_OF_MONTH);

            DatePickerDialog datePickerDialog = new DatePickerDialog(this,
                (view, year1, monthOfYear, dayOfMonth) ->
                    etDate.setText(String.format(Locale.US, "%04d-%02d-%02d", year1, monthOfYear + 1, dayOfMonth)),
                year, month, day);
            datePickerDialog.show();
        });

        etTime.setOnClickListener(v -> {
            Calendar c = Calendar.getInstance();
            int hour = c.get(Calendar.HOUR_OF_DAY);
            int minute = c.get(Calendar.MINUTE);

            TimePickerDialog timePickerDialog = new TimePickerDialog(this,
                (view, hourOfDay, minute1) -> {
                    String amPm = hourOfDay >= 12 ? "PM" : "AM";
                    int hour12 = hourOfDay % 12;
                    if (hour12 == 0) hour12 = 12;
                    etTime.setText(String.format(Locale.US, "%02d:%02d %s", hour12, minute1, amPm));
                }, hour, minute, false);
            timePickerDialog.show();
        });
    }

    private void performPostRide() {
        String pickup = etPickup.getText().toString().trim();
        String destination = etDestination.getText().toString().trim();
        String date = etDate.getText().toString().trim();
        String time = etTime.getText().toString().trim();
        String seatsStr = etSeats.getText().toString().trim();
        String notes = etNotes.getText().toString().trim();

        if (pickup.isEmpty() || destination.isEmpty() || date.isEmpty() || time.isEmpty() || seatsStr.isEmpty()) {
            tvError.setText(R.string.error_create_ride);
            tvError.setVisibility(View.VISIBLE);
            return;
        }

        int seats;
        try {
            seats = Integer.parseInt(seatsStr);
            if (seats <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            tvError.setText("Available seats must be a number greater than 0.");
            tvError.setVisibility(View.VISIBLE);
            return;
        }

        tvError.setVisibility(View.GONE);
        btnPostRide.setEnabled(false);
        btnPostRide.setText(R.string.posting_ride);

        User currentUser = authViewModel.getCurrentUser();
        String driverId = currentUser != null ? currentUser.getId() : "anonymous";
        String driverName = currentUser != null ? currentUser.getName() : "Commuter";
        String driverEmail = currentUser != null ? currentUser.getEmail() : "";

        Ride newRide = new Ride(
            null,
            driverId,
            driverName,
            driverEmail,
            pickup,
            destination,
            date,
            time,
            seats,
            notes,
            System.currentTimeMillis()
        );

        FirebaseFirestore.getInstance().collection("rides")
            .add(newRide)
            .addOnSuccessListener(documentReference -> {
                documentReference.update("rideId", documentReference.getId());
                Toast.makeText(this, R.string.ride_posted_success, Toast.LENGTH_SHORT).show();
                finish();
            })
            .addOnFailureListener(e -> {
                btnPostRide.setEnabled(true);
                btnPostRide.setText(R.string.post_ride_button);
                tvError.setText(e.getLocalizedMessage() != null ? e.getLocalizedMessage() : "Failed to post ride.");
                tvError.setVisibility(View.VISIBLE);
            });
    }
}
