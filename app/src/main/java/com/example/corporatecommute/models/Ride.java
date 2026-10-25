package com.example.corporatecommute.models;

import java.io.Serializable;

public class Ride implements Serializable {
    private String rideId;
    private String driverId;
    private String driverName;
    private String driverEmail;
    private String pickupLocation;
    private String destination;
    private String departureDate;
    private String departureTime;
    private int availableSeats;
    private String notes;
    private long createdAt;

    // Required empty constructor for Firestore serialization
    public Ride() {}

    public Ride(String rideId, String driverId, String driverName, String driverEmail,
                String pickupLocation, String destination, String departureDate,
                String departureTime, int availableSeats, String notes, long createdAt) {
        this.rideId = rideId;
        this.driverId = driverId;
        this.driverName = driverName;
        this.driverEmail = driverEmail;
        this.pickupLocation = pickupLocation;
        this.destination = destination;
        this.departureDate = departureDate;
        this.departureTime = departureTime;
        this.availableSeats = availableSeats;
        this.notes = notes;
        this.createdAt = createdAt;
    }

    public String getRideId() {
        return rideId;
    }

    public void setRideId(String rideId) {
        this.rideId = rideId;
    }

    public String getDriverId() {
        return driverId;
    }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getDriverEmail() {
        return driverEmail;
    }

    public void setDriverEmail(String driverEmail) {
        this.driverEmail = driverEmail;
    }

    public String getPickupLocation() {
        return pickupLocation;
    }

    public void setPickupLocation(String pickupLocation) {
        this.pickupLocation = pickupLocation;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public String getDepartureDate() {
        return departureDate;
    }

    public void setDepartureDate(String departureDate) {
        this.departureDate = departureDate;
    }

    public String getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(String departureTime) {
        this.departureTime = departureTime;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(long createdAt) {
        this.createdAt = createdAt;
    }
}
