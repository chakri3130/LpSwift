//
//  LPMessaging.swift
//  Bella Bank
//
//  Created by Mauro Olivo on 09/06/2020.
//  Copyright © 2020 Vegan Solutions. All rights reserved.
//

import Foundation
import LPMessagingSDK

enum LPEntryPoint {
    case iOSDefault
    case faq
    case testingStep1
    case testingStep2
    case testingStep3
    case testingStep4
    case testingStep5
    case testingStep6
    case testingStep7
    
    var entryPoints: [String] {
        switch self {
        case .iOSDefault:
            return  ["ios-default"]
        case .faq:
            return ["ios-faq"]
        case .testingStep1:
            return ["ios-tutorial-step1"]
        case .testingStep2:
            return ["ios-tutorial-step2"]
        case .testingStep3:
            return ["ios-tutorial-step3"]
        case .testingStep4:
            return ["ios-tutorial-step4"]
        case .testingStep5:
            return ["ios-tutorial-step5"]
        case .testingStep6:
            return ["ios-tutorial-step6"]
        case .testingStep7:
            return ["ios-tutorial-step7"]
        }
    }
    
    var welcomeMessage: String {
        switch self {
        case .iOSDefault,
             .faq:
            return "Hi, I'm BELLA, your automated health assistant. I'll be guiding you through your at-home COVID-19 test."
        case .testingStep1:
            return "Have a question about preparing your area?"
        case .testingStep2:
            return "Have a question about test setup?"
        case .testingStep3:
            return "Need some help with your swab?"
        case .testingStep4:
            return "Have a question about processing your test?"
        case .testingStep5:
            return "Have a question about your test result?"
        case .testingStep6:
            return "Want to understand more about reporting your test results?"
        case .testingStep7:
            return "What questions do you have about storing your test kit?"
        }
    }
    
    var quickReplies: [String] {
        switch self {
        case .iOSDefault,
             .faq:
            return ["Start"]
        case .testingStep1:
            return ["Tips when prepping area", "I didn't wash or sanitize", "Missing / damaged items", "Why must I blow my nose?"]
        case .testingStep2:
            return ["Test setup tips", "I spilled liquid", "What's in the liquid?", "I touched the test tube"]
        case .testingStep3:
            return ["How to swab correctly", "My nose is congested", "I only swabbed 1 nostril", "I can't finish swabbing", "Something touched my swab"]
        case .testingStep4:
            return ["I dropped in wrong place", "There's not enough liquid", "I sneezed on the test", "I dropped too many drops", "Test was touched/moved", "Test processing tips", "I opened test 30+ min ago"]
        case .testingStep5:
            return ["I see 2 lines", "I see a faint T line", "Do I need a PCR test?", "What do my results mean?", "Help! I tested positive"]
        case .testingStep6:
            return ["Do I need to retest?", "Who can see my results?", "How do I report results?"]
        case .testingStep7:
            return ["Temperature & weather", "I need to reorder", "Does the test expire?"]
        }
    }
}

class BellaLPMessaging {
    
	static var shared: BellaLPMessaging!// = BellaLPMessaging()
	
	static let accountID: String = "70387001"
	static let issuerID: String = "QMC_iOS" //"Bella Loves Me"
	static let appInstallationId: String = "81be1920-b6cb-450d-87eb-d21b9c90e62f"
	static var isShowing: Bool = false
	
	private var lastEngagementResponse: LPGetEngagementResponse?
	private var engagementRefreshTimer: Timer?
	private var isRefreshingEngagements: Bool = false
	private var onEngagementRecieved: ((_ :LPGetEngagementResponse?)->())? = nil
	
    private var lastCustomerId: String?
    
	init() {
		let monitoringInitParams = LPMonitoringInitParams(appInstallID: BellaLPMessaging.appInstallationId)
		do {
			try LPMessaging.instance.initialize(BellaLPMessaging.accountID, monitoringInitParams: monitoringInitParams)
		} catch {
			debugPrint("Was unable to initialize LPMessagingSDK for account \(BellaLPMessaging.accountID)")
			return
		}
        
        configureConversation()
	}
	
