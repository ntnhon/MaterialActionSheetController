//
//  MaterialActionSheetController.swift
//
//  Created by Thanh-Nhon Nguyen on 08/18/2016.
//  Copyright (c) 2016 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

// MARK: Action
public typealias HandlerWithAccessoryView = (_ accessoryView: UIView?) -> Void
public struct MaterialAction {
    public let icon: UIImage?
    public let title: String
    public let handler: HandlerWithAccessoryView?
    public let accessoryView: UIView?
    public let accessoryHandler: HandlerWithAccessoryView?
    public let dismissOnAccessoryTouch: Bool?
    
    public init(icon: UIImage?, title: String, handler: HandlerWithAccessoryView?, accessoryView: UIView? = nil, dismissOnAccessoryTouch: Bool? = true, accessoryHandler: HandlerWithAccessoryView? = nil) {
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
    public var dimBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.2)
    public var backgroundColor: UIColor = UIColor.white
    public var animationDuration: TimeInterval = 0.25
    
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
    
    // Singleton
    fileprivate static var currentTheme = MaterialActionSheetTheme()
    
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
    
    fileprivate let applicationWindow = (UIApplication.shared.delegate!.window!)!
    fileprivate var dimBackgroundView = UIView()
    fileprivate let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
    fileprivate var tableViewContentSizeObserver: NSKeyValueObservation?
    
    public var message: String?
    fileprivate var noHeader: Bool {
        return title == nil && message == nil
    }
    public var actionSections: [[MaterialAction]] = []
    
    /// If header's title and message are both nil, header is omitted
    public convenience init(title: String?, message: String?, actionSections: [MaterialAction]...) {
        self.init()
        self.title = title
        self.message = message
        self.actionSections = actionSections
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = UIModalPresentationStyle.custom
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        MaterialActionSheetTheme.currentTheme = theme
        addDimBackgroundView()
        addTableView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAddTable()
    }
    
    fileprivate func animateAddTable() {
        UIView.animate(withDuration: theme.animationDuration, animations: { [unowned self] in
            if self.tableView.contentSize.height <= self.theme.maxHeight {
                self.tableView.frame.origin = CGPoint(x: 0, y: self.applicationWindow.frame.height - self.tableView.contentSize.height)
            } else {
                self.tableView.frame.origin = CGPoint(x: 0, y: self.applicationWindow.frame.height - self.theme.maxHeight)
            }
        })
    }

    deinit {
        print("MaterialActionSheetController is deallocated")
    }

    fileprivate func dismiss() {
        willDismiss?()
        tableViewContentSizeObserver?.invalidate()
        tableViewContentSizeObserver = nil
        
        UIView.animate(withDuration: theme.animationDuration, animations: {[unowned self] in
            self.tableView.frame.origin = CGPoint(x: 0, y: self.applicationWindow.frame.height)
            self.dimBackgroundView.alpha = 0
        }, completion: { [unowned self] (finished) in
            self.tableView.removeFromSuperview()
            self.dimBackgroundView.removeFromSuperview()
            self.dismiss(animated: false, completion: {
                self.didDismiss?()
            })
        }) 
    }
    
