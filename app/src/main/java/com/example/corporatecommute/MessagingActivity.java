package com.example.corporatecommute;

import android.os.Bundle;
import android.widget.EditText;
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
import com.google.firebase.firestore.Query;

import java.util.ArrayList;
import java.util.List;

public class MessagingActivity extends AppCompatActivity {

    private RecyclerView rvMessages;
    private EditText etMessage;
    private MessageAdapter messageAdapter;
    private FirebaseFirestore db;
    private AuthViewModel authViewModel;

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
            .orderBy("timestamp", Query.Direction.ASCENDING)
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
                messageAdapter.setMessages(messages);
                if (!messages.isEmpty()) {
                    rvMessages.smoothScrollToPosition(messages.size() - 1);
                }
            });
    }
}
