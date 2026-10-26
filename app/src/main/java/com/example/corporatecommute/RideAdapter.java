package com.example.corporatecommute;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.corporatecommute.models.Ride;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class RideAdapter extends RecyclerView.Adapter<RideAdapter.RideViewHolder> {

    public interface OnRideRequestListener {
        void onRequestJoin(Ride ride);
    }

    private List<Ride> rideList = new ArrayList<>();
    private final Set<String> requestedRideIds = new HashSet<>();
    private String currentUserId = "";
    private OnRideRequestListener requestListener;

    public void setListener(OnRideRequestListener listener) {
        this.requestListener = listener;
    }

    public void setCurrentUserId(String userId) {
        this.currentUserId = userId != null ? userId : "";
        notifyDataSetChanged();
    }

    public void setRides(List<Ride> rides) {
        this.rideList = rides != null ? rides : new ArrayList<>();
        notifyDataSetChanged();
    }

    public void setRequestedRideIds(Set<String> rideIds) {
        this.requestedRideIds.clear();
        if (rideIds != null) {
            this.requestedRideIds.addAll(rideIds);
        }
        notifyDataSetChanged();
    }

    public void markRideRequested(String rideId) {
        if (rideId != null) {
            this.requestedRideIds.add(rideId);
            notifyDataSetChanged();
        }
    }

    @NonNull
    @Override
    public RideViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_ride, parent, false);
        return new RideViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RideViewHolder holder, int position) {
        Ride ride = rideList.get(position);
        boolean isDriver = currentUserId.equals(ride.getDriverId());
        boolean isRequested = requestedRideIds.contains(ride.getRideId());
        holder.bind(ride, isDriver, isRequested, requestListener);
    }

    @Override
    public int getItemCount() {
        return rideList.size();
    }

    public static class RideViewHolder extends RecyclerView.ViewHolder {
        private final TextView tvDriverName, tvSeats, tvRoute, tvDateTime, tvNotes;
        private final MaterialButton btnRequestJoin;

        public RideViewHolder(@NonNull View itemView) {
            super(itemView);
            tvDriverName = itemView.findViewById(R.id.tvDriverName);
            tvSeats = itemView.findViewById(R.id.tvSeats);
            tvRoute = itemView.findViewById(R.id.tvRoute);
            tvDateTime = itemView.findViewById(R.id.tvDateTime);
            tvNotes = itemView.findViewById(R.id.tvNotes);
            btnRequestJoin = itemView.findViewById(R.id.btnRequestJoin);
        }

        public void bind(Ride ride, boolean isDriver, boolean isRequested, OnRideRequestListener listener) {
            String driverName = ride.getDriverName() != null ? ride.getDriverName() : "Commuter";
            tvDriverName.setText(driverName);

            tvSeats.setText(itemView.getContext().getString(R.string.seats_format, ride.getAvailableSeats()));
            tvRoute.setText(itemView.getContext().getString(R.string.route_format, ride.getPickupLocation(), ride.getDestination()));
            tvDateTime.setText(itemView.getContext().getString(R.string.date_time_format, ride.getDepartureDate(), ride.getDepartureTime()));

            if (ride.getNotes() != null && !ride.getNotes().trim().isEmpty()) {
                tvNotes.setText(ride.getNotes());
                tvNotes.setVisibility(View.VISIBLE);
            } else {
                tvNotes.setVisibility(View.GONE);
            }

            if (isDriver) {
                btnRequestJoin.setText(R.string.your_ride);
                btnRequestJoin.setEnabled(false);
                btnRequestJoin.setAlpha(0.6f);
            } else if (isRequested) {
                btnRequestJoin.setText(R.string.request_sent);
                btnRequestJoin.setEnabled(false);
                btnRequestJoin.setAlpha(0.6f);
            } else {
                btnRequestJoin.setText(R.string.request_join_button);
                btnRequestJoin.setEnabled(true);
                btnRequestJoin.setAlpha(1.0f);
                btnRequestJoin.setOnClickListener(v -> {
                    if (listener != null) {
                        listener.onRequestJoin(ride);
                    }
                });
            }
        }
    }
}