    // Dim background
    fileprivate func addDimBackgroundView() {
        dimBackgroundView = UIView(frame: applicationWindow.frame)
        dimBackgroundView.backgroundColor = theme.dimBackgroundColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(MaterialActionSheetController.dimBackgroundViewTapped))
        dimBackgroundView.isUserInteractionEnabled = true
        dimBackgroundView.addGestureRecognizer(tap)
        applicationWindow.addSubview(dimBackgroundView)
        dimBackgroundView.alpha = 0
        UIView.animate(withDuration: theme.animationDuration, animations: { [unowned self] in
            self.dimBackgroundView.alpha = 1
        }) 
    }
    
    @objc fileprivate func dimBackgroundViewTapped() {
        dismiss()
    }
    
    // TableView
    fileprivate func addTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clear
        
        tableViewContentSizeObserver = tableView.observe(\UITableView.contentSize, options: .new, changeHandler: { [unowned self] (tableView, _) in
            if self.tableView.contentSize.height <= self.theme.maxHeight {
                self.tableView.frame.size = tableView.contentSize
                self.tableView.isScrollEnabled = false
            } else {
                self.tableView.frame.size = CGSize(width: tableView.frame.width, height: self.theme.maxHeight)
                self.tableView.isScrollEnabled = true
            }
        })

        tableView.register(MaterialActionSheetTableViewCell.self, forCellReuseIdentifier: "\(MaterialActionSheetTableViewCell.self)")
        tableView.register(MaterialActionSheetHeaderTableViewCell.self, forCellReuseIdentifier: "\(MaterialActionSheetHeaderTableViewCell.self)")
        
        tableView.frame.origin = CGPoint(x: 0, y: applicationWindow.frame.height)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        applicationWindow.addSubview(tableView)
    }
}

