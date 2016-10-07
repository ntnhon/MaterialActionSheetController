//
//  MaterialActionSheetController.swift
//
//  Copyright (c) 2016 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

public final class MaterialActionSheetController: UIViewController {
    
    /// Invoked when MaterialActionSheetController is about to dismiss
    public var willDismiss: (() -> Void)?
    
    /// Invoked when MaterialAcionSheetController is completely dismissed
    public var didDismiss: (() -> Void)?
    
    /// Custom header view
    public var customHeaderView: UIView?
    
    /// Customizable theme, default is light
    public var theme: MaterialActionSheetTheme = MaterialActionSheetTheme.light()
    
    fileprivate let applicationWindow = UIApplication.shared.keyWindow!
    fileprivate var dimBackgroundView = UIView()
    private let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
    
    public var message: String?
    fileprivate var noHeader: Bool {
        return title == nil && message == nil
    }
    public var actionSections: [[MaterialAction]] = []
    
    
    /// If header's title and message are both nil, header view is omitted
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
        fatalError("init(coder:) has not been implemented")
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
        tableView.removeObserver(self, forKeyPath: #keyPath(UITableView.contentSize))
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if tableView.contentSize.height <= theme.maxHeight {
            tableView.frame.size = tableView.contentSize
            tableView.isScrollEnabled = false
        } else {
            tableView.frame.size = CGSize(width: tableView.frame.width, height: theme.maxHeight)
            tableView.isScrollEnabled = true
        }
    }
    
    fileprivate func dismiss(withAction action: MaterialAction? = nil) {
        willDismiss?()
        UIView.animate(withDuration: theme.animationDuration, animations: {[unowned self] in
            self.tableView.frame.origin = CGPoint(x: 0, y: self.applicationWindow.frame.height)
            self.dimBackgroundView.alpha = 0
        }, completion: { [unowned self] (finished) in
            self.tableView.removeFromSuperview()
            self.dimBackgroundView.removeFromSuperview()
            self.dismiss(animated: false, completion: {
                if let action = action {
                    action.handler?(action)
                }
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
        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), options: NSKeyValueObservingOptions.new, context: nil)
        tableView.register(MaterialActionSheetTableViewCell.self, forCellReuseIdentifier: MaterialActionSheetTableViewCell.reuseIdentifier)
        tableView.register(MaterialActionSheetHeaderTableViewCell.self, forCellReuseIdentifier: MaterialActionSheetHeaderTableViewCell.reuseIdentifier)
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
        if !noHeader && indexPath.section == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: MaterialActionSheetHeaderTableViewCell.reuseIdentifier, for: indexPath) as! MaterialActionSheetHeaderTableViewCell
            headerCell.bind(title: title, message: message)
            return headerCell
        }
        
        var action: MaterialAction
        if noHeader {
            action = actionSections[indexPath.section][indexPath.row]
        } else {
            action = actionSections[indexPath.section - 1][indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MaterialActionSheetTableViewCell.reuseIdentifier, for: indexPath) as! MaterialActionSheetTableViewCell
        cell.bind(action: action)
        
        cell.onTapAccessoryView = { [unowned self] in
            action.accessoryHandler?(action)
            
            if let dismissOnAccessoryTouch = action.dismissOnAccessoryTouch
                , dismissOnAccessoryTouch == true {
                self.dismiss(withAction: action)
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
        if !noHeader && indexPath.section == 0 {
            return
        }
        
        var action: MaterialAction
        if noHeader {
            action = actionSections[indexPath.section][indexPath.row]
        } else {
            action = actionSections[indexPath.section - 1][indexPath.row]
        }

        dismiss(withAction: action)
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

