//
//  MaterialActionSheetController.swift
//
//  Created by Thanh-Nhon Nguyen on 08/18/2016.
//  Copyright (c) 2016 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

// MARK: Action
public typealias HandlerWithAccessoryView = (accessoryView: UIView?) -> Void
public struct MaterialAction {
    public let icon: UIImage?
    public let title: String
    public let handler: HandlerWithAccessoryView?
    public let accessoryView: UIView?
    public let accessoryHandler: HandlerWithAccessoryView?
    public let dismissOnAccessoryTouch: Bool?
    
    public init(icon icon: UIImage?, title: String, handler: HandlerWithAccessoryView?, accessoryView: UIView? = nil, dismissOnAccessoryTouch: Bool? = true, accessoryHandler: HandlerWithAccessoryView? = nil) {
        self.icon = icon
        self.title = title
        self.handler = handler
        self.accessoryView = accessoryView
        self.dismissOnAccessoryTouch = dismissOnAccessoryTouch
        self.accessoryHandler = accessoryHandler
    }
}

// MARK: Appearance
public struct MaterialActionSheetTheme {
    public var dimBackgroundColor: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    public var backgroundColor: UIColor = UIColor.whiteColor()
    public var animationDuration: NSTimeInterval = 0.25
    
    // Header's title label
    public var headerTitleFont: UIFont {
        let fontDescriptiptor = UIFontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold)
        return UIFont(descriptor: fontDescriptiptor, size: 15)
    }
    public var headerTitleColor: UIColor = UIColor.blackColor()
    public var headerTitleAlignment: NSTextAlignment = .Center
    
    // Header's message label
    public var headerMessageFont: UIFont = UIFont.systemFontOfSize(12)
    public var headerMessageColor: UIColor = UIColor.darkGrayColor()
    public var headerMessageAlignment: NSTextAlignment = .Center
    
    // TextLabel
    public var textFont: UIFont = UIFont.systemFontOfSize(13)
    public var textColor: UIColor = UIColor.darkGrayColor()
    public var textAlignment: NSTextAlignment = .Left
    
    /// Long text will be truncated if this is false
    public var wrapText: Bool = true
    
    // IconImageView
    public var iconSize: CGSize = CGSize(width: 15, height: 15)
    /// This will treat your icon as a template and apply iconColor on it. Default is true
    public var useIconImageAsTemplate: Bool = true
    public var iconTemplateColor: UIColor = UIColor.darkGrayColor()
    
    /// Maximum action sheet height
    public var maxHeight: CGFloat = UIScreen.mainScreen().bounds.height*3/4
    public var separatorColor: UIColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
    /// In case there is no header (title and message are both nil)
    public var firstSectionIsHeader: Bool = false
    
    // Singleton
    private static var currentTheme = MaterialActionSheetTheme()
    
    public static func light() -> MaterialActionSheetTheme {
        // Default is light, no need to modify
        return MaterialActionSheetTheme()
    }
    
    public static func dark() -> MaterialActionSheetTheme {
        var darkTheme = MaterialActionSheetTheme()
        darkTheme.dimBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        darkTheme.backgroundColor = UIColor.darkGrayColor()
        darkTheme.headerTitleColor = UIColor.whiteColor()
        darkTheme.headerMessageColor = UIColor.whiteColor()
        darkTheme.textColor = UIColor.whiteColor()
        darkTheme.iconTemplateColor = UIColor.whiteColor()
        return darkTheme
    }
}

// MARK: Life cycle
public final class MaterialActionSheetController: UIViewController {
    /// Invoked when MaterialActionSheetController is about to dismiss
    public var willDismiss: (() -> Void)?
    
    /// Invoked when MaterialAcionSheetController is completely dismissed
    public var didDismiss: (() -> Void)?
    
    /// Custom header view
    public var customHeaderView: UIView?
    
