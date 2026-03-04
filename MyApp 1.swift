import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct MyApp: App {
    init() {
        #if os(iOS)
        UINavigationBar.appearance().tintColor = .black
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Shows loading screen first, then transitions to the main app.
private struct RootView: View {
    @State private var showLoading = true

    var body: some View {
        Group {
            if showLoading {
                LoadingView_VectorDuck {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        showLoading = false
                    }
                }
            } else {
                HomePageView()
            }
        }
    }
}
