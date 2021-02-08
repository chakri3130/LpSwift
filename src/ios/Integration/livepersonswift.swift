@objc(livepersonswift) class livepersonswift : CDVPlugin{
    typealias LPSDKCompletion = (Bool) -> Void
var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
    var LPwrapper:LPMessagingWrapper?
//    var engagement:LPGetEngagementResponse?
@objc(instantiateLPMessagingSDK:) func instantiateLPMessagingSDK(_ command: CDVInvokedUrlCommand) {
var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
    if (self.LPwrapper == nil) {
    LPwrapper = LPMessagingWrapper.init(user: nil, authenticationParams: nil)
    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Messaging wrapper has been initialized successfully")
    }
    else
    {
        ConnectToBot(command)
    }
self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
}

    @objc(ConnectToBot:) func ConnectToBot(_ command: CDVInvokedUrlCommand) {
        
       let engagementCountry = command.arguments[0]  as! String ?? "iOS-default"
       var engagementStep = command.arguments[1] as! String ?? "dev"
       var engagmentLng = command.arguments[2] as! String ?? "us"
       var engagementEnv = command.arguments[3] as! String ?? "es"
        let customEntryPoints = [engagementCountry, engagementStep, engagmentLng, engagementEnv]
        self.LPwrapper?.getEngagement(entryPoints: customEntryPoints) { (result) in
            if(result == true)
            {
            self.LPwrapper?.showChat(completion: { (success) in
                print("success")
            })
            }
        }
        

        
    }
    

//    @objc public func getEngagement(entryPoints: [String],
//                                    completion: ((Bool) -> Void)?) {
//
//
//    }
    
    
    
}
