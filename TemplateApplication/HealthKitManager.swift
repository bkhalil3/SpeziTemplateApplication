import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        let dataTypesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: dataTypesToRead) { success, error in
            completion(success, error)
        }
    }

    // Fetch today's step count
    func fetchStepCount(completion: @escaping (Double, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0.0, nil)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0, error)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()), nil)
        }

        healthStore.execute(query)
    }

    // Fetch today's heart rate average
    func fetchHeartRate(completion: @escaping (Double, Error?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(0.0, nil)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, result, error in
            guard let result = result, let average = result.averageQuantity() else {
                completion(0.0, error)
                return
            }
            completion(average.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())), nil)
        }

        healthStore.execute(query)
    }

    // Fetch today's sleep analysis
    func fetchSleepAnalysis(completion: @escaping ([HKCategorySample], Error?) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([], nil)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 0, sortDescriptors: nil) { _, results, error in
            completion(results as? [HKCategorySample] ?? [], error)
        }

        healthStore.execute(query)
    }
}
