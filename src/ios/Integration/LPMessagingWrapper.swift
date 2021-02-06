//
//  LPMessagingWrapper.swift
//  MyApp
//
//  Created by Omer Berger on 1/20/21.
//

// import UIKit

// public class LPMessagingWrapper: NSObject {
    
//     @objc public func showChat() {
//         if BellaLPMessaging.shared == nil {
//             BellaLPMessaging.initialize()
//         }
//         BellaLPMessaging.shared.showChat(engagementResponse: nil, entryPoint: .iOSDefault)
//     }
// }
//
//  LPMessagingWrapper.swift
//  MyApp
//
//  Created by Omer Berger on 1/20/21.
//

import UIKit
import LPMessagingSDK

public class LPMessagingWrapper: NSObject {
    
    var engagement:LPGetEngagementResponse?
    @objc public convenience init(user: LPUser?, authenticationParams: LPAuthenticationParams?) {
        self.init()
        if BellaLPMessaging.shared == nil {
            BellaLPMessaging.initialize()
        }
        self.setupLPSDKParams(user: user, authParams: authenticationParams)
    }

    private func setupLPSDKParams(user: LPUser?, authParams: LPAuthenticationParams?) {
        if let user = user {
            LPMessaging.instance.setUserProfile(user, brandID: BellaLPMessaging.accountID)
        }

        if let authParams = authParams {
            LPMessaging.instance.setAuthenticationParams(authenticationParams: authParams,
                                                         brandID: BellaLPMessaging.accountID)
        }
    }
    
    deinit {
        let conversationQuery = LPMessaging.instance.getConversationBrandQuery(BellaLPMessaging.accountID)
        LPMessaging.instance.resolveConversation(conversationQuery)
        self.engagement = nil
    }

    @objc public func getEngagement(entryPoints: [String],
                                    completion: ((Bool) -> Void)?) {

        BellaLPMessaging.shared.getEngagement(for: entryPoints) { [weak self](response) in
            
            self?.engagement = response
            completion?(response != nil)
        }
    }

    @objc public func showChat(completion: ((Bool) -> Void)?) {
        BellaLPMessaging.shared.showChat(engagementResponse: self.engagement,
                                         entryPoint: .iOSDefault,
                                         completion: completion)
    }

    @objc public func logOut(completion: ((Bool) -> Void)?) {

    }

    @objc public func clearHistory(completion: ((Bool) -> Void)?) {

    }





}

