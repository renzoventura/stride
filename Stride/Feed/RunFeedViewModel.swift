//
//  RunFeedViewModel.swift
//  Stride
//
//  Fetches runs from Strava with pagination, caches them, and exposes state for the feed UI.
//  Pagination: requests 30 activities per page, filters to type == "Run", stops when a page returns empty.
//  Debouncer: when the UI signals "near bottom", we wait 400ms before loading the next page to avoid duplicate/rapid calls.
//

import Foundation

@MainActor
@Observable
final class RunFeedViewModel {
    var runs: [RunFeedItem] = []
    var isLoading = false
    var loadError: String?
    /// True when we've received an empty page and there are no more runs to fetch.
    var hasReachedEnd = false
    /// When set, navigate to background selection for this run.
    var selectedRunForBackground: RunFeedItem?

    private let session: StravaSession
    /// Current 1-based page for the next request. Cached runs are from pages 1..<(nextPage - 1).
    private var nextPage = 1
    /// Debounce: we only trigger a load after being "near bottom" for this duration (400ms).
    private let nearBottomDebounceDuration: Duration = .milliseconds(400)
    private var nearBottomDebounceTask: Task<Void, Never>?

    init(session: StravaSession) {
        self.session = session
    }

    /// Call when the user scrolls near the bottom. Debounces then loads the next page if not already at end.
    func didScrollNearBottom() {
        guard !hasReachedEnd, !isLoading else { return }
        nearBottomDebounceTask?.cancel()
        nearBottomDebounceTask = Task {
            do {
                try await Task.sleep(for: nearBottomDebounceDuration)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            await loadNextPage()
        }
    }

    /// Loads the first page (e.g. on appear). Resets cache and pagination state.
    func loadFirstPage() async {
        nextPage = 1
        hasReachedEnd = false
        loadError = nil
        runs = []
        await loadNextPage()
    }

    /// Fetches the next page of activities, filters to runs, appends to runs. Stops when page is empty.
    func loadNextPage() async {
        guard !isLoading, !hasReachedEnd else { return }
        guard let token = await session.validAccessToken() else {
            loadError = "Not logged in"
            return
        }
        isLoading = true
        loadError = nil
        defer { isLoading = false }
        do {
            let activities = try await StravaAPIClient.listActivities(accessToken: token, page: nextPage)
            if activities.isEmpty {
                hasReachedEnd = true
                return
            }
            let runsOnly = activities.filter { $0.type.lowercased() == "run" }
            let newItems: [RunFeedItem] = runsOnly.map { RunFeedItem(activity: $0) }
            runs.append(contentsOf: newItems)
            nextPage += 1
            // If we got a full page, there might be more; if we got less than page size, we're done.
            let pageSize = 30
            if activities.count < pageSize {
                hasReachedEnd = true
            }
        } catch StravaAPIClientError.apiError(let code, let message) {
            loadError = "\(code): \(message)"
        } catch {
            loadError = error.localizedDescription
        }
    }
}
