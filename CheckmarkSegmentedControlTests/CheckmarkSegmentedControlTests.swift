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
    
    func testShouldPlaceTitlesAtTheBottomOfTheContainer() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let layerIndex = index * 2
            let titleLayer: CATextLayer = checkmark.layer.sublayers[layerIndex] as! CATextLayer
            let expectedSize = sizeForText(checkmark.titles[index], font: checkmark.titleFont)
        
            let sectionContainerWidth = checkmark.frame.width / CGFloat(checkmark.titles.count)
            let expectedOrigin = CGPoint(x: CGFloat(index) * sectionContainerWidth, y:checkmark.frame.height - expectedSize.height)
            XCTAssertEqualWithAccuracy(titleLayer.frame.origin.x, expectedOrigin.x, 0.1, "Incorrect x origin for: \(checkmark.titles[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.origin.y, expectedOrigin.y, 0.1, "Incorrect y origin for: \(checkmark.titles[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.width, sectionContainerWidth, 0.1, "Incorrect width for: \(checkmark.titles[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.height, expectedSize.height, 0.1, "Incorrect height for: \(checkmark.titles[index])")
        }
    }
    
    func testTitleLablesShouldHaveCorrectTitels() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index * 2] as! CATextLayer
            
            XCTAssertEqual(titleLayer.string as! String, checkmark.titles[index])
        }
    }

    func testTitleLabelContentIsCentered() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index * 2] as! CATextLayer
            
            XCTAssertEqual(titleLayer.alignmentMode, kCAAlignmentCenter)
        }
    }
    
    func testShouldChangeTitleColor() {
        checkmark.titleColor = UIColor.blueColor()
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index * 2] as! CATextLayer
            
            XCTAssertTrue(CGColorEqualToColor(titleLayer.foregroundColor, UIColor.blueColor().CGColor))
        }
    }
    
    func testShouldDrawCirlceAboveTitleLabel() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let layerIndex = (index * 2) + 1
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            let titleSize = sizeForText(checkmark.titles[index], font: checkmark.titleFont)
            
            let containerWidth: CGFloat = checkmark.frame.width / CGFloat(checkmark.titles.count)
            let containerFrame  = CGRectMake(containerWidth * CGFloat(index), 0, containerWidth, checkmark.frame.height)
            let remainingHeight = checkmark.frame.height - titleSize.height

            let expectedOrigin = CGPoint(x: CGRectGetMidX(containerFrame) - remainingHeight/2, y:0.0)
            
            XCTAssertEqualWithAccuracy(circleLayer.frame.origin.x, expectedOrigin.x, 0.1, "Incorrect circle x origin for: \(checkmark.titles[index])")
            XCTAssertEqualWithAccuracy(circleLayer.frame.origin.y, expectedOrigin.y, 0.1, "Incorrect circle y origin for: \(checkmark.titles[index])")
            XCTAssertEqualWithAccuracy(circleLayer.frame.width, remainingHeight, 0.1, "Incorrect circle w origin for: \(checkmark.titles[index])")
            XCTAssertEqualWithAccuracy(circleLayer.frame.height, remainingHeight, 0.1, "Incorrect circle height for: \(checkmark.titles[index])")
        }
    }
    
    private func sizeForText(text: String, font: UIFont) -> CGSize {
        let textAttributes = [NSFontAttributeName : font]
        let string: NSString = text

        return string.sizeWithAttributes(textAttributes)
    }
}
