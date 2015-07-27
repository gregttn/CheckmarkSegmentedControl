//
//  ViewController.swift
//  CheckmarkSegmentedControl
//
//  Created by Grzegorz Tatarzyn on 27/04/2015.
//  Copyright (c) 2015 gregttn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var checkmark: CheckmarkSegmentedControl!
    
       override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkmark.options = [CheckmarkOption(title:"Option 1"),
            CheckmarkOption(title: "Option 2", fillColor: UIColor.greenColor()),
            CheckmarkOption(title: "Option 3", fillColor: UIColor.yellowColor()),
            CheckmarkOption(title: "Option 4", fillColor: UIColor.blueColor())]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

