import HealthKit
@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler
import SwiftUI

struct HomeView: View {
    enum Tabs: String {
        case schedule
        case contact
        case healthDashboard // Define the Health Dashboard tab
    }

    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.schedule
    @AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization = TabViewCustomization()

    @State private var presentingAccount = false
    @State private var healthPermissionsGranted = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            // Schedule Tab
            ScheduleView(presentingAccount: $presentingAccount)
                .tabItem {
                    Label("Schedule", systemImage: "list.clipboard")
                }
                .tag(Tabs.schedule)
                

            // Contacts Tab
            Contacts(presentingAccount: $presentingAccount)
                .tabItem {
                    Label("Contacts", systemImage: "person.fill")
                }
                .tag(Tabs.contact)
                

            // Health Dashboard Tab
            if healthPermissionsGranted {
                HealthDashboardView()
                    .tabItem {
                        Label("Health Dashboard", systemImage: "waveform.path.ecg")
                    }
                    .tag(Tabs.healthDashboard)
                    
            } else {
                HealthDashboardPermissionView(onPermissionsGranted: {
                    healthPermissionsGranted = true
                }, onPermissionsDenied: handlePermissionDenied)
                    .tabItem {
                        Label("Health Dashboard", systemImage: "waveform.path.ecg")
                    }
                    .tag(Tabs.healthDashboard)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($tabViewCustomization)
        .sheet(isPresented: $presentingAccount) {
            AccountSheet(dismissAfterSignIn: false)
        }
        .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
            AccountSheet()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func handlePermissionDenied(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct HealthDashboardPermissionView: View {
    enum ViewState {
        case requestPermissions
        case requesting
        case granted
    }

    @State private var viewState: ViewState = .requestPermissions

    var onPermissionsGranted: () -> Void
    var onPermissionsDenied: (String, String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            switch viewState {
            case .requestPermissions:
                RequestPermissionsView(viewState: $viewState, onPermissionsGranted: onPermissionsGranted, onPermissionsDenied: onPermissionsDenied)
            case .requesting:
                RequestingPermissionsView()
            case .granted:
                PermissionsGrantedViewWithButton(onPermissionsGranted: onPermissionsGranted)
            }
        }
        .padding()
        .frame(maxWidth: 400)
    }
}

struct RequestPermissionsView: View {
    @Binding var viewState: HealthDashboardPermissionView.ViewState
    var onPermissionsGranted: () -> Void
    var onPermissionsDenied: (String, String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)

            Text("Health Permissions Required")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)

            Text("To provide you with the best experience, we need access to your health data. Please grant the necessary permissions.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            GrantPermissionsButton(viewState: $viewState, onPermissionsGranted: onPermissionsGranted, onPermissionsDenied: onPermissionsDenied)
        }
    }
}

struct GrantPermissionsButton: View {
    @Binding var viewState: HealthDashboardPermissionView.ViewState
    var onPermissionsGranted: () -> Void
    var onPermissionsDenied: (String, String) -> Void

    var body: some View {
        Button(action: {
            requestHealthPermissions()
        }) {
            Text("Grant Permissions")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding()
    }

    private func requestHealthPermissions() {
        viewState = .requesting
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                viewState = .granted
            } else {
                if let error = error {
                    onPermissionsDenied("Permission Error", error.localizedDescription)
                } else {
                    onPermissionsDenied("Permission Denied", "Health permissions were not granted. Please enable them in settings.")
                }
            }
        }
    }
}

struct RequestingPermissionsView: View {
    var body: some View {
        ProgressView("Requesting Permissions...")
            .padding()
    }
}

struct PermissionsGrantedViewWithButton: View {
    var onPermissionsGranted: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            PermissionsGrantedView()
            Button("Continue to Dashboard") {
                onPermissionsGranted()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(12)
            .padding(.top, 20)
        }
    }
}

struct PermissionsGrantedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)

            Text("Permissions Granted!")
                .font(.title2)
                .bold()
                .foregroundColor(.green)


            Text("You're all set to explore your health metrics!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

