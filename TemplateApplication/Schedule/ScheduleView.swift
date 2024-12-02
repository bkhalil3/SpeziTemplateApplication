@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler
import SpeziSchedulerUI
import SpeziViews
import SwiftUI

struct ScheduleView: View {
    @Environment(Account.self) private var account: Account?
    @Environment(TemplateApplicationScheduler.self) private var scheduler: TemplateApplicationScheduler

    @State private var presentedEvent: Event?
    @Binding private var presentingAccount: Bool

    @State private var completedTaskIds: Set<String> = [] // Track completed task IDs

    var body: some View {
        @Bindable var scheduler = scheduler

        NavigationStack {
            TodayList { event in
                InstructionsTile(event) {
                    HStack {
                        if completedTaskIds.contains(event.task.id ?? "") { // Safeguard for `nil` task.id
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            EventActionButton(event: event, "Start") {
                                presentedEvent = event
                            }
                        }
                    }
                }
            }
            .navigationTitle("Schedule")
            .viewStateAlert(state: $scheduler.viewState)
            .sheet(item: $presentedEvent) { event in
                EventView(event, completedTaskIds: $completedTaskIds) // Pass shared state
            }
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
        .onAppear(perform: loadCompletedTasks)
    }

    private func loadCompletedTasks() {
        let completedTasks = UserDefaults.standard.array(forKey: "completedTasks") as? [String] ?? []
        completedTaskIds = Set(completedTasks)
    }

    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}
