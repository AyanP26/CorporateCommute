package com.example.corporatecommute;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.corporatecommute.models.RideRequest;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.List;

public class RideRequestAdapter extends RecyclerView.Adapter<RideRequestAdapter.RequestViewHolder> {

    public interface OnRequestActionListener {
        void onAccept(RideRequest request);
        void onDecline(RideRequest request);
    }

    private List<RideRequest> requestList = new ArrayList<>();
    private OnRequestActionListener listener;

    public void setListener(OnRequestActionListener listener) {
        this.listener = listener;
    }

    public void setRequests(List<RideRequest> requests) {
        this.requestList = requests != null ? requests : new ArrayList<>();
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RequestViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_request, parent, false);
        return new RequestViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RequestViewHolder holder, int position) {
        RideRequest request = requestList.get(position);
        holder.bind(request, listener);
    }

    @Override
    public int getItemCount() {
        return requestList.size();
    }

    public static class RequestViewHolder extends RecyclerView.ViewHolder {
        private final TextView tvPassengerName, tvPassengerEmail, tvRoute, tvStatus;
        private final MaterialButton btnAccept, btnDecline;
        private final LinearLayout layoutActions;

        public RequestViewHolder(@NonNull View itemView) {
            super(itemView);
            tvPassengerName = itemView.findViewById(R.id.tvPassengerName);
            tvPassengerEmail = itemView.findViewById(R.id.tvPassengerEmail);
            tvRoute = itemView.findViewById(R.id.tvRoute);
            tvStatus = itemView.findViewById(R.id.tvStatus);
            btnAccept = itemView.findViewById(R.id.btnAccept);
            btnDecline = itemView.findViewById(R.id.btnDecline);
            layoutActions = itemView.findViewById(R.id.layoutActions);
        }

        public void bind(RideRequest request, OnRequestActionListener listener) {
            tvPassengerName.setText(request.getPassengerName() != null ? request.getPassengerName() : "Commuter");
            tvPassengerEmail.setText(request.getPassengerEmail() != null ? request.getPassengerEmail() : "");
            tvRoute.setText("Route: " + request.getRoute());

            String status = request.getStatus() != null ? request.getStatus() : "PENDING";
            tvStatus.setText(status);

            if (status.equals("PENDING")) {
                layoutActions.setVisibility(View.VISIBLE);
                tvStatus.setBackgroundResource(R.drawable.bg_input_field);
            } else {
                layoutActions.setVisibility(View.GONE);
                if (status.equals("ACCEPTED")) {
                    tvStatus.setBackgroundColor(0xFF2E7D32);
                } else {
                    tvStatus.setBackgroundColor(0xFFC62828);
                }
            }

            btnAccept.setOnClickListener(v -> {
                if (listener != null) listener.onAccept(request);
            });

            btnDecline.setOnClickListener(v -> {
                if (listener != null) listener.onDecline(request);
            });
        }
    }
}
