import Foundation

struct UserDefaultsConfig {
    
    enum Key: String {
        case appTheme
        case userEmail
        case onboardingSkipped
        case currentScreen
        case isParticipent
        case isDemographicCompleted
    }
    /**
     App theme
     */
    @UserDefaultsWrapper(key: Key.appTheme.rawValue, defaultValue: Theme.main.rawValue)
    static var theme: String
    
    /**
     User Email Address
     */
    @UserDefaultsWrapper(key: Key.userEmail.rawValue, defaultValue: nil)
    static var userEmail: String?
    
    /**
     User Skipped Onboarding
     */
    @UserDefaultsWrapper(key: Key.onboardingSkipped.rawValue, defaultValue: false)
    static var onboardingSkipped: Bool
    
    @UserDefaultsWrapper(key: Key.currentScreen.rawValue, defaultValue: nil)
    static var currentScreen: Int?
    
    @UserDefaultsWrapper(key: Key.isParticipent.rawValue, defaultValue: nil)
    static var isParticipent: Bool?
    
    @UserDefaultsWrapper(key: Key.isDemographicCompleted.rawValue, defaultValue: false)
    static var isDemographicCompleted: Bool
}