// MARK: UITableViewDataSource
extension MaterialActionSheetController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        if noHeader {
            return actionSections.count
        }
        
        return actionSections.count + 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // With header
        if !noHeader && (indexPath as NSIndexPath).section == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "\(MaterialActionSheetHeaderTableViewCell.self)", for: indexPath) as! MaterialActionSheetHeaderTableViewCell
            headerCell.bind(title: title, message: message)
            return headerCell
        }
        
        var action: MaterialAction
        if noHeader {
            action = actionSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        } else {
            action = actionSections[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(MaterialActionSheetTableViewCell.self)", for: indexPath) as! MaterialActionSheetTableViewCell
        cell.bind(action: action)
        
        cell.onTapAccessoryView = { [unowned self] in
            action.accessoryHandler?(action.accessoryView)
            
            if let dismissOnAccessoryTouch = action.dismissOnAccessoryTouch,
                dismissOnAccessoryTouch == true {
                self.dismiss()
            }
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension MaterialActionSheetController: UITableViewDelegate {
    // Selection logic
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         // Tap at header does nothing
        if !noHeader && (indexPath as NSIndexPath).section == 0 {
            return
        }
        
        var action: MaterialAction
        if noHeader {
            action = actionSections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        } else {
            action = actionSections[(indexPath as NSIndexPath).section - 1][(indexPath as NSIndexPath).row]
        }
        
        action.handler?(action.accessoryView)
        dismiss()
    }
    
    // Add separator between sections
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let customHeaderView = customHeaderView {
            return customHeaderView.bounds.height
        }
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let customHeaderView = customHeaderView {
            return customHeaderView
        }
        
        return emptyView()
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        // Last section doesn't have separator
        if numberOfSections(in: tableView) == (section + 1) {
            return emptyView()
        }
        
        if (noHeader && theme.firstSectionIsHeader && section == 0) ||
            (!noHeader && section == 0) {
            return longSeparatorView()
        }
        
        return shortSeparatorView()
    }
    
    fileprivate func emptyView() -> UIView {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: applicationWindow.frame.size.width, height: 1)))
        view.backgroundColor = theme.backgroundColor
        return view
    }
    
    fileprivate func longSeparatorView() -> UIView {
        let lineView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: applicationWindow.frame.size.width, height: 1)))
        lineView.backgroundColor = theme.separatorColor
        return lineView
    }
    
    fileprivate func shortSeparatorView() -> UIView {
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
    fileprivate var iconImageView = UIImageView()
    fileprivate var titleLabel = UILabel()
    fileprivate var customAccessoryView = UIView()
    fileprivate var customAccessoryViewWidthConstraint: NSLayoutConstraint!
    fileprivate var customAccessoryViewHeightConstraint: NSLayoutConstraint!
    
    var onTapAccessoryView: (() -> Void)?
    
    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = MaterialActionSheetTheme.currentTheme.backgroundColor
        backgroundColor = MaterialActionSheetTheme.currentTheme.backgroundColor
        iconImageView.tintColor = MaterialActionSheetTheme.currentTheme.iconTemplateColor
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(customAccessoryView)
        
        // Auto layout iconImageView
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: MaterialActionSheetTheme.currentTheme.iconSize.width),
            iconImageView.heightAnchor.constraint(equalToConstant: MaterialActionSheetTheme.currentTheme.iconSize.height)
            ])
        
        // Auto layout titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if MaterialActionSheetTheme.currentTheme.wrapText {
            titleLabel.numberOfLines = 0
        } else {
            titleLabel.numberOfLines = 1
        }
        titleLabel.font = MaterialActionSheetTheme.currentTheme.textFont
        titleLabel.textColor = MaterialActionSheetTheme.currentTheme.textColor
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: customAccessoryView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            ])
        
        // Auto layout customAccessoryView
        customAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customAccessoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            customAccessoryView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        
        customAccessoryViewWidthConstraint = customAccessoryView.widthAnchor.constraint(equalToConstant: 0)
        customAccessoryViewWidthConstraint.isActive = true
        
        customAccessoryViewHeightConstraint = customAccessoryView.heightAnchor.constraint(equalToConstant: 0)
        customAccessoryViewHeightConstraint.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(action: MaterialAction) {
        if MaterialActionSheetTheme.currentTheme.useIconImageAsTemplate {
            iconImageView.image = action.icon?.withRenderingMode(.alwaysTemplate)
        } else {
            iconImageView.image = action.icon
        }
        
        titleLabel.text = action.title
        if let accessoryView = action.accessoryView {
            customAccessoryViewWidthConstraint.constant = accessoryView.bounds.size.width
            customAccessoryViewHeightConstraint.constant = accessoryView.bounds.size.height
            
            
            if let accessoryView = accessoryView as? UIControl {
                accessoryView.addTarget(self, action: #selector(MaterialActionSheetTableViewCell.accessoryViewTapped), for: [.touchUpInside])
            } else {
                let accessoryTap = UITapGestureRecognizer(target: self, action: #selector(MaterialActionSheetTableViewCell.accessoryViewTapped))
                accessoryView.isUserInteractionEnabled = true
                accessoryView.addGestureRecognizer(accessoryTap)
            }
            
            customAccessoryView.addSubview(accessoryView)
        }
    }
    
    fileprivate override func prepareForReuse() {
        super.prepareForReuse()
        // Clean iconImageView and customAccessoryView
        iconImageView.image = nil
        
        for subView in customAccessoryView.subviews {
            subView.removeFromSuperview()
        }
        customAccessoryViewWidthConstraint.constant = 0
        customAccessoryViewHeightConstraint.constant = 0
    }
    
    @objc fileprivate func accessoryViewTapped() {
        onTapAccessoryView?()
    }
}

private final class MaterialActionSheetHeaderTableViewCell: UITableViewCell {
    fileprivate let titleLabel = UILabel(frame: .zero)
    fileprivate let messageLabel = UILabel(frame: .zero)
    
    private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = MaterialActionSheetTheme.currentTheme.backgroundColor
        backgroundColor = MaterialActionSheetTheme.currentTheme.backgroundColor
        
        titleLabel.textAlignment = MaterialActionSheetTheme.currentTheme.headerTitleAlignment
        messageLabel.textAlignment = MaterialActionSheetTheme.currentTheme.headerMessageAlignment
        
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        // Auto layout titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = MaterialActionSheetTheme.currentTheme.headerTitleFont
        titleLabel.textColor = MaterialActionSheetTheme.currentTheme.headerTitleColor
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10)
            ])
        
        // Auto layout messageLabel
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = MaterialActionSheetTheme.currentTheme.headerMessageFont
        messageLabel.textColor = MaterialActionSheetTheme.currentTheme.headerMessageColor
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func bind(title: String?, message: String?) {
        titleLabel.text = title
        messageLabel.text = message
    }
}
