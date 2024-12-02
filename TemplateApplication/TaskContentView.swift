import SpeziScheduler
import SpeziQuestionnaire
import SwiftUI

struct TaskContentView: View {
    let event: Event
    @Binding var isCompleted: Bool
    let onComplete: () -> Void

    var body: some View {
        if let questionnaire = event.task.questionnaire {
            HStack {
                Text(event.task.title ?? "Task")
                    .font(.headline)
                    .bold()

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.green)
                }
            }
            .padding()

            if !isCompleted {
                QuestionnaireView(questionnaire: questionnaire) { result in
                    guard case let .completed(response) = result else { return }
                    onComplete()
                }
                .disabled(isCompleted) // Disable interaction if completed
                .opacity(isCompleted ? 0.5 : 1.0) // Dim the questionnaire if completed
            }
        } else {
            SimpleTaskView(event: event, onComplete: onComplete)
        }
    }
}
