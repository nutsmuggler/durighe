import Foundation
import SwiftUI

@Observable
final class NoticeManager {
    static let shared = NoticeManager()

    private(set) var notices: [Notice] = []

    private let displayedStorageURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("displayed_notices.json")
    }()

    private let cacheStorageURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("notices_cache.json")
    }()

    private var displayedNoticeIDs: Set<UUID> = []

    init() {
        loadDisplayedNotices()
        loadCachedNotices()
    }
    // MARK: - Loading

    func fetchNotices(from url: URL) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let fetched = try decoder.decode([Notice].self, from: data)
        await MainActor.run {
            self.notices = fetched
        }
        saveCache()
    }

    func loadDisplayedNotices() {
        guard let data = try? Data(contentsOf: displayedStorageURL),
              let ids = try? JSONDecoder().decode([UUID].self, from: data)
        else { return }

        displayedNoticeIDs = Set(ids)
    }

    func loadCachedNotices() {
        guard let data = try? Data(contentsOf: cacheStorageURL),
              let cached = try? JSONDecoder().decode([Notice].self, from: data)
        else { return }

        notices = cached
    }

    // MARK: - Displayable Notice

    @MainActor
    func displayableNotice() -> Notice? {
        let now = Date()
        let available = notices
            .filter { notice in
                notice.startDate <= now &&
                notice.endDate >= now &&
                !displayedNoticeIDs.contains(notice.id)
            }
            .sorted(by: { $0.startDate < $1.startDate })

        guard let notice = available.first else { return nil }

        return notice
    }

    // MARK: - Persistence

    private func saveDisplayedNotices() {
        Task.detached {
            if let data = try? await JSONEncoder().encode(Array(self.displayedNoticeIDs)) {
                try? data.write(to: self.displayedStorageURL)
            }
        }
    }

    private func saveCache() {
        Task.detached {
            if let data = try? await JSONEncoder().encode(self.notices) {
                try? data.write(to: self.cacheStorageURL)
            }
        }
    }

    func markAsDisplayed(_ notice: Notice) {
        displayedNoticeIDs.insert(notice.id)
        saveDisplayedNotices()
    }

    // MARK: - Auto Refresh

    private var refreshTask: Task<Void, Never>?

    /// Starts automatic refreshing every `interval` seconds, plus refresh on foreground.
    func startAutoRefresh(configuration: NoticeConfiguration) {
        // Cancel any existing task
        refreshTask?.cancel()

        // Periodic refresh
        refreshTask = Task.detached { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await self.fetchNotices(from: configuration.remoteURL)
                try? await Task.sleep(nanoseconds: UInt64(configuration.refreshInterval * 1_000_000_000))
            }
        }

        // Refresh when app enters foreground
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                try? await self?.fetchNotices(from: configuration.remoteURL)
            }
        }
    }

    /// Stops automatic refresh (optional)
    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helpers

    func allNotices() -> [Notice] {
        return notices
    }
}
