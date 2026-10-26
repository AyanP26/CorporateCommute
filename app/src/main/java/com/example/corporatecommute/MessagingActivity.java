package com.example.corporatecommute;

import android.os.Bundle;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.corporatecommute.models.Message;
import com.example.corporatecommute.models.User;
import com.example.corporatecommute.viewmodels.AuthViewModel;
import com.google.android.material.button.MaterialButton;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class MessagingActivity extends AppCompatActivity {

    private RecyclerView rvMessages;
    private EditText etMessage;
    private MessageAdapter messageAdapter;
    private FirebaseFirestore db;
    private AuthViewModel authViewModel;
    private String rideId = "general_commuter_chat";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_messaging);

        db = FirebaseFirestore.getInstance();
        authViewModel = AuthViewModel.getInstance();

        MaterialButton btnBack = findViewById(R.id.btnBack);
        MaterialButton btnSend = findViewById(R.id.btnSend);
        etMessage = findViewById(R.id.etMessage);
        rvMessages = findViewById(R.id.rvMessages);
        TextView tvTitle = findViewById(R.id.tvTitle);

        if (getIntent() != null) {
            String passedRideId = getIntent().getStringExtra("RIDE_ID");
            if (passedRideId != null && !passedRideId.isEmpty()) {
                rideId = passedRideId;
            }
            String rideTitle = getIntent().getStringExtra("RIDE_TITLE");
            if (rideTitle != null && !rideTitle.isEmpty()) {
                if (tvTitle != null) {
                    tvTitle.setText(rideTitle);
                }
            } else {
                if (tvTitle != null) {
                    tvTitle.setText("General Chat");
                }
            }
        }

        btnBack.setOnClickListener(v -> finish());

        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setStackFromEnd(true);
        rvMessages.setLayoutManager(layoutManager);

        messageAdapter = new MessageAdapter();
        rvMessages.setAdapter(messageAdapter);

        btnSend.setOnClickListener(v -> sendMessage());

        listenToMessages();
    }

    private void sendMessage() {
        String text = etMessage.getText().toString().trim();
        if (text.isEmpty()) return;

        User currentUser = authViewModel.getCurrentUser();
        String senderId = currentUser != null && currentUser.getId() != null ? currentUser.getId() : "anon";
        String senderName = currentUser != null && currentUser.getName() != null ? currentUser.getName() : "Commuter";
        String senderEmail = currentUser != null && currentUser.getEmail() != null ? currentUser.getEmail() : "";

        Message msg = new Message(
            null,
            rideId,
            senderId,
            senderName,
            senderEmail,
            text,
            System.currentTimeMillis()
        );

        db.collection("messages")
            .add(msg)
            .addOnSuccessListener(docRef -> {
                docRef.update("messageId", docRef.getId());
                etMessage.setText("");
            })
            .addOnFailureListener(e ->
                Toast.makeText(this, "Failed to send: " + e.getLocalizedMessage(), Toast.LENGTH_SHORT).show()
            );
    }

    private void listenToMessages() {
        db.collection("messages")
            .whereEqualTo("rideId", rideId)
            .addSnapshotListener((value, error) -> {
                if (error != null || value == null) return;

                List<Message> messages = new ArrayList<>();
                for (DocumentSnapshot doc : value.getDocuments()) {
                    Message msg = doc.toObject(Message.class);
                    if (msg != null) {
                        msg.setMessageId(doc.getId());
                        messages.add(msg);
                    }
                }

                // Sort messages by timestamp locally in memory to avoid Firestore composite index errors
                Collections.sort(messages, (m1, m2) -> Long.compare(m1.getTimestamp(), m2.getTimestamp()));

                messageAdapter.setMessages(messages);
                if (!messages.isEmpty()) {
                    rvMessages.smoothScrollToPosition(messages.size() - 1);
                }
            });
    }
}
