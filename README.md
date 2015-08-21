[![Build Status](https://travis-ci.org/gregttn/CheckmarkSegmentedControl.svg?branch=master)](https://travis-ci.org/gregttn/CheckmarkSegmentedControl)
[![Pod Version](https://img.shields.io/cocoapods/v/CheckmarkSegmentedControl.svg?style=flat)](https://cocoapods.org/pods/CheckmarkSegmentedControl)

# CheckmarkSegmentedControl

CheckmarkSegmentedControl is a customisable alternative to UISegmentedControl.
Visually it looks like radio buttons group with checkmark sign in the middle and animated border on selection. Each option can be fully customised.

![Preview](https://raw.githubusercontent.com/gregttn/CheckmarkSegmentedControl/master/preview.gif)

### Features
* creation of segmented control with look of radio buttons
* selection of a new option is animated
* each option can have border, background and font customized

### Installation

#### Cocoapods
Include the following in your Podfile:

```ruby
use_frameworks!
pod 'CheckmarkSegmentedControl'
```

#### Manual
You need to copy CheckmarkSegmentedControl.swift to your project.

### Usage

```swift
var checkmark: CheckmarkSegmentedControl = CheckmarkSegmentedControl(frame: frame)
checkmark.options = [
    CheckmarkOption(title:"Option 1"), // by default black border and light gray colour as background
    CheckmarkOption(title: "Option 2", borderColor: UIColor.yellowColor(), fillColor: UIColor.greenColor()),
    CheckmarkOption(title: "Option 3", borderColor: UIColor.blueColor(), fillColor: UIColor.yellowColor()),
    CheckmarkOption(title: "Option 4", borderColor: UIColor.greenColor(), fillColor: UIColor.blueColor())]

```

Get notified when new option is selected:

```swift
checkmark.addTarget(self, action: "optionSelected:", forControlEvents: UIControlEvents.ValueChanged)

func optionSelected(sender: AnyObject) {
    println("Selected option: \(checkmark.options[checkmark.selectedIndex])")
}

```

### Licence

MIT licence
