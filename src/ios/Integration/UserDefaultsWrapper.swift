import UIKit
import Combine

/**
Property wrapper per UserDfaults
*/
@propertyWrapper
struct UserDefaultsWrapper<Value>
{
    let key: String
    let defaultValue: Value
    let ubiquo: Bool = false
    
    init(key: String, defaultValue: Value, ubiquo: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: Value {
        get {
            let udValue: Value?
            
            if ubiquo {
                udValue = NSUbiquitousKeyValueStore.default.value(forKey: key) as? Value
            } else {
                udValue = UserDefaults.standard.value(forKey: key) as? Value
            }
            
            switch (udValue as Any) {
            case Optional<Any>.some(let value):
                return value as! Value
            case Optional<Any>.none:
                return defaultValue
            default:
                return udValue ?? defaultValue
            }
        }
        set {
            switch (newValue as Any) {
            case Optional<Any>.some(let value):
                UserDefaults.standard.set(value, forKey: key)
            case Optional<Any>.none:
                UserDefaults.standard.removeObject(forKey: key)
            default:
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }

    
//    var wrappedValue: Value{
//        get{
//            if ubiquo
//            {
//                return (NSUbiquitousKeyValueStore.default.value(forKey: key) as? Value) ?? defaultValue
//            }
//            else
//            {
//                return (UserDefaults.standard.value(forKey: key) as? Value)  ?? defaultValue
//            }
//        }
//        set{
//            if ubiquo
//            {
//                NSUbiquitousKeyValueStore.default.set(newValue, forKey: key)
//                NSUbiquitousKeyValueStore.default.synchronize()
//            }
//            else
//            {
//                UserDefaults.standard.set(newValue, forKey: key)
//                UserDefaults.standard.synchronize()
//            }
//        }
//    }
}
