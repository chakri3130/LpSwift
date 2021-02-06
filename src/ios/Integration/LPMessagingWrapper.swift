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

    @objc public convenience init(user: LPUser?, authenticationParams: LPAuthenticationParams?) {
        self.init()
        if BellaLPMessaging.shared == nil {
            BellaLPMessaging.initialize()
        }
        self.setupLPSDKParams(user: user, authParams: authenticationParams)
    }

    @objc public func showChat() {
        BellaLPMessaging.shared.showChat(engagementResponse: nil, entryPoint: .iOSDefault)
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

    
}

