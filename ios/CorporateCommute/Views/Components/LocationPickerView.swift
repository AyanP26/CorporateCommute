import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var searchService = LocationSearchService()

    let title: String
    let initialLocation: CommuteLocation?
    let onLocationSelected: (CommuteLocation) -> Void

    @State private var cameraPosition: MapCameraPosition
    @State private var selectedLocation: CommuteLocation
    @State private var isResolving: Bool = false

    init(
        title: String = "Select Location",
        initialLocation: CommuteLocation? = nil,
        onLocationSelected: @escaping (CommuteLocation) -> Void
    ) {
        self.title = title
        self.initialLocation = initialLocation
        self.onLocationSelected = onLocationSelected

        let initial = initialLocation ?? CommuteLocation.corporateHQ
        _selectedLocation = State(initialValue: initial)
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: initial.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            )
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Interactive Apple Map
                Map(position: $cameraPosition) {
                    Marker(selectedLocation.name, coordinate: selectedLocation.coordinate)
                        .tint(AppTheme.accentBlue)
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea()

                // Overlay Controls
                VStack(spacing: 12) {
                    // Search Bar
                    searchBarView
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    // Autocompletion Suggestions Dropdown
                    if !searchService.searchResults.isEmpty {
                        suggestionsList
                            .padding(.horizontal, 16)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else if searchService.searchQuery.isEmpty {
                        // Quick Presets Carousel
                        quickPresetsView
                            .padding(.horizontal, 16)
                    }

                    Spacer()

                    // Floating re-center button & Bottom Confirmation Card
                    VStack(alignment: .trailing, spacing: 14) {
                        HStack {
                            Spacer()
                            Button(action: centerOnCurrentLocation) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppTheme.accentBlue)
                                    .frame(width: 46, height: 46)
                                    .background(Color(red: 0x06 / 255.0, green: 0x09 / 255.0, blue: 0x1A / 255.0).opacity(0.92))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                            }
                            .padding(.trailing, 16)
                        }

                        selectionConfirmationCard
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.textLight)
                }
            }
        }
    }

    // MARK: - Search Bar
    private var searchBarView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.placeholderText)

            TextField("", text: $searchService.searchQuery, prompt: Text("Search location on Apple Maps...").foregroundColor(AppTheme.placeholderText))
                .tint(.white)
                .foregroundColor(AppTheme.textLight)
                .font(.system(size: 14))

            if isResolving || searchService.isSearching {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            } else if !searchService.searchQuery.isEmpty {
                Button(action: { searchService.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.placeholderText)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                .fill(Color(red: 0x06 / 255.0, green: 0x09 / 255.0, blue: 0x1A / 255.0).opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.pillCornerRadius)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 10, y: 5)
    }

    // MARK: - Suggestions Dropdown
    private var suggestionsList: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(searchService.searchResults) { result in
                        Button(action: {
                            selectSearchResult(result)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.accentBlue)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.title)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.textLight)
                                        .lineLimit(1)

                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.placeholderText)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.placeholderText.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }

                        if result != searchService.searchResults.last {
                            Divider()
                                .background(Color.white.opacity(0.08))
                        }
                    }
                }
            }
            .frame(maxHeight: 240)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0x06 / 255.0, green: 0x09 / 255.0, blue: 0x1A / 255.0).opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
    }

    // MARK: - Quick Presets Chips
    private var quickPresetsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CommuteLocation.samplePresets) { preset in
                    let isSelected = selectedLocation.name == preset.name
                    Button(action: {
                        choosePreset(preset)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 11))
                            Text(preset.name.components(separatedBy: " - ").first ?? preset.name)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(isSelected ? .white : AppTheme.textLight.opacity(0.85))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isSelected ? AppTheme.accentBlue : AppTheme.buttonPurple.opacity(0.85))
                                .overlay(
                                    Capsule().stroke(isSelected ? AppTheme.accentBlue : Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
    }

    // MARK: - Selection Confirmation Card
    private var selectionConfirmationCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Circle()
                    .fill(AppTheme.accentBlueSoft)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "map.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.accentBlue)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedLocation.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textLight)
                        .lineLimit(1)

                    Text(selectedLocation.address)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.placeholderText)
                        .lineLimit(2)
                }

                Spacer()
            }

            PrimaryButton(title: "Confirm Location", style: .accent) {
                onLocationSelected(selectedLocation)
                dismiss()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0x06 / 255.0, green: 0x09 / 255.0, blue: 0x1A / 255.0).opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 16, y: 8)
    }

    private func centerOnCurrentLocation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: selectedLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            )
        }
    }

    private func selectSearchResult(_ result: LocationSearchResult) {
        isResolving = true
        searchService.searchQuery = ""
        searchService.searchResults = []

        Task {
            do {
                let resolved = try await searchService.resolveLocation(for: result)
                await MainActor.run {
                    self.selectedLocation = resolved
                    self.isResolving = false
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.cameraPosition = .region(
                            MKCoordinateRegion(
                                center: resolved.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            )
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    self.isResolving = false
                }
            }
        }
    }

    private func choosePreset(_ preset: CommuteLocation) {
        selectedLocation = preset
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: preset.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            )
        }
    }
}
