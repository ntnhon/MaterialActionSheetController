//
//  ViewController.swift
//  MaterialActionSheetController
//
//  Created by Thanh-Nhon Nguyen on 08/18/2016.
//  Copyright (c) 2016 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import MaterialActionSheetController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapped() {
        let info = MaterialAction(icon: UIImage(named: "Info"), title: "Library information", handler: nil)
        let comment = MaterialAction(icon: UIImage(named: "Comment"), title: "Add comment to this library", handler: nil, accessoryView: UISwitch(), accessoryHandler: { (accessoryView) in
            if let accessoryView = accessoryView as? UISwitch {
                print(accessoryView.on)
            }
        })
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 70, height: 35)))
        view.backgroundColor = UIColor.blueColor()
        let menu = MaterialAction(icon: UIImage(named: "Menu"), title: "Open other action sheet controller Open other action sheet controller", handler: nil, accessoryView: view)

        let materialActionSheetController = MaterialActionSheetController(title: "Material action sheet controller", message: "A Google like action sheet controller. Create and use it the way you do with UIAlertController", sections: [info], [comment, menu])
        presentViewController(materialActionSheetController, animated: true, completion: nil)
    }
}