package com.example.corporatecommute;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.corporatecommute.models.RideRequest;

import java.util.ArrayList;
import java.util.List;

public class MyRequestsAdapter extends RecyclerView.Adapter<MyRequestsAdapter.MyRequestViewHolder> {

    private List<RideRequest> requestList = new ArrayList<>();

    public void setRequests(List<RideRequest> requests) {
        this.requestList = requests != null ? requests : new ArrayList<>();
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public MyRequestViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_my_request, parent, false);
        return new MyRequestViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull MyRequestViewHolder holder, int position) {
        RideRequest request = requestList.get(position);
        holder.bind(request);
    }

    @Override
    public int getItemCount() {
        return requestList.size();
    }

    public static class MyRequestViewHolder extends RecyclerView.ViewHolder {
        private final TextView tvRoute, tvStatus, tvStatusMessage;

        public MyRequestViewHolder(@NonNull View itemView) {
            super(itemView);
            tvRoute = itemView.findViewById(R.id.tvRoute);
            tvStatus = itemView.findViewById(R.id.tvStatus);
            tvStatusMessage = itemView.findViewById(R.id.tvStatusMessage);
        }

        public void bind(RideRequest request) {
            tvRoute.setText("Route: " + (request.getRoute() != null ? request.getRoute() : ""));

            String status = request.getStatus() != null ? request.getStatus() : "PENDING";
            tvStatus.setText(status);

            if (status.equals("ACCEPTED")) {
                tvStatus.setBackgroundColor(0xFF2E7D32);
                tvStatusMessage.setText("🎉 Your ride request has been approved by the driver!");
                tvStatusMessage.setTextColor(0xFF81C784);
            } else if (status.equals("DECLINED")) {
                tvStatus.setBackgroundColor(0xFFC62828);
                tvStatusMessage.setText("❌ Your ride request was declined.");
                tvStatusMessage.setTextColor(0xFFE57373);
            } else {
                tvStatus.setBackgroundResource(R.drawable.bg_input_field);
                tvStatusMessage.setText("⏳ Waiting for driver confirmation...");
                tvStatusMessage.setTextColor(0xFFD1D1D1);
            }
        }
    }
}
