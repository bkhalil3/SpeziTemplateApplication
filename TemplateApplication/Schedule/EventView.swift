import SpeziQuestionnaire
import SpeziScheduler
import SpeziSchedulerUI
import SwiftUI

struct EventView: View {
    private let event: Event

    @Environment(TemplateApplicationStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss
    @Binding var completedTaskIds: Set<String> // Shared state from ScheduleView
    @State private var isCompleted: Bool = false // Local completion state
    @State private var navigateToHealthDashboard: Bool = false // Flag to trigger navigation

    var body: some View {
        if navigateToHealthDashboard {
            HealthDashboardView(onCompletion: handleDashboardCompletion)
        } else {
            VStack(spacing: 20) {
                if isCompleted {
                    CompletedTaskView {
                        dismiss()
                    }
                } else {
                    TaskContentView(event: event, isCompleted: $isCompleted, onComplete: startHealthDashboardCheck)
                }
            }
            .padding()
            .onAppear {
                isCompleted = completedTaskIds.contains(event.task.id)
            }
        }
    }

    private func startHealthDashboardCheck() {
        // Navigate to the Health Dashboard tab
        navigateToHealthDashboard = true
    }

    private func handleDashboardCompletion() {
        // Mark the task as completed and return to CompletedTaskView
        completeTask()
        navigateToHealthDashboard = false
    }

    private func completeTask() {
        let taskId = event.task.id
        isCompleted = true
        completedTaskIds.insert(taskId)
        saveTaskCompletion(taskId: taskId)
    }

    private func saveTaskCompletion(taskId: String) {
        var completedTasks = UserDefaults.standard.array(forKey: "completedTasks") as? [String] ?? []
        if !completedTasks.contains(taskId) {
            completedTasks.append(taskId)
            UserDefaults.standard.set(completedTasks, forKey: "completedTasks")
        }
    }

    init(_ event: Event, completedTaskIds: Binding<Set<String>>) {
        self.event = event
        self._completedTaskIds = completedTaskIds
    }
}

struct CompletedTaskView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)

            Text("Task Completed")
                .font(.title2)
                .bold()
                .foregroundColor(.green)

            Text("You have successfully completed this task.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Back to Schedule") {
                onDismiss()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .transition(.opacity)
    }
}
