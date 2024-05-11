import SwiftUI
import Foundation

class TokenManager: ObservableObject {
    static let shared = TokenManager()
    private let maxTokens = 5
    
    @Published var tokens: Int {
        didSet {
            UserDefaults.standard.set(tokens, forKey: "tokens")
        }
    }
    
    @Published var lastRecoveryTime: Date? {
        didSet {
            UserDefaults.standard.set(lastRecoveryTime, forKey: "lastRecoveryTime")
        }
    }
    
    @Published var isChatLogViewOpen = false
    
    private var recoveryInterval: TimeInterval = 5 * 60
    private var timer: Timer?
    @Published var timeRemaining: TimeInterval = 5 * 60
    @Published var formattedTimeRemaining: String = "05:00"
    
    init() {
        tokens = UserDefaults.standard.integer(forKey: "tokens")
        lastRecoveryTime = UserDefaults.standard.object(forKey: "lastRecoveryTime") as? Date
        if lastRecoveryTime == nil {
                let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
                lastRecoveryTime = oneHourAgo
                UserDefaults.standard.set(lastRecoveryTime, forKey: "lastRecoveryTime")
            }
        startTimerIfNeeded()
        updateFormattedTime()
    }
    
    func startTimerIfNeeded() {
        if !isChatLogViewOpen && timeRemaining > 0 {
            startTimer()
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateTimeAndRecoverToken()
        }
    }
    
    func updateTimeAndRecoverToken() {
        guard let lastRecoveryTime = lastRecoveryTime else {
            return
        }
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(lastRecoveryTime)

        if elapsedTime >= recoveryInterval {
            let tokensToRecover = Int(elapsedTime / recoveryInterval)
            timeRemaining = recoveryInterval - (elapsedTime-(Double(tokensToRecover)*recoveryInterval))
            tokens = min(tokensToRecover+tokens, maxTokens)
            saveLastRecoveryTime()
        } else {
            timeRemaining = recoveryInterval - elapsedTime
            tokens = min(tokens, maxTokens)
        }
        updateFormattedTime()
    }
    
    func updateFormattedTime() {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        formattedTimeRemaining = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func useToken() {
        if tokens == 5 {
            saveLastRecoveryTime()
        }
        tokens -= 1
    }
    
    func saveLastRecoveryTime() {
        lastRecoveryTime = Date()
        print(Date())
    }
    
    func recoverTokenIfNeeded() {
        if tokens < 5 {
            tokens += 1
        }
    }
    var isTimerPaused: Bool = false
        
    func pauseTimer() {
        timer?.invalidate()
        isTimerPaused = true
    }
        
    func resumeTimer() {
        isTimerPaused = false
        startTimerIfNeeded()
    }
}

