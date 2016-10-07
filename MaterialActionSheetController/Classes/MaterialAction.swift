//
//  MaterialActionSheetController.swift
//
//  Copyright (c) 2016 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

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
