# Durighe
**Durighe**, as in *du righe*, venetian, a small library to add temporary notices to your apps.

Here is sample of a simple implementation.
Set it up in your App delegate:

    let noticeConfiguration = NoticeConfiguration(
        remoteURL: Bundle.main.url(forResource: "notices", withExtension: "json")!,
        bannerBackground: Color.orange,
        textColor: Color.white,
        overlayColor: Color.black.opacity(0.3),
        refreshInterval: 5
    )
    @main
    struct NotifioApp: App {
        init() {
            NoticeManager.shared.startAutoRefresh(configuration: noticeConfiguration)
        }
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }

And then attach the overlay to your main view

    struct ContentView: View {
        var body: some View {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
            .noticeOverlay(configuration: noticeConfiguration)
        }
    }