	static func initialize() {
		shared = BellaLPMessaging()
	}
	
	static func logout(success: (() -> Void)? = nil,
                failure: ((_ errors: [Error]) -> Void)? = nil) {
                     
        LPMessaging.instance.logout {
            success?()
        } failure: { (error) in
            failure?(error)
        }
    }
		
	func destroyInstance(completion: (() -> Void)? = nil) {

        debugPrint("Destroy LPMessaging local data")
        LPMessaging.instance.logout(completion: {
            LPMessaging.instance.destruct()
			self.lastEngagementResponse = nil

//            let monitoringInitParams = LPMonitoringInitParams(appInstallID: BellaLPMessaging.appInstallationId)
//
//			do {
//				try LPMessaging.instance.initialize(BellaLPMessaging.accountID, monitoringInitParams: monitoringInitParams)
//			} catch {
//				Logger.err("Was unable to initialize LPMessagingSDK for account \(BellaLPMessaging.accountID)")
//				completion?()
//				return
//			}

			completion?()
		}) { (error) in
			completion?()
            debugPrint("Failed logging out form LPMessagingSDK")
		}
		
    }
    
    func destruct() {
        LPMessaging.instance.destruct()
        BellaLPMessaging.initialize()
    }
    
//    func showChat(entryPoint: LPEntryPoint, customDelegate: LPMessagingSDKdelegate? = nil, in controller: UIViewController? = nil) {
////        let tempCustomerId: String? = nil
////        LPMessaging.instance.setUserProfile(LPUser(firstName: "Saurabh", lastName: "Prajapati", nickName: "SP", uid: tempCustomerId, profileImageURL: nil, phoneNumber: nil, employeeID: nil), brandID: BellaLPMessaging.accountID)
//        
//        guard lastEntryPoint == entryPoint && lastEngagementResponse != nil else {
//            getEngagement(for: entryPoint) {[weak self] (response) in
//                if response != nil {
//                    self?.showChat(entryPoint: entryPoint, customDelegate: customDelegate, in: controller)
//                }
//            }
//            return
//        }
//        
//        showChat(engagementResponse: lastEngagementResponse, entryPoint: entryPoint, customDelegate: customDelegate, in: controller)
////        destruct()
//        
//
//    }
    
    func showChat(engagementResponse: LPGetEngagementResponse?, entryPoint: LPEntryPoint, customDelegate: LPMessagingSDKdelegate? = nil, in controller: UIViewController? = nil) {
        LPMessaging.instance.delegate = customDelegate ?? self

        var conversationQuery = LPMessaging.instance.getConversationBrandQuery(BellaLPMessaging.accountID)
        
        if let campaignId = engagementResponse?.engagementDetails?.first?.campaignId, let engagementId = engagementResponse?.engagementDetails?.first?.engagementId {
            let campaignInfo = LPCampaignInfo(campaignId: campaignId, engagementId: engagementId, contextId: nil, sessionId: engagementResponse?.sessionId, visitorId: engagementResponse?.visitorId)
            conversationQuery = LPMessaging.instance.getConversationBrandQuery(BellaLPMessaging.accountID, campaignInfo: campaignInfo)
        }
                
        let historyControlParam = LPConversationHistoryControlParam(historyConversationsStateToDisplay: .all, historyConversationsMaxDays: -1, historyMaxDaysType: .startConversationDate)
        
        let welcomeMessageParam = LPWelcomeMessage(message: entryPoint.welcomeMessage, frequency: .FirstTimeConversation)
//        welcomeMessageParam.set(NumberOfOptionsPerRow: 2)
        
        do {
            try welcomeMessageParam.set(options: entryPoint.quickReplies.map({ LPMessagingSDK.LPWelcomeMessageOption(value: $0, displayName: $0) }))
            
        } catch let error {
            print("error \(error)")
        }
        
        let conversationViewParams =
            LPConversationViewParams(conversationQuery: conversationQuery,
                                     containerViewController: controller,
                                     isViewOnly: false,
                                     conversationHistoryControlParam: historyControlParam,
                                     welcomeMessage: welcomeMessageParam)
        
//        BellaLPMessaging.configureConversation()
//        configureConversation()

        DispatchQueue.main.async {
            LPMessaging.instance.showConversation(conversationViewParams, authenticationParams: nil)
        }

        BellaLPMessaging.isShowing = true
    }
    
