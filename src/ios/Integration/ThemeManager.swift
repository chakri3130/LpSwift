//
//  ThemeManager.swift
//  Bella Bank
//
//  Created by Luigi Villa on 24/03/2020.
//  Copyright © 2020 Vegan Solutions. All rights reserved.
//

import UIKit
import SceneKit

enum Colors: String {
    case scrollbarBgColor
    case scrollbarCursorColor
    
    case otpStartColor
    case otpEndColor
    
    case buttonTextColor
    
    //splash gradient
    case splashLeftColor1
    case splashLeftColor2
    case splashLeftColor3
    case splashLeftColor4
    
    case splashRightColor1
    case splashRightColor2
    case splashRightColor3
    case splashRightColor4
    
    //progressview colors
    case ProgressViewColor1
    case ProgressViewColor2
    case ProgressViewColor3
    case ProgressViewColor4
    case ProgressViewColor5
    case ProgressViewColor6
    case ProgressViewColor7
    case ProgressViewColor8
    case ProgressViewColor9
    case ProgressViewColor10
    
    // LPMessaging
    case lpcBgInputContainer
    case lpcBgNavigation
    case lpcBgRemoteBubble
    case lpcBgUserBubble
    case lpcBubbleTextColor
    case lpcBgShareIcons
    case lpcShareIconsColor
    case lpcSeparatorTitleBackgroundColor
    
    case textColor
    case lightTextColor
    
    //AlertBackground
    case alertBackground_1
    case alertBackground_2
    case alertBackground_3
    
    // OTP background
    case otpBackground
    case lightishRed
    
    //Button gradient colors
    case salmon
    case fadedOrange
    case grapefruit
    case darkPink
    
    //Test Result color
    case inconclusiveResult
    case positiveResult
    case negativeResult
    
    //Health Assessment
    case yellowMask
}

enum Fonts: String {
    case rubikMediumItalic = "Rubik-MediumItalic"
    case rubikBold = "Rubik-Bold"
    case rubiklLight = "Rubik-Light"
    case rubikMedium = "Rubik-Medium"
    case rubikBlack = "Rubik-Black"
    case rubikLightItalic = "Rubik-LightItalic"
    case rubikBlackItalic = "Rubik-BlackItalic"
    case rubikRegular = "Rubik-Regular"
    case rubikBoldItalic = "Rubik-BoldItalic"
    case rubikItalic = "Rubik-Italic"
}

/// This enum contains all the themes
enum Theme: String {
    case main
    case light
    case dark
}

class ThemeManager: NSObject {
    static let shared: ThemeManager = {
        let themeneManager = ThemeManager()
        return themeneManager
    }()
    
    var forcedTheme: Theme?
    
    var currentTheme: Theme {
        get {
            if let theme = forcedTheme {
                return theme
            } else if let theme = Theme(rawValue: UserDefaultsConfig.theme) {
                return theme
            }
            return .main
        }
    }

    var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme == .light
            ? .default
            : .default
    }
    
    func color(color: Colors) -> UIColor? {
        let named = color.rawValue
        if self.currentTheme == .main {
            return UIColor(named: named)
        } else {
            let colorPrefix = self.currentTheme.rawValue
            return UIColor.init(named: colorPrefix + "_" + named)
        }
    }
    
    func image(named: String) -> UIImage? {
        if self.currentTheme == .main {
            return UIImage(named: named)
        } else {
            let imagePrefix = self.currentTheme.rawValue
            if let toRet = UIImage.init(named: imagePrefix + "_" + named)
            {
                return toRet
            }
            else
            {
                return UIImage.init(named: named)
            }
        }
    }
    
    func font(font: Fonts, size: CGFloat) -> UIFont? {
        let named = font.rawValue
        guard let font = UIFont.init(name: named, size: size) else {
            print("FONT NOT FIND:(\(named)")
            return UIFont.systemFont(ofSize: size)
        }
        
        return font
    }

    func blurStyle() -> UIBlurEffect.Style {
        if self.currentTheme == .main {
            return .dark
        } else {
            return .light
        }
    }
    
    var loaderTint: UIColor {
        return currentTheme == .main ? .white : .black
    }
    
    var tintColor: UIColor? {
        return color(color: .textColor)
    }
    
    var progressViewColors: [UIColor] {
        return [
            ThemeManager.shared.color(color: .ProgressViewColor1),
            ThemeManager.shared.color(color: .ProgressViewColor2),
            ThemeManager.shared.color(color: .ProgressViewColor3),
            ThemeManager.shared.color(color: .ProgressViewColor4),
            ThemeManager.shared.color(color: .ProgressViewColor5),
            ThemeManager.shared.color(color: .ProgressViewColor6),
            ThemeManager.shared.color(color: .ProgressViewColor7),
            ThemeManager.shared.color(color: .ProgressViewColor8),
            ThemeManager.shared.color(color: .ProgressViewColor9),
            ThemeManager.shared.color(color: .ProgressViewColor10)
        ].compactMap({ $0 })
    }
    
    var errorColor: UIColor {
        return UIColor(red: 187/255, green: 31/255, blue: 44/255, alpha: 1.0)
    }
}

//import Lottie
//extension ThemeManager {
//    func lottieAnimation(named: String) -> Animation? {
//        var animationName = named
//        if currentTheme != .main {
//            let prefix = self.currentTheme.rawValue
//            animationName = prefix + "_" + named
//        }
//        return Animation.named(animationName)
//    }
//}
