import SpeziScheduler
import SwiftUI

struct SimpleTaskView: View {
    let event: Event
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            Text(event.task.title ?? "Task")
                .font(.title)
                .bold()

            Text(event.task.instructions ?? "Complete this task as instructed.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.primary)

            Button(action: onComplete) {
                Text("Mark as Complete")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
        }
        .padding()
    }
}
