import LPMessagingSDK
import UIKit

typealias LPSDKCompletion = (Bool) -> Void

@objc(livepersonswift) class livepersonswift: CDVPlugin {
    var lpNavigationController: UINavigationController?
    var lpMessagingWrapper: LPMessagingWrapper?
    @objc func instantiateLPMessagingSDK(_ command: CDVInvokedUrlCommand?) {
        if #available(iOS 13.0, *) {
            lpNavigationController?.overrideUserInterfaceStyle = .light
        }
        
        if lpMessagingWrapper == nil {
            self.lpMessagingWrapper = LPMessagingWrapper(
                user: nil,
                authenticationParams: nil)
            let token = command?.arguments[0]

            let pluginResult = CDVPluginResult(
                status: CDVCommandStatus.ok,
                messageAs: "LP_MESSAgging_SDk_has_been_Initialized"
            )
            self.commandDelegate.send(pluginResult, callbackId: command?.callbackId)
        }
    }
    
    @objc func ConnectToBot(_ command: CDVInvokedUrlCommand?) {
        let entryPoints = [
            command?.arguments[0],
            command?.arguments[1],
            command?.arguments[2],
            command?.arguments[3]
        ]
        let SelectedLangugage = UserDefaults.standard.set(command?.argument(at: 2), forKey: "langugage")
        let key_entrypoint = UserDefaults.standard.set(command?.argument(at: 1), forKey: "entryPoint")
        
        if let entryPoints = entryPoints as? [String] {
            self.getEngagementWithCompletionAction(entryPoints: entryPoints) { (completion) in
                let pluginResult = CDVPluginResult(status: .ok, messageAs: "Engegment Success")
                self.commandDelegate.send(pluginResult, callbackId: command?.callbackId)
            }
        }
    }
    
    @objc func showChat(_ command: CDVInvokedUrlCommand) {
        self.showChatWithCompletionAction { (success) in
            let pluginResult = CDVPluginResult(status: .ok, messageAs: "Conversation Opened")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    func getEngagementWithCompletionAction(entryPoints: [String], completionAction: @escaping LPSDKCompletion) {
        self.lpMessagingWrapper?.getEngagement(entryPoints: entryPoints, completion: completionAction)
    }
    
    func showChatWithCompletionAction(_ completion: @escaping LPSDKCompletion) {
        self.lpMessagingWrapper?.showChat(completion: completion)
    }
    
    func logOutWithCompletionAction(_ completion: @escaping LPSDKCompletion) {
        self.lpMessagingWrapper?.logOut(completion: completion)
    }
    
    func clearHistoryWithCompletionAction(_ completion: @escaping LPSDKCompletion) {
        self.lpMessagingWrapper?.clearHistory(completion: completion)
    }
}
