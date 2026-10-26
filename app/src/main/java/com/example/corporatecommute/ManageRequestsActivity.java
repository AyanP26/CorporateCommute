package com.example.corporatecommute;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.corporatecommute.models.RideRequest;
import com.example.corporatecommute.models.User;
import com.example.corporatecommute.viewmodels.AuthViewModel;
import com.google.android.material.button.MaterialButton;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.ArrayList;
import java.util.List;

public class ManageRequestsActivity extends AppCompatActivity {

    private RecyclerView rvRequests;
    private TextView tvNoRequests;
    private RideRequestAdapter requestAdapter;
    private FirebaseFirestore db;
    private AuthViewModel authViewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_manage_requests);

        db = FirebaseFirestore.getInstance();
        authViewModel = AuthViewModel.getInstance();

        MaterialButton btnBack = findViewById(R.id.btnBack);
        rvRequests = findViewById(R.id.rvRequests);
        tvNoRequests = findViewById(R.id.tvNoRequests);

        btnBack.setOnClickListener(v -> finish());

        rvRequests.setLayoutManager(new LinearLayoutManager(this));
        requestAdapter = new RideRequestAdapter();
        rvRequests.setAdapter(requestAdapter);

        requestAdapter.setListener(new RideRequestAdapter.OnRequestActionListener() {
            @Override
            public void onAccept(RideRequest request) {
                updateRequestStatus(request, "ACCEPTED");
            }

            @Override
            public void onDecline(RideRequest request) {
                updateRequestStatus(request, "DECLINED");
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        loadRequests();
    }

    private void loadRequests() {
        User currentUser = authViewModel.getCurrentUser();
        String currentUserId = currentUser != null ? currentUser.getId() : "";

        db.collection("ride_requests")
            .get()
            .addOnSuccessListener(queryDocumentSnapshots -> {
                List<RideRequest> requests = new ArrayList<>();
                for (DocumentSnapshot doc : queryDocumentSnapshots) {
                    RideRequest req = doc.toObject(RideRequest.class);
                    if (req != null) {
                        req.setRequestId(doc.getId());
                        if (currentUserId.isEmpty() || req.getDriverId().equals(currentUserId) || req.getDriverId().equals("driver1")) {
                            requests.add(req);
                        }
                    }
                }

                if (requests.isEmpty()) {
                    rvRequests.setVisibility(View.GONE);
                    tvNoRequests.setVisibility(View.VISIBLE);
                } else {
                    tvNoRequests.setVisibility(View.GONE);
                    rvRequests.setVisibility(View.VISIBLE);
                    requestAdapter.setRequests(requests);
                }
            })
            .addOnFailureListener(e -> {
                rvRequests.setVisibility(View.GONE);
                tvNoRequests.setVisibility(View.VISIBLE);
            });
    }

    private void updateRequestStatus(RideRequest request, String status) {
        if (request.getRequestId() == null) return;

        db.collection("ride_requests").document(request.getRequestId())
            .update("status", status)
            .addOnSuccessListener(aVoid -> {
                Toast.makeText(this, "Request " + status.toLowerCase() + ".", Toast.LENGTH_SHORT).show();
                loadRequests();
            })
            .addOnFailureListener(e ->
                Toast.makeText(this, "Failed to update: " + e.getLocalizedMessage(), Toast.LENGTH_SHORT).show()
            );
    }
}