    private func configureConversation() {
        
        let avatar = UIImage(named: "chatAvatar")
        let configurations = LPConfig.defaultConfiguration
        
        configurations.conversationBackgroundColor = .clear
        configurations.conversationBackgroundPortraitImage = UIImage(named: "bgChat")
        
        //Navigation
        // Setting black with alpha 0.4 is not working
        configurations.conversationNavigationBackgroundColor = UIColor(red: 107.0/255.0, green: 120.0/255.0, blue: 120.0/255.0, alpha: 1.0) // ThemeManager.shared.color(color: .lpcBgNavigation) ?? .gray
		//configurations.conversationBackgroundColor = .clear
        configurations.conversationNavigationTitleColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        configurations.systemBubbleTextColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
		configurations.lpNavigationBarLeftItemImageButton = UIImage(named: "lpcClose")
		configurations.lpNavigationBarRightItemImageButton = UIImage(named: "lpcMenuDots")

        //InputTextView
        configurations.inputTextViewContainerBackgroundColor = UIColor(red: 5/255.0, green: 10/255.0, blue: 41/255.0, alpha: 0.0)
		configurations.inputTextViewTopBorderColor = .clear
        configurations.sendButtonDisabledColor = UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.sendButtonEnabledColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
		configurations.sendButtonImage = UIImage(named: "aIc24Send")
        configurations.isSendMessageButtonInTextMode = false
        
        // ConnectionStatus Configuration
        configurations.connectionStatusConnectingBackgroundColor = .clear
        configurations.connectionStatusConnectingTextColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.connectionStatusFailedToConnectTextColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.connectionStatusFailedToConnectBackgroundColor = .clear
        
        // User Bubble
        configurations.userBubbleBackgroundColor = UIColor(red: 168/255.0, green: 68/255.0, blue: 255/255.0, alpha: 1.0)//UIColor(red: 155, green: 84, blue: 246, alpha: 1.0)
        configurations.userBubbleBorderColor = .clear
        configurations.userBubbleLinkColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        configurations.userBubbleTextColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        configurations.userBubbleTimestampColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.userBubbleSendStatusTextColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        // configurations.userBubbleErrorTextColor
        // configurations.userBubbleErrorBorderColor
        
        // Remote user avatar
        configurations.brandAvatarImage = avatar
        configurations.remoteUserDefaultAvatarImage = avatar
        configurations.remoteUserAvatarBackgroundColor = UIColor.clear
        configurations.remoteUserAvatarIconColor = UIColor.clear
        
        // Remote user bubble
        configurations.remoteUserBubbleBackgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        configurations.remoteUserBubbleBorderColor = .clear
        configurations.remoteUserBubbleLinkColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.remoteUserBubbleTextColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.remoteUserBubbleTimestampColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.remoteUserTypingTintColor = UIColor(red: 1.000/255.0, green: 1.000/255.0, blue: 1.000/255.0, alpha: 1.0)

        // Remote user typing indicator
        configurations.announceAgentTyping = true
        configurations.showAgentTypingInMessageBubble = false
        
        // Changes to layout
        configurations.remoteUserAvatarLeadingPadding = 10
        configurations.remoteUserAvatarTrailingPadding = 10
        configurations.bubbleLeadingPadding = 10
        configurations.bubbleTrailingPadding = 10
        configurations.bubbleTimestampTopPadding = 5
        configurations.bubbleTimestampBottomPadding = 20
        
        configurations.enableStructuredContent = true
        configurations.structuredContentBubbleBorderColor = UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.structuredContentTextColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        configurations.structuredContentButtonTextColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.structuredContentButtonBorderColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        
        // Separator Configuration
        configurations.dateSeparatorTitleBackgroundColor =  UIColor(red: 222/255.0, green: 224/255.0, blue: 226/255.0, alpha: 1.0)
        configurations.dateSeparatorTextColor =   UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.dateSeparatorBackgroundColor = .clear
        configurations.dateSeparatorLineBackgroundColor = .clear
        configurations.dateSeparatorTopPadding = 10.0
        configurations.lpDateFormat = "MM/dd/yyyy"
        
        configurations.enableConversationSeparatorTextMessage = false
        configurations.enableConversationSeparatorLine = false
        configurations.conversationSeparatorTextColor = .clear
        
        configurations.conversationSeparatorBottomPadding = 0.0
        configurations.conversationSeparatorTopPadding = 0.0
        configurations.conversationSeparatorViewBottomPadding = 0.0
        
        // Image Sharing Configuration
        
        configurations.fileSharingFromConsumer = true
        configurations.fileSharingFromAgent = true
        configurations.photosharingMenuBackgroundColor =   UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.photosharingMenuButtonsTintColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        configurations.photosharingMenuButtonsTextColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        configurations.photosharingMenuButtonsBackgroundColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)

