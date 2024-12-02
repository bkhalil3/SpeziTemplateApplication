import Foundation
import Spezi
import SpeziScheduler
import SpeziViews
import class ModelsR4.Questionnaire
import class ModelsR4.QuestionnaireResponse


@Observable
final class TemplateApplicationScheduler: Module, DefaultInitializable, EnvironmentAccessible {
    @Dependency(Scheduler.self) @ObservationIgnored private var scheduler

    @MainActor var viewState: ViewState = .idle

    init() {
        print("TemplateApplicationScheduler initialized.")
    }

    func configure() {
        guard let scheduler = self.scheduler as? Scheduler else {
            let defaultError = NSError(
                domain: "SchedulerError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Scheduler dependency not available."]
            )
            viewState = .error(AnyLocalizedError(error: defaultError, defaultErrorDescription: "Scheduler dependency not available."))
            return
        }
        
        do {
            try scheduler.createOrUpdateTask(
                id: "health-data-check",
                title: "Health Data Check",
                instructions: "Review your Health Dashboard to track your progress for the day.",
                category: .questionnaire, // Use an appropriate category
                schedule: .daily(hour: 18, minute: 0, startingAt: .today)
            )
        } catch {
            viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
        }
    }
}

extension Task.Context {
    @Property(coding: .json) var questionnaire: Questionnaire?
}

extension Outcome {
    @Property(coding: .json) var questionnaireResponse: QuestionnaireResponse?
}
