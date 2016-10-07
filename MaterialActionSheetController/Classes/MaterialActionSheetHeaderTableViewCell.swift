//
//  MaterialActionSheetController.swift
//
//  Copyright (c) 2016 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

internal final class MaterialActionSheetHeaderTableViewCell: UITableViewCell, ReusableCell {
    
    private var titleLabel = UILabel()
    private var messageLabel = UILabel()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
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
        
        NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: margin).isActive = true
        
        // Auto layout messageLabel
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = MaterialActionSheetTheme.currentTheme.headerMessageFont
        messageLabel.textColor = MaterialActionSheetTheme.currentTheme.headerMessageColor
        NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottomMargin, multiplier: 1, constant: 2*margin).isActive = true
        NSLayoutConstraint(item: messageLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailingMargin, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leadingMargin, multiplier: 1, constant: 1).isActive = true
        NSLayoutConstraint(item: messageLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottomMargin, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(title: String?, message: String?) {
        titleLabel.text = title
        messageLabel.text = message
    }
    
}