    /// Customizable theme, default is light
    public var theme: MaterialActionSheetTheme = MaterialActionSheetTheme.light()
    
    private let applicationWindow = (UIApplication.sharedApplication().delegate!.window!)!
    private var dimBackgroundView = UIView()
    private let tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
    
    private var headerTitle: String?
    private var headerMessage: String?
    private var noHeader: Bool {
        return headerTitle == nil && headerMessage == nil
    }
    private var actionSections: [[MaterialAction]] = []
    
    /// If header's title and message are both nil, header is omitted
    public convenience init(title title: String?, message: String?, actionSections: [MaterialAction]...) {
        self.init()
        self.headerTitle = title
        self.headerMessage = message
        self.actionSections = actionSections
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = UIModalPresentationStyle.Custom
        modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        MaterialActionSheetTheme.currentTheme = theme
        addDimBackgroundView()
        addTableView()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animateWithDuration(theme.animationDuration) { [unowned self] in
            
            if self.tableView.contentSize.height <= self.theme.maxHeight {
                self.tableView.frame.origin = CGPoint(x: 0, y: self.applicationWindow.frame.height - self.tableView.contentSize.height)
            } else {
                self.tableView.frame.origin = CGPoint(x: 0, y: self.applicationWindow.frame.height - self.theme.maxHeight)
            }
        }
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if tableView.contentSize.height <= theme.maxHeight {
            tableView.frame.size = tableView.contentSize
            tableView.scrollEnabled = false
        } else {
            tableView.frame.size = CGSize(width: tableView.frame.width, height: theme.maxHeight)
            tableView.scrollEnabled = true
        }
    }
    
    private func dismiss() {
        willDismiss?()
        UIView.animateWithDuration(theme.animationDuration, animations: {[unowned self] in
            self.tableView.frame.origin = CGPoint(x: 0, y: self.applicationWindow.frame.height)
            self.dimBackgroundView.alpha = 0
        }) { [unowned self] (finished) in
            self.tableView.removeFromSuperview()
            self.dimBackgroundView.removeFromSuperview()
            self.dismissViewControllerAnimated(false, completion: {
                self.didDismiss?()
            })
        }
    }
    
    // Dim background
    private func addDimBackgroundView() {
        dimBackgroundView = UIView(frame: applicationWindow.frame)
        dimBackgroundView.backgroundColor = theme.dimBackgroundColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(MaterialActionSheetController.dimBackgroundViewTapped))
        dimBackgroundView.userInteractionEnabled = true
        dimBackgroundView.addGestureRecognizer(tap)
        applicationWindow.addSubview(dimBackgroundView)
        dimBackgroundView.alpha = 0
        UIView.animateWithDuration(theme.animationDuration) { [unowned self] in
            self.dimBackgroundView.alpha = 1
        }
    }
    
    @objc private func dimBackgroundViewTapped() {
        dismiss()
    }
    
    // TableView
    private func addTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clearColor()
        tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        tableView.registerClass(MaterialActionSheetTableViewCell.self, forCellReuseIdentifier: "\(MaterialActionSheetTableViewCell.self)")
        tableView.registerClass(MaterialActionSheetHeaderTableViewCell.self, forCellReuseIdentifier: "\(MaterialActionSheetHeaderTableViewCell.self)")
        tableView.frame.origin = CGPoint(x: 0, y: applicationWindow.frame.height)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.separatorColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        applicationWindow.addSubview(tableView)
    }
}

