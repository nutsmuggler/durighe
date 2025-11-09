import Foundation
import SwiftUI


public final class NoticeManager: NSObject, ObservableObject {
    public static let shared = NoticeManager()

    @Published var notices: [Notice] = []

    private let displayedStorageURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("displayed_notices.json")
    }()

    private let cacheStorageURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("notices_cache.json")
    }()

    private var displayedNoticeIDs: Set<UUID> = []

    override init() {
        super.init()
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

    func noticeIsDisplayable(_ notice: Notice) -> Bool {
        let now = Date()
        let isTimeValid = notice.startDate <= now && notice.endDate >= now
        let hasNotBeenDislpayed = !displayedNoticeIDs.contains(notice.id)
        var isForThisVersion = true
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let minVersion = notice.minimumAppVersion {
            isForThisVersion = minVersion.versionCompare(appVersion) != .orderedDescending
        }
        return isTimeValid && hasNotBeenDislpayed && isForThisVersion
    }
    
    @MainActor
    func displayableNotice() -> Notice? {
        let now = Date()
        let available = notices
            .filter { noticeIsDisplayable($0) }
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
    public func startAutoRefresh(configuration: NoticeConfiguration) {
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
    public func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helpers

    func allNotices() -> [Notice] {
        return notices
    }
}
