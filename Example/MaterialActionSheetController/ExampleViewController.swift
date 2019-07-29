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
    
    fileprivate let lightTheme = MaterialActionSheetTheme.light()
    fileprivate let darkTheme = MaterialActionSheetTheme.dark()
    
    // Actions sample
    private lazy var infoAction = MaterialAction(
        icon: UIImage(named: "Info"),
        title: "Library information",
        handler: { [unowned self] (accessoryView) in
            self.doSomething()
    })
    
    private lazy var addCommentAction = MaterialAction(
        icon: UIImage(named: "Comment"),
        title: "Say something about this library",
        handler: { [unowned self] (accessoryView) in
            self.doSomething()
    })
    
    private lazy var menuAction = MaterialAction(
        icon: UIImage(named: "Menu"),
        title: "This is a very long action title and it is wrapped to multiple lines by default. You can change this behavior by changing theme settings.",
        handler: { [unowned self] (accessoryView) in
            self.doSomething()
    })
    
    private lazy var lightBulbAction = MaterialAction(
        icon: UIImage(named: "Light"),
        title: "Edison light bulb will show you how to add and handle UISwitch",
        handler: { [unowned self] (accessoryView) in
            self.doSomething()
        },
        accessoryView: UISwitch(),
        dismissOnAccessoryTouch: false) { [unowned self] (accessoryView) in
            if let lightBulbSwitch = accessoryView as? UISwitch {
                if lightBulbSwitch.isOn {
                    print("Light is ON!\n")
                } else {
                    print("Light is OFF!\n")
                }
            }
            self.doSomething()
    }

    private lazy var greenAction = MaterialAction(
        icon: UIImage(named: "Info"),
        title: "Green means you can go ahead",
        handler: { [unowned self] (accessoryView) in
            self.doSomething()
        },
        accessoryView: self.dummyColorView(UIColor.green),
        dismissOnAccessoryTouch: true,
        accessoryHandler: { [unowned self] (accessoryView) in
            self.doSomething()
    })

    private lazy var yellowAction = MaterialAction(
        icon: UIImage(named: "Info"),
        title: "Yellow means you should go faster",
        handler: { [unowned self] (accessoryView) in
            self.doSomething()
        },
        accessoryView: self.dummyColorView(UIColor.yellow),
        dismissOnAccessoryTouch: true,
        accessoryHandler: {[unowned self] (accessoryView) in
            self.doSomething()
    })
    
    private lazy var redAction = MaterialAction(
        icon: UIImage(named: "Info"),
        title: "Move you arse",
        handler: { [unowned self] (accessoryView) in
            self.doSomething()
        },
        accessoryView: self.dummyColorView(UIColor.red), dismissOnAccessoryTouch: true,
        accessoryHandler: { [unowned self] (accessoryView) in
            self.doSomething()
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = 20
    }
    
    fileprivate func doSomething() {
        // Dummy function
        print("I've done something.\n")
    }
    
    fileprivate func fullOption(theme: MaterialActionSheetTheme) {
        let materialActionSheetController = MaterialActionSheetController(
            title: "Material action sheet controller",
            message: "A Google like action sheet controller. Create and use it the way you do with UIAlertController.",
            actionSections: [infoAction], [addCommentAction, menuAction], [lightBulbAction], [greenAction, yellowAction, redAction])

        materialActionSheetController.theme = theme
        
        materialActionSheetController.willDismiss = { [unowned self] in
            print("I will dismiss.")
            self.doSomething()
        }
        
        materialActionSheetController.didDismiss = { [unowned self] in
            print("I did dismiss.")
            self.doSomething()
        }
        
        present(materialActionSheetController, animated: true, completion: nil)
    }
    
    fileprivate func manyOptions(theme: MaterialActionSheetTheme) {
        let longTextAction = MaterialAction(
            icon: UIImage(named: "Info"),
            title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. \nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            handler: { [unowned self] (accessoryView) in
                self.doSomething()
        })
        
        let materialActionSheetController = MaterialActionSheetController(
            title: "Material action sheet controller",
            message: "A Google like action sheet controller. Create and use it the way you do with UIAlertController.",
            actionSections: [longTextAction], [addCommentAction, menuAction], [lightBulbAction], [greenAction, yellowAction, redAction])
        
        materialActionSheetController.theme = theme
        
        materialActionSheetController.willDismiss = { [unowned self] in
            print("I will dismiss.")
            self.doSomething()
        }
        
        materialActionSheetController.didDismiss = { [unowned self] in
            print("I did dismiss.")
            self.doSomething()
        }
        
        present(materialActionSheetController, animated: true, completion: nil)
    }
    
    fileprivate func customHeader(theme: MaterialActionSheetTheme) {
        let thankAction = MaterialAction(icon: UIImage(named: "Comment"), title: "Thanks for the heads up!", handler: { [unowned self] (accessoryView) in
            self.doSomething()
        })
        
        let grewUpAction = MaterialAction(icon: UIImage(named: "Comment"), title: "The child is grown, the dream is gone...", handler: { [unowned self] (accessoryView) in
            self.doSomething()
        })
        
        let materialActionSheetController = MaterialActionSheetController(
            title: nil,
            message: nil,
            actionSections: [thankAction, grewUpAction])
        
        materialActionSheetController.theme = theme
        
        let imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: 150)))
        imageView.image = UIImage(named: "Trap")
        materialActionSheetController.customHeaderView = imageView
        
        materialActionSheetController.willDismiss = { [unowned self] in
            print("I will dismiss.")
            self.doSomething()
        }
        
        materialActionSheetController.didDismiss = { [unowned self] in
            print("I did dismiss.")
            self.doSomething()
        }
        
        present(materialActionSheetController, animated: true, completion: nil)
    }
    
    fileprivate func noHeader(theme: MaterialActionSheetTheme) {
        let materialActionSheetController = MaterialActionSheetController(title: nil, message: nil, actionSections: [infoAction, addCommentAction], [lightBulbAction])
        materialActionSheetController.theme = theme
        
        materialActionSheetController.willDismiss = { [unowned self] in
            print("I will dismiss.")
            self.doSomething()
        }
        
        materialActionSheetController.didDismiss = { [unowned self] in
            print("I did dismiss.")
            self.doSomething()
        }
        
        present(materialActionSheetController, animated: true, completion: nil)
    }
    
    fileprivate func singleSection(theme: MaterialActionSheetTheme) {
        let materialActionSheetController = MaterialActionSheetController(title: nil, message: nil, actionSections: [infoAction, addCommentAction])
        materialActionSheetController.theme = theme
        
        materialActionSheetController.willDismiss = { [unowned self] in
            print("I will dismiss.")
            self.doSomething()
        }
        
        materialActionSheetController.didDismiss = { [unowned self] in
            print("I did dismiss.")
            self.doSomething()
        }
        
        present(materialActionSheetController, animated: true, completion: nil)
    }
    
    fileprivate func dummyColorView(_ color: UIColor) -> UIView {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 28, height: 28)))
        view.backgroundColor = color
        view.layer.cornerRadius = 14
        return view
    }
}

extension ExampleViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0, 0):
            fullOption(theme: lightTheme)
        case (0, 1):
            manyOptions(theme: lightTheme)
        case (0, 2):
            fullOption(theme: darkTheme)
        case (1, 0):
            customHeader(theme: lightTheme)
        case (1, 1):
            customHeader(theme: darkTheme)
        case (2, 0):
            noHeader(theme: lightTheme)
        case (2, 1):
            noHeader(theme: darkTheme)
        case (3, 0):
            singleSection(theme: lightTheme)
        case (3, 1):
            singleSection(theme: darkTheme)
        default:
            return
        }
    }
}
