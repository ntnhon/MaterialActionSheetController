//
//  ExampleViewController.swift
//  MaterialActionSheetController
//
//  Created by Thanh-Nhon Nguyen on 8/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import MaterialActionSheetController

final class ExampleViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = 20
    }
    
    private func fullOption() {
        // Section Info
        let info = MaterialAction(icon: UIImage(named: "Info"), title: "Library information", handler: nil)
        
        // Section comment
        let comment = MaterialAction(icon: UIImage(named: "Comment"), title: "Add comment to this library", handler: nil, accessoryView: UISwitch(), accessoryHandler: { (accessoryView) in
            if let accessoryView = accessoryView as? UISwitch {
                print(accessoryView.on)
            }
        })
        
        let menu = MaterialAction(icon: UIImage(named: "Menu"), title: "This is a very long action title and it is wrapped to multiple lines by default. You can change this behavior by changing theme settings.", handler: nil)
        
        // Section color
        let greenView = dummyColorView(UIColor.greenColor())
        let green = MaterialAction(icon: UIImage(named: "Info"), title: "Green means you can go ahead", handler: nil, accessoryView: greenView, accessoryHandler: nil)
        
        let yellowColor = dummyColorView(UIColor.yellowColor())
        let yellow = MaterialAction(icon: UIImage(named: "Info"), title: "Yellow means you should go faster", handler: nil, accessoryView: yellowColor, accessoryHandler: nil)
        
        let redView = dummyColorView(UIColor.redColor())
        let red = MaterialAction(icon: UIImage(named: "Info"), title: "Move you arse", handler: nil, accessoryView: redView, accessoryHandler: nil)
        
        let materialActionSheetController = MaterialActionSheetController(title: "Material action sheet controller", message: "A Google like action sheet controller. Create and use it the way you do with UIAlertController.", sections: [info], [comment, menu], [green, yellow, red])
        presentViewController(materialActionSheetController, animated: true, completion: nil)
    }
    
    private func noHeader() {
        
    }
    
    private func singleSection() {
        
    }
    
    private func dummyColorView(color: UIColor) -> UIView {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 28, height: 28)))
        view.backgroundColor = color
        view.layer.cornerRadius = 14
        return view
    }
}

extension ExampleViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedRow = indexPath.row
        
        if selectedRow == 0 {
            fullOption()
        } else if selectedRow == 1 {
            noHeader()
        } else if selectedRow == 2 {
            singleSection()
        }
    }
}