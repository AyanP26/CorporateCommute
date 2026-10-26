package com.example.corporatecommute;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.corporatecommute.models.Ride;
import com.example.corporatecommute.models.RideRequest;
import com.example.corporatecommute.models.User;
import com.example.corporatecommute.viewmodels.AuthViewModel;
import com.google.android.material.button.MaterialButton;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class HomeActivity extends AppCompatActivity {

    private TextView tvWelcomeUser, tvUserEmail, tvNoRides;
    private MaterialButton btnPostRide, btnViewRequests, btnViewMyRequests, btnLogout;
    private RecyclerView rvRides;
    private RideAdapter rideAdapter;
    private AuthViewModel authViewModel;
    private FirebaseFirestore db;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        authViewModel = AuthViewModel.getInstance();
        db = FirebaseFirestore.getInstance();

        tvWelcomeUser = findViewById(R.id.tvWelcomeUser);
        tvUserEmail = findViewById(R.id.tvUserEmail);
        tvNoRides = findViewById(R.id.tvNoRides);
        btnPostRide = findViewById(R.id.btnPostRide);
        btnViewRequests = findViewById(R.id.btnViewRequests);
        btnViewMyRequests = findViewById(R.id.btnViewMyRequests);
        btnLogout = findViewById(R.id.btnLogout);
        rvRides = findViewById(R.id.rvRides);

        rvRides.setLayoutManager(new LinearLayoutManager(this));
        rideAdapter = new RideAdapter();
        rvRides.setAdapter(rideAdapter);

        rideAdapter.setListener(this::handleRideRequest);

        authViewModel.getCurrentUserData(user -> {
            if (user != null) {
                tvWelcomeUser.setText(getString(R.string.welcome_user_format, user.getName()));
                tvUserEmail.setText(user.getEmail());
                rideAdapter.setCurrentUserId(user.getId());
                fetchUserRideRequests(user.getId());
            } else {
                tvWelcomeUser.setText(R.string.welcome_default);
                tvUserEmail.setText("");
            }
        });

        btnPostRide.setOnClickListener(v -> {
            Intent intent = new Intent(HomeActivity.this, CreateRideActivity.class);
            startActivity(intent);
        });

        btnViewRequests.setOnClickListener(v -> {
            Intent intent = new Intent(HomeActivity.this, ManageRequestsActivity.class);
            startActivity(intent);
        });

        btnViewMyRequests.setOnClickListener(v -> {
            Intent intent = new Intent(HomeActivity.this, MyRequestsActivity.class);
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

    @Override
    protected void onResume() {
        super.onResume();
        loadRidesFromFirestore();
        User currentUser = authViewModel.getCurrentUser();
        if (currentUser != null && currentUser.getId() != null) {
            fetchUserRideRequests(currentUser.getId());
        }
    }

    private void fetchUserRideRequests(String passengerId) {
        if (passengerId == null || passengerId.isEmpty()) return;

        db.collection("ride_requests")
            .whereEqualTo("passengerId", passengerId)
            .get()
            .addOnSuccessListener(queryDocumentSnapshots -> {
                Set<String> requestedRideIds = new HashSet<>();
                for (DocumentSnapshot doc : queryDocumentSnapshots) {
                    String rideId = doc.getString("rideId");
                    if (rideId != null) {
                        requestedRideIds.add(rideId);
                    }
                }
                rideAdapter.setRequestedRideIds(requestedRideIds);
            });
    }

    private void handleRideRequest(Ride ride) {
        User currentUser = authViewModel.getCurrentUser();
        if (currentUser == null) {
            Toast.makeText(this, "Please log in to request a ride.", Toast.LENGTH_SHORT).show();
            return;
        }

        String passengerId = currentUser.getId() != null ? currentUser.getId() : "";
        String passengerName = currentUser.getName() != null ? currentUser.getName() : "Commuter";
        String passengerEmail = currentUser.getEmail() != null ? currentUser.getEmail() : "";
        String route = ride.getPickupLocation() + " -> " + ride.getDestination();

        RideRequest request = new RideRequest(
            null,
            ride.getRideId(),
            ride.getDriverId(),
            passengerId,
            passengerName,
            passengerEmail,
            route,
            "PENDING",
            System.currentTimeMillis()
        );

        db.collection("ride_requests")
            .add(request)
            .addOnSuccessListener(docRef -> {
                docRef.update("requestId", docRef.getId());
                rideAdapter.markRideRequested(ride.getRideId());
                Toast.makeText(this, R.string.request_success_toast, Toast.LENGTH_SHORT).show();
            })
            .addOnFailureListener(e ->
                Toast.makeText(this, "Failed to send request: " + e.getLocalizedMessage(), Toast.LENGTH_SHORT).show()
            );
    }

    private void loadRidesFromFirestore() {
        db.collection("rides")
            .get()
            .addOnSuccessListener(queryDocumentSnapshots -> {
                List<Ride> rides = new ArrayList<>();
                for (DocumentSnapshot doc : queryDocumentSnapshots) {
                    Ride ride = doc.toObject(Ride.class);
                    if (ride != null) {
                        ride.setRideId(doc.getId());
                        rides.add(ride);
                    }
                }

                if (rides.isEmpty()) {
                    seedSampleRides();
                } else {
                    displayRides(rides);
                }
            })
            .addOnFailureListener(e -> seedSampleRides());
    }

    private void seedSampleRides() {
        List<Ride> sampleRides = new ArrayList<>();
        sampleRides.add(new Ride(
            "sample1", "driver1", "Alex Morgan", "alex.morgan@company.com",
            "Reston Station", "Corporate HQ (Tysons)", "2026-10-15", "08:00 AM", 3,
            "EV charging available at HQ. Non-smoking.", System.currentTimeMillis()
        ));

        sampleRides.add(new Ride(
            "sample2", "driver2", "Sarah Chen", "sarah.chen@company.com",
            "Herndon Park & Ride", "Tech Campus (Reston)", "2026-10-15", "08:30 AM", 2,
            "Departs promptly at 8:30 AM.", System.currentTimeMillis()
        ));

        sampleRides.add(new Ride(
            "sample3", "driver3", "Michael Scott", "michael.scott@company.com",
            "Fairfax City Center", "Innovation Center", "2026-10-16", "09:00 AM", 4,
            "Flexible departure time (+/- 10 mins).", System.currentTimeMillis()
        ));

        for (Ride ride : sampleRides) {
            db.collection("rides").add(ride);
        }

        displayRides(sampleRides);
    }

    private void displayRides(List<Ride> rides) {
        if (rides == null || rides.isEmpty()) {
            rvRides.setVisibility(View.GONE);
            tvNoRides.setVisibility(View.VISIBLE);
        } else {
            tvNoRides.setVisibility(View.GONE);
            rvRides.setVisibility(View.VISIBLE);
            rideAdapter.setRides(rides);
        }
    }
}
