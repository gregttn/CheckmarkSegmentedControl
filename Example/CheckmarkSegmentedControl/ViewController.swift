//
//  ViewController.swift
//  CheckmarkSegmentedControl
//
//  Created by Grzegorz Tatarzyn on 27/04/2015.
//  Copyright (c) 2015 gregttn. All rights reserved.
//

import UIKit
import CheckmarkSegmentedControl

class ViewController: UIViewController {
    @IBOutlet weak var checkmark: CheckmarkSegmentedControl!
    
       override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkmark.options = [
            CheckmarkOption(title:"Option 1"), // by default black border and light gray colour as background
            CheckmarkOption(title: "Option 2", borderColor: UIColor.orange, fillColor: UIColor.brown),
            CheckmarkOption(title: "Option 3", borderColor: UIColor.brown, fillColor: UIColor.orange),
            CheckmarkOption(title: "Option 4", borderColor: UIColor.green, fillColor: UIColor.blue)
        ]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func optionSelected(_ sender: AnyObject) {
        print("Selected option: \(checkmark.options[checkmark.selectedIndex])")
    }
}

