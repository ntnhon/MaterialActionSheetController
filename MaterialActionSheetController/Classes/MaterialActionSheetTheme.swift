//
//  MaterialActionSheetController.swift
//
//  Copyright (c) 2016 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

public struct MaterialActionSheetTheme {
    
    public var dimBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.2)
    public var backgroundColor: UIColor = UIColor.white
    public var animationDuration: TimeInterval = 0.25
    public var pulseAnimationOnSelection: Bool = true
    public var pulseColor: UIColor = UIColor.lightGray.withAlphaComponent(0.2)
    
    // Header's title label
    public var headerTitleFont: UIFont {
        let fontDescriptiptor = UIFontDescriptor().withSymbolicTraits(.traitBold)
        return UIFont(descriptor: fontDescriptiptor!, size: 15)
    }
    public var headerTitleColor: UIColor = UIColor.black
    public var headerTitleAlignment: NSTextAlignment = .center
    
    // Header's message label
    public var headerMessageFont: UIFont = UIFont.systemFont(ofSize: 12)
    public var headerMessageColor: UIColor = UIColor.darkGray
    public var headerMessageAlignment: NSTextAlignment = .center
    
    // TextLabel
    public var textFont: UIFont = UIFont.systemFont(ofSize: 13)
    public var textColor: UIColor = UIColor.darkGray
    public var textAlignment: NSTextAlignment = .left
    
    /// Long text will be truncated if this is false
    public var wrapText: Bool = true
    
    // IconImageView
    public var iconSize: CGSize = CGSize(width: 15, height: 15)
    /// This will treat your icon as a template and apply iconColor on it. Default is true
    public var useIconImageAsTemplate: Bool = true
    public var iconTemplateColor: UIColor = UIColor.darkGray
    
    /// Maximum action sheet height
    public var maxHeight: CGFloat = UIScreen.main.bounds.height*3/4
    public var separatorColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)
    /// In case there is no header (title and message are both nil)
    public var firstSectionIsHeader: Bool = false
    
    // Singleton instance
    internal static var currentTheme = MaterialActionSheetTheme()
    
    public static func light() -> MaterialActionSheetTheme {
        // Default is light, no need to modify
        return MaterialActionSheetTheme()
    }
    
    public static func dark() -> MaterialActionSheetTheme {
        var darkTheme = MaterialActionSheetTheme()
        darkTheme.dimBackgroundColor = UIColor.black.withAlphaComponent(0.6)
        darkTheme.backgroundColor = UIColor.darkGray
        darkTheme.headerTitleColor = UIColor.white
        darkTheme.headerMessageColor = UIColor.white
        darkTheme.textColor = UIColor.white
        darkTheme.iconTemplateColor = UIColor.white
        darkTheme.pulseColor = UIColor.white.withAlphaComponent(0.2)
        return darkTheme
    }
    
}
