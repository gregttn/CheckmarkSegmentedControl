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
            CheckmarkOption(title: "Option 2"),
            CheckmarkOption(title: "Option 3"),
            CheckmarkOption(title: "Option 4")]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