        //configurations.photoSharingMenuCameraImage
		configurations.cameraButtonEnabledColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        configurations.cameraButtonDisabledColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        
		configurations.photoSharingCloseMenuImageButton = UIImage(named: "lpcClose")
		configurations.photoSharingMenuLibraryImage = UIImage(named: "aIc24Gallery")
		
        //enable voice messages
        configurations.enableAudioSharing = true
        configurations.recordingDurationLimit = 60
        configurations.maxNumberOfSavedAudioFilesOnDisk = 20

        //configurations.fileSharingMenuFileImage
        //configurations.fileCellLoaderFillColor
        //configurations.fileCellLoaderRingProgressColor
        //configurations.fileCellLoaderRingBackgroundColor
        //configurations.maxNumberOfSavedFilesOnDisk
		
        // Read Text Type
        configurations.isReadReceiptTextMode = false//true
        configurations.checkmarkReadColor = .clear
        
        // Font Configuration
        configurations.customFontNameConversationFeed = "Rubik-Regular"
		configurations.customFontNameNonConversationFeed = "Rubik-Regular"
        configurations.customFontNameDateSeparator = "Rubik-Regular"
		
        configurations.toastNotificationsEnabled = false
        
        // Unread Message
        configurations.unreadMessagesDividerEnabled = false
        configurations.unreadMessagesDividerBackgroundColor = .clear
        configurations.unreadMessagesDividerTextColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        
        //csat
        configurations.csatResolutionHidden = false
        configurations.csatThankYouScreenHidden = true
        configurations.csatShowSurveyView = false
        configurations.csatNavigationTitleColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.csatAllTitlesTextColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.csatRatingButtonSelectedColor =  UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.csatResolutionButtonSelectedColor = UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.csatSubmitButtonTextColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        configurations.csatSubmitButtonBackgroundColor =   UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.csatAgentAvatarBackgroundColor = .clear
        configurations.csatAgentAvatarIconColor =   UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.csatNavigationBackgroundColor = .clear

        // LinkPreview
        configurations.enableLinkPreview = true
//        configurations.linkPreviewBorderColor = ThemeManager.shared.color(color: .textColor) ?? .white
//        configurations.linkPreviewBackgroundColor = ThemeManager.shared.color(color: .textColor) ?? .white
//        configurations.linkPreviewTitleTextColor = ThemeManager.shared.color(color: .lpcBubbleTextColor) ?? .white
//        configurations.linkPreviewDescriptionTextColor = ThemeManager.shared.color(color: .lpcBubbleTextColor) ?? .white
//        configurations.linkPreviewSiteNameTextColor = (ThemeManager.shared.color(color: .lpcBubbleTextColor) ?? .white).withAlphaComponent(0.6)
        
        // RealTimeLinkPreview
        // Disable realTimeLinkPreview to achieve clear backgroundColor of the InputTextView
        configurations.enableRealTimeLinkPreview = true
//        configurations.urlRealTimePreviewBackgroundColor = ThemeManager.shared.color(color: .textColor) ?? .white
//        configurations.urlRealTimePreviewBorderColor = ThemeManager.shared.color(color: .textColor) ?? .white
//        configurations.urlRealTimePreviewTitleTextColor = ThemeManager.shared.color(color: .lpcBubbleTextColor) ?? .white
//        configurations.urlRealTimePreviewDescriptionTextColor = ThemeManager.shared.color(color: .lpcBubbleTextColor) ?? .white
        
