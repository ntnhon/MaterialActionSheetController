# MaterialActionSheetController
A Google like action sheet for iOS written in Swift.

[![CI Status](http://img.shields.io/travis/Thanh-Nhon Nguyen/MaterialActionSheetController.svg?style=flat)](https://travis-ci.org/Thanh-Nhon Nguyen/MaterialActionSheetController)
[![Version](https://img.shields.io/cocoapods/v/MaterialActionSheetController.svg?style=flat)](http://cocoapods.org/pods/MaterialActionSheetController)
[![License](https://img.shields.io/cocoapods/l/MaterialActionSheetController.svg?style=flat)](http://cocoapods.org/pods/MaterialActionSheetController)
[![Platform](https://img.shields.io/cocoapods/p/MaterialActionSheetController.svg?style=flat)](http://cocoapods.org/pods/MaterialActionSheetController)

## Screenshots
![Full option](https://raw.githubusercontent.com/ntnhon/MaterialActionSheetController/0a0d9d5715a281b8da5506c07be0864486dfadeb/Screenshots/Full_option.png)
## Features

- [x] Using blocks to configure actions
- [x] Action with optional icon and accessory view
- [x] Handling touch on accessory view
- [x] Separate long action list in sections
- [x] 2 built-in themes: light & dark

## Todos

- Swift 3 compliant
- Present on iPad as a pop-up
- Custom header

## Requirements

- iOS 8.0+
- Xcode 7.3

## Installation

#### CocoaPods
MaterialActionSheetController is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'MaterialActionSheetController'
```

#### Manually

Add `MaterialActionSheetController.swift` to your project

## Usage

```swift
// Import MaterialActionSheetController if you're using CocoaPods
import MaterialActionSheetController
```
```swift
// Create an action
let lightBulbAction = MaterialAction(
        icon: UIImage(named: "lightbulb"),
        title: "Action with UISwitch as an accessory view", handler: { [unowned self] (accessoryView) in
            self.doSomething()
        }, 
        accessoryView: UISwitch(), 
        dismissOnAccessoryTouch: true, 
        accessoryHandler: { [unowned self] (accessoryView) in
            if let lightBulbSwitch = accessoryView as? UISwitch {
                if accessoryView.on {
                    print("Light is ON!")
                } else {
                    print("Light is OFF!")
                }
            }
            self.doSomeOtherThing()
    })
```
```swift
// Then create and present your MaterialActionSheetController
// parameter sections is a variadic which take a flexible list of section
let materialActionSheetController = MaterialActionSheetController(
        title: "A nice title",
        message: "A friendly message",
        actionSections: [aCoolAction, anotherCoolAction], [cancelAction])

// Customize theme
materialActionSheetController.theme = MaterialActionSheetTheme.dark()

presentViewController(materialActionSheetController, animated: true, completion: nil)
```
See code in demo for more detailed examples.

## Contribute

Feel free to make PR, contributions are warmly welcome and appreciated.

## License

MaterialActionSheetController is available under the MIT license. See the LICENSE file for more info.
