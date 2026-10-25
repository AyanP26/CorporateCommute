package com.example.corporatecommute;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.corporatecommute.models.Ride;

import java.util.ArrayList;
import java.util.List;

public class RideAdapter extends RecyclerView.Adapter<RideAdapter.RideViewHolder> {

    private List<Ride> rideList = new ArrayList<>();

    public void setRides(List<Ride> rides) {
        this.rideList = rides != null ? rides : new ArrayList<>();
        notifyDataSetChanged();
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
        holder.bind(ride);
    }

    @Override
    public int getItemCount() {
        return rideList.size();
    }

    public static class RideViewHolder extends RecyclerView.ViewHolder {
        private final TextView tvDriverName, tvSeats, tvRoute, tvDateTime, tvNotes;

        public RideViewHolder(@NonNull View itemView) {
            super(itemView);
            tvDriverName = itemView.findViewById(R.id.tvDriverName);
            tvSeats = itemView.findViewById(R.id.tvSeats);
            tvRoute = itemView.findViewById(R.id.tvRoute);
            tvDateTime = itemView.findViewById(R.id.tvDateTime);
            tvNotes = itemView.findViewById(R.id.tvNotes);
        }

        public void bind(Ride ride) {
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
        }
    }
}