        // Loading View
        if #available(iOS 13.0, *) {
            let effect = UIBlurEffect(style: .systemUltraThinMaterial)
            configurations.loadingViewBlurEffect = effect
        } else {
            // Fallback on earlier versions
        }

        // To set clear background color of the InputTextView
        configurations.loadingViewBackgroundColor = .clear// ThemeManager.shared.color(color: .lpcBgNavigation) ?? .clear
        configurations.loadingViewProgressTintColor =   UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.loadingViewTextColor =   UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        
        //to show banner like agent will respond soon
		configurations.ttrShouldShow = false
        configurations.ttrShowShiftBanner = false
        configurations.showOffHoursBanner = false
        configurations.ttrShouldShowTimestamp = false
        configurations.ttrBannerBackgroundColor = .clear
		configurations.ttrBannerTextColor =   UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
		
        // scroll to bottom
		configurations.scrollToBottomButtonEnabled = true
        configurations.scrollToBottomButtonMessagePreviewEnabled = false
        configurations.scrollToBottomButtonBadgeBackgroundColor =   UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0) // ThemeManager.shared.color(color: .lpcBgUserBubble) ?? .red
        configurations.scrollToBottomButtonBackgroundColor =   UIColor(red: 52/255.0, green: 60/255.0, blue: 113/255.0, alpha: 1.0)
        configurations.scrollToBottomButtonArrowColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        configurations.scrollToBottomButtonBadgeTextColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    }
	
    private var lastEntryPoint: LPEntryPoint?
    
    func getEngagement(for entryPoint: LPEntryPoint, onEnd: ((_ :LPGetEngagementResponse?)->())?) {
        if entryPoint == lastEntryPoint && lastEngagementResponse != nil {
            onEnd?(lastEngagementResponse)
            return
        }
        
        let identity = LPMonitoringIdentity(consumerID: nil, issuer: BellaLPMessaging.issuerID)
        var entryPoints = entryPoint.entryPoints
        
//        if let envEntryPoint = Environment.entryPoint, !envEntryPoint.isEmpty {
//            entryPoints.append(envEntryPoint)
//        }
        
        let monitoringParams: LPMonitoringParams? = LPMonitoringParams (entryPoints: entryPoints, engagementAttributes: nil)

        LPMessaging.instance.getEngagement(identities: [identity], monitoringParams: monitoringParams) { (getEngagementResponse) in
            self.lastEngagementResponse = getEngagementResponse
            self.lastEntryPoint = entryPoint
            onEnd?(getEngagementResponse)
        } failure: { (error) in
            onEnd?(nil)
        }
    }

    static func onChatDidDismiss(resolveConversation: Bool = false) {
		
		BellaLPMessaging.isShowing = false

		if resolveConversation {
			let conversationQuery = LPMessaging.instance.getConversationBrandQuery(BellaLPMessaging.accountID)
            LPMessaging.instance.resolveConversation(conversationQuery)
		}
		
        LPMessaging.instance.delegate = nil
		
//		MainCoordinator.shared?.rootViewController.resetBadgeView()
		UIApplication.shared.applicationIconBadgeNumber = 0
	}
}

extension BellaLPMessaging: LPMessagingSDKdelegate {
    func LPMessagingSDKConversationViewControllerDidDismiss() {
		BellaLPMessaging.onChatDidDismiss()
    }
    
    // This protocol method are not optional so we need to implement them even if empty
    func LPMessagingSDKObseleteVersion(_ error: NSError) {
        print(error)
    }
    func LPMessagingSDKAuthenticationFailed(_ error: NSError) {
        print(error)
    }
    func LPMessagingSDKTokenExpired(_ brandID: String) {
        print(brandID)
    }
    
    func LPMessagingSDKError(_ error: NSError) {
        print(error)
    }
}
