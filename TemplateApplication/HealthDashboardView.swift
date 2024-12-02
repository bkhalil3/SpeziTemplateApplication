import Charts
import HealthKit
import SwiftUI

struct HealthDashboardView: View {
    @State private var stepCount: Double = 0.0
    @State private var heartRate: Double = 0.0
    @State private var sleepHours: Double = 0.0
    @State private var exportURL: URL?

    var onCompletion: (() -> Void)? // Callback to notify when the review is complete

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    metricsSection
                    manualUpdateSection
                    activityTrendsChart
                    sleepAnalysisChart
                    shareReportButton
                    finishReviewButton // Add a button for finishing the review
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .edgesIgnoringSafeArea(.all)
                )
            }
            .navigationTitle("Health Dashboard")
            .onAppear(perform: fetchHealthData) // Ensure the function is called here
        }
    }

    private func fetchHealthData() {
        // Request HealthKit data
        HealthKitManager.shared.fetchStepCount { steps, error in
            if let error = error {
                print("Error fetching step count: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.stepCount = steps
            }
        }

        HealthKitManager.shared.fetchHeartRate { rate, error in
            if let error = error {
                print("Error fetching heart rate: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.heartRate = rate
            }
        }

        HealthKitManager.shared.fetchSleepAnalysis { samples, error in
            if let error = error {
                print("Error fetching sleep analysis: \(error.localizedDescription)")
                return
            }
            let totalHours = samples.reduce(0) { total, sample in
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                return total + duration / 3600 // Convert to hours
            }
            DispatchQueue.main.async {
                self.sleepHours = totalHours
            }
        }
    }

    // MARK: - Finish Review Button
    private var finishReviewButton: some View {
        Button(action: {
            onCompletion?() // Notify parent view that the review is complete
        }) {
            Text("Finish Review")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(12)
                .shadow(radius: 4)
        }
        .padding()
    }
}


// MARK: - Metrics Section
extension HealthDashboardView {
    private var metricsSection: some View {
        VStack(spacing: 15) {
            Text("Your Key Metrics")
                .font(.title2)
                .bold()
                .foregroundColor(.accentColor)
                .padding(.bottom, 5)

            HStack(spacing: 15) {
                MetricCard(title: "Steps", value: "\(Int(stepCount))", icon: "figure.walk", color: .blue)
                MetricCard(title: "Heart Rate", value: "\(Int(heartRate)) bpm", icon: "heart.fill", color: .red)
            }
            MetricCard(title: "Sleep", value: "\(String(format: "%.1f", sleepHours)) hrs", icon: "bed.double.fill", color: .purple)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemGray5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.3), radius: 4)
    }
}

// MARK: - Manual Update Section
extension HealthDashboardView {
    private var manualUpdateSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            manualUpdateHeader
            manualUpdateDescription
            manualUpdateControls
        }
    }

    private var manualUpdateHeader: some View {
        HStack {
            Image(systemName: "slider.horizontal.3")
                .foregroundColor(.accentColor)
            Text("Adjust Your Data")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }

    private var manualUpdateDescription: some View {
        Text("Manually update your health metrics. This feature is optional as the app fetches data automatically.")
            .font(.caption)
            .foregroundColor(.secondary)
    }

    private var manualUpdateControls: some View {
        VStack(spacing: 10) {
            manualUpdateStepper(title: "Steps:", value: $stepCount, range: 0...100_000, step: 1000, unit: "")
            manualUpdateStepper(title: "Heart Rate:", value: $heartRate, range: 0...200, step: 1, unit: " bpm")
            manualUpdateStepper(title: "Sleep:", value: $sleepHours, range: 0...24, step: 0.5, unit: " hrs")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .shadow(color: .gray.opacity(0.3), radius: 2)
    }

    private func manualUpdateStepper(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, unit: String) -> some View {
        HStack {
            Text(title)
            Stepper(value: value, in: range, step: step) {
                Text("\(value.wrappedValue, specifier: "%.0f")\(unit)")
            }
        }
    }
}

// MARK: - Activity Trends Chart
extension HealthDashboardView {
    private var activityTrendsChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Activity and Heart Rate Trends")
                .font(.headline)
                .padding(.bottom, 5)

            Chart {
                stepsLineMarks
                heartRateBarMarks
            }
            .frame(height: 200)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.3), radius: 4)
        }
    }

    private var stepsLineMarks: some ChartContent {
        ForEach(["Morning", "Afternoon", "Evening"], id: \.self) { time in
            LineMark(
                x: .value("Time", time),
                y: .value("Steps", stepsValue(for: time))
            )
            .foregroundStyle(boldColorForStepsTime(time))
            .lineStyle(StrokeStyle(lineWidth: 3))
        }
    }

    private var heartRateBarMarks: some ChartContent {
        ForEach(["Morning", "Afternoon", "Evening"], id: \.self) { time in
            BarMark(
                x: .value("Time", time),
                y: .value("Heart Rate", heartRateValue(for: time))
            )
            .foregroundStyle(boldColorForHeartRateTime(time))
        }
    }

    private func stepsValue(for time: String) -> Double {
        switch time {
        case "Morning": return stepCount / 2
        case "Afternoon": return stepCount * 0.75
        case "Evening": return stepCount
        default: return 0
        }
    }

    private func heartRateValue(for time: String) -> Double {
        switch time {
        case "Morning": return heartRate - 5
        case "Afternoon": return heartRate + 10
        case "Evening": return heartRate
        default: return 0
        }
    }

    private func boldColorForStepsTime(_ time: String) -> Color {
        switch time {
        case "Morning": return .blue.opacity(0.9)
        case "Afternoon": return .green.opacity(0.9)
        case "Evening": return .purple.opacity(0.9)
        default: return .gray.opacity(0.9)
        }
    }

    private func boldColorForHeartRateTime(_ time: String) -> Color {
        switch time {
        case "Morning": return .red.opacity(0.9)
        case "Afternoon": return .orange.opacity(0.9)
        case "Evening": return .pink.opacity(0.9)
        default: return .gray.opacity(0.9)
        }
    }
}

// MARK: - Sleep Analysis Chart
extension HealthDashboardView {
    private var sleepAnalysisChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "moon.fill")
                    .foregroundColor(.purple)
                Text("Sleep Analysis")
                    .font(.headline)
            }

            Chart {
                BarMark(
                    x: .value("Day", "Monday"),
                    y: .value("Hours", sleepHours - 1)
                )
                .foregroundStyle(Color.blue)

                BarMark(
                    x: .value("Day", "Tuesday"),
                    y: .value("Hours", sleepHours + 0.5)
                )
                .foregroundStyle(Color.green)

                BarMark(
                    x: .value("Day", "Wednesday"),
                    y: .value("Hours", sleepHours)
                )
                .foregroundStyle(Color.purple)
            }
            .frame(height: 200)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.3), radius: 4)
        }
    }
}

// MARK: - Share Report
extension HealthDashboardView {
    private var shareReportButton: some View {
        Button(action: generateAndShareReport) {
            Label("Share Report", systemImage: "square.and.arrow.up")
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.green],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 4)
        }
    }

    private func generateAndShareReport() {
        ExportManager.generatePDF(healthData: [
            "Steps": stepCount,
            "HeartRate": heartRate,
            "SleepHours": sleepHours
        ]) { url in
            if let url = url {
                exportURL = url
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(activityVC, animated: true, completion: nil)
                }
            }
        }
    }
}


// MARK: - Metric Card

struct MetricCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color

    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .shadow(color: .gray.opacity(0.3), radius: 4)
    }
}