// MARK: UITableViewDataSource
extension MaterialActionSheetController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if noHeader {
            return actionSections.count
        }
        
        return actionSections.count + 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noHeader { // Without header
            return actionSections[section].count
        } else { // With header
            if section == 0 {
                return 1
            } else {
                return actionSections[section - 1].count
            }
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { // With header
        if !noHeader && indexPath.section == 0 {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("\(MaterialActionSheetHeaderTableViewCell.self)", forIndexPath: indexPath) as! MaterialActionSheetHeaderTableViewCell
            headerCell.bind(title: headerTitle, message: headerMessage)
            return headerCell
        }
        
        var action: MaterialAction
        if noHeader {
            action = actionSections[indexPath.section][indexPath.row]
        } else {
            action = actionSections[indexPath.section - 1][indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("\(MaterialActionSheetTableViewCell.self)", forIndexPath: indexPath) as! MaterialActionSheetTableViewCell
        cell.bind(action: action)
        
        cell.onTapAccessoryView = { [unowned self] in
            action.accessoryHandler?(accessoryView: action.accessoryView)
            
            if let dismissOnAccessoryTouch = action.dismissOnAccessoryTouch
                where dismissOnAccessoryTouch == true {
                self.dismiss()
            }
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension MaterialActionSheetController: UITableViewDelegate {
    // Selection logic
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         // Tap at header does nothing
        if !noHeader && indexPath.section == 0 {
            return
        }
        
        var action: MaterialAction
        if noHeader {
            action = actionSections[indexPath.section][indexPath.row]
        } else {
            action = actionSections[indexPath.section - 1][indexPath.row]
        }
        
        action.handler?(accessoryView: action.accessoryView)
        dismiss()
    }
    
    // Add separator between sections
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let customHeaderView = customHeaderView {
            return customHeaderView.bounds.height
        }
        
        return 1
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let customHeaderView = customHeaderView {
            return customHeaderView
        }
        
        return emptyView()
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        // Last section doesn't have separator
        if numberOfSectionsInTableView(tableView) == (section + 1) {
            return emptyView()
        }
        
        if (noHeader && theme.firstSectionIsHeader && section == 0) ||
            (!noHeader && section == 0) {
            return longSeparatorView()
        }
        
        return shortSeparatorView()
    }
    
    private func emptyView() -> UIView {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: applicationWindow.frame.size.width, height: 1)))
        view.backgroundColor = theme.backgroundColor
        return view
    }
    
    private func longSeparatorView() -> UIView {
        let lineView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: applicationWindow.frame.size.width, height: 1)))
        lineView.backgroundColor = theme.separatorColor
        return lineView
    }
    
    private func shortSeparatorView() -> UIView {
        let separatorLeadingSpace = 2 * 16 + theme.iconSize.width // 2 * margin + icon's width
        
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: applicationWindow.frame.size.width, height: 1)))
        view.backgroundColor = theme.backgroundColor
        
        let lineView = UIView(frame: CGRect(origin: CGPoint(x: separatorLeadingSpace, y: 0), size: CGSize(width: applicationWindow.frame.size.width - separatorLeadingSpace, height: 1)))
        lineView.backgroundColor = theme.separatorColor
        
        view.addSubview(lineView)
        return view
    }
}

// MARK: Cells
private final class MaterialActionSheetTableViewCell: UITableViewCell {
    private var iconImageView = UIImageView()
    private var titleLabel = UILabel()
    private var customAccessoryView = UIView()
    private var customAccessoryViewWidthConstraint: NSLayoutConstraint!
    private var customAccessoryViewHeightConstraint: NSLayoutConstraint!
    
