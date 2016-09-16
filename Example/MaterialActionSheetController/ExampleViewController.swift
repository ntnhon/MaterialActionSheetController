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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = 20
    }
    
    fileprivate func doSomething() {
        // Dummy function
        print("I've done something.\n")
    }
    
    fileprivate func fullOption(theme: MaterialActionSheetTheme) {
        // Section Info
        let infoAction = MaterialAction(
            icon: UIImage(named: "Info"),
            title: "Library information",
            handler: { [unowned self] (accessoryView) in
                self.doSomething()
        })
        
        // Section comment
        let addCommentAction = MaterialAction(
            icon: UIImage(named: "Comment"),
            title: "Say something about this library",
            handler: { [unowned self] (accessoryView) in
                self.doSomething()
        })
        
        let menuAction = MaterialAction(
            icon: UIImage(named: "Menu"),
            title: "This is a very long action title and it is wrapped to multiple lines by default. You can change this behavior by changing theme settings.",
            handler: { [unowned self] (accessoryView) in
                self.doSomething()
        })
        
        // Section light
        let lightBulbAction = MaterialAction(
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

        // Section color
        let greenView = dummyColorView(UIColor.green)
        let greenAction = MaterialAction(
            icon: UIImage(named: "Info"),
            title: "Green means you can go ahead",
            handler: { [unowned self] (accessoryView) in
                self.doSomething()
            },
            accessoryView: greenView,
            dismissOnAccessoryTouch: true,
            accessoryHandler: { [unowned self] (accessoryView) in
                self.doSomething()
        })
        
        let yellowColor = dummyColorView(UIColor.yellow)
        let yellowAction = MaterialAction(
            icon: UIImage(named: "Info"),
            title: "Yellow means you should go faster",
            handler: { [unowned self] (accessoryView) in
                self.doSomething()
            },
            accessoryView: yellowColor,
            dismissOnAccessoryTouch: true,
            accessoryHandler: {[unowned self] (accessoryView) in
                self.doSomething()
        })
        
        let redView = dummyColorView(UIColor.red)
        let redAction = MaterialAction(
            icon: UIImage(named: "Info"),
            title: "Move you arse",
            handler: { [unowned self] (accessoryView) in
                self.doSomething()
            },
            accessoryView: redView, dismissOnAccessoryTouch: true,
            accessoryHandler: { [unowned self] (accessoryView) in
                self.doSomething()
        })
        
        // Create and present MaterialActionSheetController
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
        let infoAction = MaterialAction(icon: UIImage(named: "Info"), title: "Library information", handler: { [unowned self] (accessoryView) in
            self.doSomething()
        })

        
        let commentAction = MaterialAction(icon: UIImage(named: "Comment"), title: "Add comment", handler: { [unowned self] (accessoryView) in
            self.doSomething()
        })
        
        let lightBulbAction = MaterialAction(
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
        
        let materialActionSheetController = MaterialActionSheetController(title: nil, message: nil, actionSections: [infoAction, commentAction], [lightBulbAction])
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
        let infoAction = MaterialAction(icon: UIImage(named: "Info"), title: "Library information", handler: { [unowned self] (accessoryView) in
            self.doSomething()
            })
        
        
        let commentAction = MaterialAction(icon: UIImage(named: "Comment"), title: "Add comment", handler: { [unowned self] (accessoryView) in
            self.doSomething()
            })
        
        let materialActionSheetController = MaterialActionSheetController(title: nil, message: nil, actionSections: [infoAction, commentAction])
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
