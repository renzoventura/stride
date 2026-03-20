//
//  RunFeedView.swift
//  Stride
//
//  Scrollable running feed: 3-column grid (Instagram-style), infinite scroll with debounced next-page load.
//

import SwiftUI

struct RunFeedView: View {
    @Bindable var viewModel: RunFeedViewModel

    var body: some View {
        Group {
            if viewModel.runs.isEmpty, viewModel.isLoading {
                ProgressView("Loading runs…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.runs.isEmpty, let error = viewModel.loadError {
                ContentUnavailableView(
                    "Couldn't load runs",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else {
                runGrid
            }
        }
        .navigationTitle("Runs")
        .task {
            if viewModel.runs.isEmpty {
                await viewModel.loadFirstPage()
            }
        }
    }

    private var runGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0)
            ], spacing: 0) {
                ForEach(viewModel.runs) { item in
                    RunCardView(item: item)
                }
                // Sentinel: when this appears we're near the bottom → debounced load next page.
                nearBottomSentinel
            }
        }
        .scrollIndicators(.hidden)
    }

    /// Invisible view at the end of the list. onAppear triggers debounced next-page fetch (see RunFeedViewModel.didScrollNearBottom).
    private var nearBottomSentinel: some View {
        Color.clear
            .frame(height: 1)
            .onAppear {
                viewModel.didScrollNearBottom()
            }
    }
}

#Preview {
    NavigationStack {
        RunFeedView(viewModel: RunFeedViewModel(session: StravaSession()))
    }
}