    var onTapAccessoryView: (() -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = MaterialActionSheetTheme.currentTheme.backgroundColor
        backgroundColor = MaterialActionSheetTheme.currentTheme.backgroundColor
        iconImageView.tintColor = MaterialActionSheetTheme.currentTheme.iconTemplateColor
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(customAccessoryView)
        
        // Auto layout iconImageView
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: iconImageView, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: iconImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: MaterialActionSheetTheme.currentTheme.iconSize.width).active = true
        NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: MaterialActionSheetTheme.currentTheme.iconSize.height).active = true
        
        // Auto layout titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if MaterialActionSheetTheme.currentTheme.wrapText {
            titleLabel.numberOfLines = 0
        } else {
            titleLabel.numberOfLines = 1
        }
        titleLabel.font = MaterialActionSheetTheme.currentTheme.textFont
        titleLabel.textColor = MaterialActionSheetTheme.currentTheme.textColor
        NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: iconImageView, attribute: .Trailing, multiplier: 1, constant: 15).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: customAccessoryView, attribute: .LeadingMargin, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 10).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -10).active = true
        
        // Auto layout customAccessoryView
        customAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: customAccessoryView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -10).active = true
        NSLayoutConstraint(item: customAccessoryView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        
        customAccessoryViewWidthConstraint = NSLayoutConstraint(item: customAccessoryView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 0)
        customAccessoryViewWidthConstraint.active = true
        
        customAccessoryViewHeightConstraint = NSLayoutConstraint(item: customAccessoryView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 0)
        customAccessoryViewHeightConstraint.active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(action action: MaterialAction) {
        if MaterialActionSheetTheme.currentTheme.useIconImageAsTemplate {
            iconImageView.image = action.icon?.imageWithRenderingMode(.AlwaysTemplate)
        } else {
            iconImageView.image = action.icon
        }
        
        titleLabel.text = action.title
        if let accessoryView = action.accessoryView {
            customAccessoryViewWidthConstraint.constant = accessoryView.bounds.size.width
            customAccessoryViewHeightConstraint.constant = accessoryView.bounds.size.height
            
            
            if let accessoryView = accessoryView as? UIControl {
                accessoryView.addTarget(self, action: #selector(MaterialActionSheetTableViewCell.accessoryViewTapped), forControlEvents: [.TouchUpInside])
            } else {
                let accessoryTap = UITapGestureRecognizer(target: self, action: #selector(MaterialActionSheetTableViewCell.accessoryViewTapped))
                accessoryView.userInteractionEnabled = true
                accessoryView.addGestureRecognizer(accessoryTap)
            }
            
            customAccessoryView.addSubview(accessoryView)
        }
    }
    
    private override func prepareForReuse() {
        super.prepareForReuse()
        // Clean iconImageView and customAccessoryView
        iconImageView.image = nil
        
        for subView in customAccessoryView.subviews {
            subView.removeFromSuperview()
        }
        customAccessoryViewWidthConstraint.constant = 0
        customAccessoryViewHeightConstraint.constant = 0
    }
    
    @objc private func accessoryViewTapped() {
        onTapAccessoryView?()
    }
}

private final class MaterialActionSheetHeaderTableViewCell: UITableViewCell {
    private var titleLabel = UILabel()
    private var messageLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        contentView.backgroundColor = MaterialActionSheetTheme.currentTheme.backgroundColor
        backgroundColor = MaterialActionSheetTheme.currentTheme.backgroundColor
        
        titleLabel.textAlignment = MaterialActionSheetTheme.currentTheme.headerTitleAlignment
        messageLabel.textAlignment = MaterialActionSheetTheme.currentTheme.headerMessageAlignment
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        
        let margin: CGFloat = 4
        
        // Auto layout titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = MaterialActionSheetTheme.currentTheme.headerTitleFont
        titleLabel.textColor = MaterialActionSheetTheme.currentTheme.headerTitleColor

        NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .TrailingMargin, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: margin).active = true
        
        // Auto layout messageLabel
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = MaterialActionSheetTheme.currentTheme.headerMessageFont
        messageLabel.textColor = MaterialActionSheetTheme.currentTheme.headerMessageColor
        NSLayoutConstraint(item: messageLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .BottomMargin, multiplier: 1, constant: 2*margin).active = true
        NSLayoutConstraint(item: messageLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .TrailingMargin, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: messageLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 1).active = true
        NSLayoutConstraint(item: messageLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .BottomMargin, multiplier: 1, constant: 0).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(title title: String?, message: String?) {
        titleLabel.text = title
        messageLabel.text = message
    }
}