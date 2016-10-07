//
//  MaterialActionSheetController.swift
//
//  Copyright (c) 2016 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

public typealias MaterialActionHandler = (_ materialAction: MaterialAction) -> Void
public struct MaterialAction {
    
    public let icon: UIImage?
    public let title: String
    public let handler: MaterialActionHandler?
    public let accessoryView: UIView?
    public let accessoryHandler: MaterialActionHandler?
    public let dismissOnAccessoryTouch: Bool?
    
    
    public init(icon: UIImage?, title: String, handler: MaterialActionHandler?, accessoryView: UIView? = nil, dismissOnAccessoryTouch: Bool? = true, accessoryHandler: MaterialActionHandler? = nil) {
        self.icon = icon
        self.title = title
        self.handler = handler
        self.accessoryView = accessoryView
        self.dismissOnAccessoryTouch = dismissOnAccessoryTouch
        self.accessoryHandler = accessoryHandler
    }
    
}
