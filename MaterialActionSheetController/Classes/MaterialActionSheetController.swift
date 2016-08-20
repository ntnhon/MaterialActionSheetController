//
//  MaterialActionSheetController.swift
//
//  Created by Thanh-Nhon Nguyen on 08/18/2016.
//  Copyright (c) 2016 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

// MARK: Action
public typealias handlerWithAccessoryView = ((accessoryView: UIView?) -> Void)
public struct MaterialAction {
    public let icon: UIImage?
    public let title: String
    public let handler: handlerWithAccessoryView?
    public let accessoryView: UIView?
    public let accessoryHandler: handlerWithAccessoryView?
    public let dismissOnAccessoryTouch: Bool?
    
    public init(icon icon: UIImage?, title: String, handler: handlerWithAccessoryView?, accessoryView: UIView? = nil, dismissOnAccessoryTouch: Bool? = true, accessoryHandler: handlerWithAccessoryView? = nil) {
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
    public var dimBackgroundColor: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
    public var animationDuration: NSTimeInterval = 0.25
    public var titleFont: UIFont = UIFont.systemFontOfSize(15)
    public var titleColor: UIColor = UIColor.blackColor()
    public var messageFont: UIFont = UIFont.systemFontOfSize(12)
    public var messageColor: UIColor = UIColor.darkGrayColor()
    public var textFont: UIFont = UIFont.systemFontOfSize(13)
    public var textColor: UIColor = UIColor.darkGrayColor()
    /// Action's title will be truncated if this is false
    public var wrapText: Bool = true
    public var iconSize: CGSize = CGSize(width: 15, height: 15)
    public var maxHeight: CGFloat = UIScreen.mainScreen().bounds.height*2/3
    public var separatorColor: UIColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
    /// In case there is no header (title and message are both nil)
    public var firstSectionIsHeader: Bool = false
    
    private static var currentTheme = MaterialActionSheetTheme()
}

// MARK: Life cycle
public final class MaterialActionSheetController: UIViewController {
    /// Invoked when MaterialActionSheetController is about to dismiss
    public var willDismiss: (() -> Void)?
    
    /// Invoked when MaterialAcionSheetController is completely dismissed
    public var didDismiss: (() -> Void)?
    
    /// Customizable theme
    public var theme: MaterialActionSheetTheme = MaterialActionSheetTheme() {
        didSet {
            MaterialActionSheetTheme.currentTheme = theme
        }
    }
    
    private let applicationWindow = (UIApplication.sharedApplication().delegate!.window!)!
    private var actions: [MaterialAction] = []
    private var dimBackgroundView = UIView()
    private let tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
    
    private var _title: String?
    private var message: String?
    private var isNoHeader: Bool {
        return _title == nil && message == nil
    }
    private var sections: [[MaterialAction]] = []
    
    /// If title and message are both nil, header is omitted
    public convenience init(title title: String?, message: String?, sections: [MaterialAction]...) {
        self.init()
        self._title = title
        self.message = message
        for section in sections {
            self.sections.append(section)
        }
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
    
    private func dismiss(completion: (() -> Void)? = nil) {
        willDismiss?()
        UIView.animateWithDuration(theme.animationDuration, animations: {[unowned self] in
            self.tableView.frame.origin = CGPoint(x: 0, y: self.applicationWindow.frame.height)
            self.dimBackgroundView.alpha = 0
        }) { [unowned self] (finished) in
            self.tableView.removeFromSuperview()
            self.dimBackgroundView.removeFromSuperview()
            self.dismissViewControllerAnimated(true, completion: {
                completion?()
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
        applicationWindow.addSubview(tableView)
    }
}

// MARK: UITableViewDataSource
/// 
extension MaterialActionSheetController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isNoHeader {
            return sections.count
        }
        
        return sections.count + 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isNoHeader == false && section == 0 {
            return 1
        }
        
        return sections[section - 1].count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isNoHeader == false && indexPath.section == 0 {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("\(MaterialActionSheetHeaderTableViewCell.self)", forIndexPath: indexPath) as! MaterialActionSheetHeaderTableViewCell
            headerCell.bind(title: _title, message: message)
            return headerCell
        }
        
        var action: MaterialAction
        if isNoHeader {
            action = sections[indexPath.section][indexPath.row]
        } else {
            action = sections[indexPath.section - 1][indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("\(MaterialActionSheetTableViewCell.self)", forIndexPath: indexPath) as! MaterialActionSheetTableViewCell
        cell.bind(action: action)
        
        cell.onTapAccessoryView = { [unowned self] in
            action.accessoryHandler?(accessoryView: action.accessoryView)
            if
                let dismissOnAccessoryTouch = action.dismissOnAccessoryTouch
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
        if isNoHeader == false && indexPath.section == 0 {
            return
        }
        
        var action: MaterialAction
        if isNoHeader {
            action = sections[indexPath.section][indexPath.row]
        } else {
            action = sections[indexPath.section - 1][indexPath.row]
        }
        
        action.handler?(accessoryView: action.accessoryView)
        dismiss()
    }
    
    // Add separator between sections
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if numberOfSectionsInTableView(tableView) > 1 {
            return 1
        }
        
        return 0
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        // Last section doesn't have separator
        if numberOfSectionsInTableView(tableView) == (section + 1) {
            return nil
        }
        
        if (isNoHeader && theme.firstSectionIsHeader && section == 0) ||
            (!isNoHeader && section == 0) {
            return longSeparatorView()
        }
        
        return shortSeparatorView()
    }
    
    private func longSeparatorView() -> UIView {
        let lineView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: applicationWindow.frame.size.width, height: 1)))
        lineView.backgroundColor = theme.separatorColor
        return lineView
    }
    
    private func shortSeparatorView() -> UIView {
        let separatorLeadingSpace = 2 * 16 + theme.iconSize.width // 2 * margin + icon's width
        
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: applicationWindow.frame.size.width, height: 1)))
        view.backgroundColor = UIColor.clearColor()
        
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
        iconImageView.image = action.icon
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        
        let margin: CGFloat = 4
        
        // Auto layout titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        titleLabel.font = MaterialActionSheetTheme.currentTheme.titleFont
        titleLabel.textColor = MaterialActionSheetTheme.currentTheme.titleColor

        NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .TrailingMargin, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: margin).active = true
        
        // Auto layout messageLabel
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .Justified
        messageLabel.numberOfLines = 0
        messageLabel.font = MaterialActionSheetTheme.currentTheme.messageFont
        messageLabel.textColor = MaterialActionSheetTheme.currentTheme.messageColor
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