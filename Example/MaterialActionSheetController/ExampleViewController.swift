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
    
    private let lightTheme = MaterialActionSheetTheme.light()
    private let darkTheme = MaterialActionSheetTheme.dark()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = 20
    }
    
    private func doSomething() {
        // Dummy function
    }
    
    private func fullOption(theme theme: MaterialActionSheetTheme) {
        // Section Info
        let infoAction = MaterialAction(
            icon: UIImage(named: "Info"),
            title: "Library information",
            handler: { [unowned self] (accessoryView) in
                print("MaterialActionSheetController v1.0\n")
                self.doSomething()
        })
        
        // Section comment
        let addCommentAction = MaterialAction(
            icon: UIImage(named: "Comment"),
            title: "Say something about this library",
            handler: { [unowned self] (accessoryView) in
                print("MaterialActionSheetController is in its early stages, contributions are warmly welcome!\n")
                self.doSomething()
        })
        
        let menuAction = MaterialAction(
            icon: UIImage(named: "Menu"),
            title: "This is a very long action title and it is wrapped to multiple lines by default. You can change this behavior by changing theme settings.",
            handler: { [unowned self] (accessoryView) in
                print("Yes it is, a very long text.\n")
                self.doSomething()
        })
        
        // Section light
        let lightBulbAction = MaterialAction(
            icon: UIImage(named: "Light"),
            title: "Edison light bulb will show you how to add and handle UISwitch",
            handler: { [unowned self] (accessoryView) in
                if let lightBulbSwitch = accessoryView as? UISwitch {
                    if lightBulbSwitch.on {
                        print("It's so bright here!\n")
                    } else {
                        print("It's so dark here!\n")
                    }
                }
                print("Click on the switch to turn on or off the light.\n")
                self.doSomething()
            },
            accessoryView: UISwitch(),
            dismissOnAccessoryTouch: true) { [unowned self] (accessoryView) in
                if let lightBulbSwitch = accessoryView as? UISwitch {
                    if lightBulbSwitch.on {
                        print("Light is ON!\n")
                    } else {
                        print("Light is OFF!\n")
                    }
                }
                self.doSomething()
        }

        // Section color
        let greenView = dummyColorView(UIColor.greenColor())
        let greenAction = MaterialAction(
            icon: UIImage(named: "Info"),
            title: "Green means you can go ahead",
            handler: { [unowned self] (accessoryView) in
                print("Okay.\n")
                self.doSomething()
            },
            accessoryView: greenView,
            dismissOnAccessoryTouch: true,
            accessoryHandler: { [unowned self] (accessoryView) in
                print("It's green.\n")
                self.doSomething()
        })
        
        let yellowColor = dummyColorView(UIColor.yellowColor())
        let yellowAction = MaterialAction(
            icon: UIImage(named: "Info"),
            title: "Yellow means you should go faster",
            handler: { [unowned self] (accessoryView) in
                print("Should I?.\n")
                self.doSomething()
            },
            accessoryView: yellowColor,
            dismissOnAccessoryTouch: true,
            accessoryHandler: {[unowned self] (accessoryView) in
                print("It's yellow.\n")
                self.doSomething()
        })
        
        let redView = dummyColorView(UIColor.redColor())
        let redAction = MaterialAction(
            icon: UIImage(named: "Info"),
            title: "Move you arse",
            handler: { [unowned self] (accessoryView) in
                print("It's red.\n")
                self.doSomething()
            },
            accessoryView: redView, dismissOnAccessoryTouch: true,
            accessoryHandler: { [unowned self] (accessoryView) in
                print("Really?.\n")
                self.doSomething()
        })
        
        // Create and present MaterialActionSheetController
        let materialActionSheetController = MaterialActionSheetController(
            title: "Material action sheet controller",
            message: "A Google like action sheet controller. Create and use it the way you do with UIAlertController.",
            sections: [infoAction], [addCommentAction, menuAction], [lightBulbAction], [greenAction, yellowAction, redAction])
        
        materialActionSheetController.theme = theme
        
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
        if indexPath.section == 0 {
            if indexPath.row == 0  {
                fullOption(theme: lightTheme)
            } else {
                fullOption(theme: darkTheme)
            }
        }
    }
}