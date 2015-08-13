# CheckmarkSegmentedControl

CheckmarkSegmentedControl is a customiable alternative to UISegmentedControl.

![Preview](https://raw.githubusercontent.com/gregttn/CheckmarkSegmentedControl/master/preview.gif)

### Features
* creation of segmented control with look of radio buttons
* selection of a new option is animated
* each option can have border, background and font customized

### Installation

For the moment only manual installation is available. You need to copy CheckmarkSegmentedControl.swift to your project.

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
