package com.example.corporatecommute;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
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

public class MyRequestsActivity extends AppCompatActivity {

    private RecyclerView rvMyRequests;
    private TextView tvNoMyRequests;
    private MyRequestsAdapter adapter;
    private FirebaseFirestore db;
    private AuthViewModel authViewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_requests);

        db = FirebaseFirestore.getInstance();
        authViewModel = AuthViewModel.getInstance();

        MaterialButton btnBack = findViewById(R.id.btnBack);
        rvMyRequests = findViewById(R.id.rvMyRequests);
        tvNoMyRequests = findViewById(R.id.tvNoMyRequests);

        btnBack.setOnClickListener(v -> finish());

        rvMyRequests.setLayoutManager(new LinearLayoutManager(this));
        adapter = new MyRequestsAdapter();
        rvMyRequests.setAdapter(adapter);
    }

    @Override
    protected void onResume() {
        super.onResume();
        loadMyRequests();
    }

    private void loadMyRequests() {
        User currentUser = authViewModel.getCurrentUser();
        String currentUserId = currentUser != null ? currentUser.getId() : "";

        db.collection("ride_requests")
            .get()
            .addOnSuccessListener(queryDocumentSnapshots -> {
                List<RideRequest> myRequests = new ArrayList<>();
                for (DocumentSnapshot doc : queryDocumentSnapshots) {
                    RideRequest req = doc.toObject(RideRequest.class);
                    if (req != null) {
                        req.setRequestId(doc.getId());
                        if (currentUserId.isEmpty() || (req.getPassengerId() != null && req.getPassengerId().equals(currentUserId))) {
                            myRequests.add(req);
                        }
                    }
                }

                if (myRequests.isEmpty()) {
                    rvMyRequests.setVisibility(View.GONE);
                    tvNoMyRequests.setVisibility(View.VISIBLE);
                } else {
                    tvNoMyRequests.setVisibility(View.GONE);
                    rvMyRequests.setVisibility(View.VISIBLE);
                    adapter.setRequests(myRequests);
                }
            })
            .addOnFailureListener(e -> {
                rvMyRequests.setVisibility(View.GONE);
                tvNoMyRequests.setVisibility(View.VISIBLE);
            });
    }
}
