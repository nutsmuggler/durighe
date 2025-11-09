# Durighe
**Durighe**, as in *du righe*, venetian, a small library to add temporary notices to your apps.

Here is sample of a simple implementation.
Set it up in your App proxy:

    let noticeConfiguration = NoticeConfiguration(
        remoteURL: YOUR_URL,
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

And then attach the overlay to your main view:

    import SwiftUI
    import Durighe
    
    struct ContentView: View {
        @State var notificationActive: Bool = false
        
        var body: some View {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                
                Button(notificationActive ? "Deactivate" : "Activate") {
                    notificationActive.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .noticeOverlay(configuration: noticeConfiguration) {
                notificationActive
            }
        }
    }

Notice that the overlay has a configurations as well as an active block; this can be used to prevent notices form displaying if certain criterias are not met (ie: before an onboarding sequence is completed).

The remote URL must contain a file with this structure:

    [
      {
        "id": "1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D",
        "text": "🍁 Autumn sale! Enjoy 20% off all premium plans until November 15.",
        "startDate": "2025-11-01T00:00:00Z",
        "endDate": "2025-11-15T23:59:59Z",
        "urlString": "https://notabc.app/",
        "imageUrl": "https://notabc.app/assets/images/piano.png",
        "backgroundColorHex": "#4ea872",
        "minimumAppVersion": "1.0.0"
      },
      {
        "id": "A1B2C3D4-E5F6-789A-BCDE-F0123456789A",
        "text": "🌱 New feature: garden planner now supports companion planting!",
        "startDate": "2025-10-15T00:00:00Z",
        "endDate": "2025-12-01T00:00:00Z",
        "urlString": "https://menuplan.app/",
        "imageUrl": "https://notabc.app/assets/images/gramophone.png",
        "backgroundColorHex": "#664ea8"
        
      }
    ]

Some attributes are optional, some are required, check the `Notice` struct for details.
