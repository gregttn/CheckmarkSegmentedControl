//
//  CheckmarkSegmentedControlTests.swift
//  CheckmarkSegmentedControlTests
//
//  Created by Grzegorz Tatarzyn on 27/04/2015.
//  Copyright (c) 2015 gregttn. All rights reserved.
//

import UIKit
import XCTest

class CheckmarkSegmentedControlTests: XCTestCase {
    var checkmark: CheckmarkSegmentedControl!
    let titles: [String] = ["option 1", "option 2"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        checkmark = CheckmarkSegmentedControl(frame: CGRectMake(0, 0, 50, 60))
        checkmark.titles = titles
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShouldPlaceTitlesAtTheBottomOfTheConainer() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index] as! CATextLayer
            let expectedSize = sizeForText(checkmark.titles[index], font: checkmark.titleFont)
        
            let expectedOrigin = CGPoint(x: CGFloat(index) * checkmark.frame.width / CGFloat(checkmark.titles.count), y:checkmark.frame.height - expectedSize.height)
            XCTAssertEqualWithAccuracy(titleLayer.frame.origin.x, expectedOrigin.x, 0.1, "Incorrect x origin for: \(checkmark.titles[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.origin.y, expectedOrigin.y, 0.1, "Incorrect x origin for: \(checkmark.titles[index])")
        }
    }
    
    func testTitleLablesShouldHaveCorrectTitels() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index] as! CATextLayer
            
            XCTAssertEqual(titleLayer.string as! String, checkmark.titles[index])
        }
    }

    private func sizeForText(text: String, font: UIFont) -> CGSize {
        let textAttributes = [NSFontAttributeName : font]
        let string: NSString = text

        return string.sizeWithAttributes(textAttributes)
    }
}
