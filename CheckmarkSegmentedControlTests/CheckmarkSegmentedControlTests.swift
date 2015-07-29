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
    let titles: [CheckmarkOption] = [CheckmarkOption(title:"option"), CheckmarkOption(title:"another option")]
    let numberOfLayers = 4
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        checkmark = CheckmarkSegmentedControl(frame: CGRectMake(0, 0, 500, 60))
        checkmark.options = titles
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShouldPlaceTitlesAtTheBottomOfTheContainer() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let layerIndex = index * numberOfLayers
            let titleLayer: CATextLayer = checkmark.layer.sublayers[layerIndex] as! CATextLayer
            let expectedSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
        
            let sectionContainerWidth = checkmark.frame.width / CGFloat(checkmark.options.count)
            let expectedOrigin = CGPoint(x: CGFloat(index) * sectionContainerWidth, y:checkmark.frame.height - expectedSize.height)
            XCTAssertEqualWithAccuracy(titleLayer.frame.origin.x, expectedOrigin.x, 0.1, "Incorrect x origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.origin.y, expectedOrigin.y, 0.1, "Incorrect y origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.width, sectionContainerWidth, 0.1, "Incorrect width for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.height, expectedSize.height, 0.1, "Incorrect height for: \(checkmark.options[index])")
        }
    }
    
    func testTitleLablesShouldHaveCorrectTitels() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index * numberOfLayers] as! CATextLayer
            
            XCTAssertEqual(titleLayer.string as! String, checkmark.options[index].title)
        }
    }

    func testTitleLabelContentIsCentered() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index * numberOfLayers] as! CATextLayer
            
            XCTAssertEqual(titleLayer.alignmentMode, kCAAlignmentCenter)
        }
    }
    
    func testShouldChangeTitleColor() {
        checkmark.titleColor = UIColor.blueColor()
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index * numberOfLayers] as! CATextLayer
            
            XCTAssertTrue(CGColorEqualToColor(titleLayer.foregroundColor, UIColor.blueColor().CGColor))
        }
    }
    
    func testShouldDrawCirlceAboveTitleLabel() {
        checkmark.titleLabelTopMargin = 15.0
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let layerIndex = (index * numberOfLayers) + 1
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            let expectedFrame = expectedFrameFor(circleLayer, frame: checkmark.frame, index: index)
            
            XCTAssertEqualWithAccuracy(circleLayer.frame.origin.x, expectedFrame.origin.x, 0.1, "Incorrect circle x origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(circleLayer.frame.origin.y, expectedFrame.origin.y, 0.1, "Incorrect circle y origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(circleLayer.frame.width, expectedFrame.width, 0.1, "Incorrect circle w origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(circleLayer.frame.height, expectedFrame.height, 0.1, "Incorrect circle height for: \(checkmark.options[index])")
        }
    }
    
    func testUseFrameWidthInsteadOfHeightIfSmallerThanHeightForCircleFrame() {
        let frame = CGRectMake(0, 0, 100, 500)
        checkmark.drawRect(frame)
        
        for index in (0..<titles.count) {
            let layerIndex = (index * numberOfLayers) + 1
            let sectionSize: CGSize = CGSizeMake(frame.width / CGFloat(titles.count), frame.height)
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            
            let titleSize: CGSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
            let containerFrame = CGRectMake(sectionSize.width * CGFloat(index), 0, sectionSize.width, sectionSize.height)
            let circleLayerFrame = CGRectInset(containerFrame, checkmark.titleLabelTopMargin/2.0, (titleSize.height + checkmark.titleLabelTopMargin)/2)
            let middleX = CGRectGetMidX(circleLayerFrame)
            let expectedFrame = CGRectMake(middleX - circleLayerFrame.width/2, 0, circleLayerFrame.width, circleLayerFrame.width)
            
            XCTAssertEqual(circleLayer.frame, expectedFrame)
        }
    }
    
    func testShouldPresentFirstOptionAsSelectedByDefault() {
        checkmark.strokeColor = UIColor.blueColor()
        checkmark.drawRect(checkmark.frame)
        
        let layerIndex = 2
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers[layerIndex] as! CAShapeLayer
        
        let expectedFrame = expectedFrameFor(borderLayer, frame: checkmark.frame, index: 0)
        
        XCTAssertTrue(CGColorEqualToColor(borderLayer.strokeColor, UIColor.blueColor().CGColor))
        XCTAssertTrue(CGColorEqualToColor(borderLayer.fillColor, UIColor.clearColor().CGColor))
        XCTAssertEqual(borderLayer.lineWidth , 3)
        XCTAssertEqual(borderLayer.frame, expectedFrame)
    }
    
    func testShouldAllowToSetSelectedOption() {
        checkmark.strokeColor = UIColor.blueColor()
        checkmark.selectedIndex = 1
        
        checkmark.drawRect(checkmark.frame)
        
        let firstLayerIndex = 2
        XCTAssertFalse(checkmark.layer.sublayers[firstLayerIndex].isKindOfClass(CAShapeLayer))
        
        let layerIndex = 4
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers[layerIndex] as! CAShapeLayer
        let expectedFrame = expectedFrameFor(borderLayer, frame: checkmark.frame, index: 1)
        
        XCTAssertTrue(CGColorEqualToColor(borderLayer.strokeColor, UIColor.blueColor().CGColor))
        XCTAssertTrue(CGColorEqualToColor(borderLayer.fillColor, UIColor.clearColor().CGColor))
        XCTAssertEqual(borderLayer.lineWidth , 3)
        XCTAssertEqual(borderLayer.frame, expectedFrame)
    }
    
    func testShouldClearSubleyersBeforeDrawing() {
        checkmark.strokeColor = UIColor.blueColor()
        checkmark.selectedIndex = 1
        
        checkmark.drawRect(checkmark.frame)
        
        XCTAssertEqual(checkmark.layer.sublayers.count, 6)
        
        checkmark.drawRect(checkmark.frame)
        
        XCTAssertEqual(checkmark.layer.sublayers.count, 6)
    }
    
    func testShouldNotAllowNegativeValueToBeAssignedToSelectedIndex() {
        checkmark.selectedIndex = -1
        
        XCTAssertEqual(checkmark.selectedIndex, 0)
    }
    
    func testShouldSetSelectedToMaxIndexOfTitlesIfGreaterValuePassed() {
        checkmark.selectedIndex = titles.count
        
        XCTAssertEqual(checkmark.selectedIndex, 1)
    }
    
    func testShouldChangeSelectedElementOnTap() {
        let point = CGPointMake(checkmark.frame.width/CGFloat(titles.count) + 10 ,10)
        let touch = StubTouch(location: point)
        
        checkmark.touchesBegan([touch], withEvent: UIEvent())
        
        XCTAssertEqual(checkmark.selectedIndex, 1)
    }
    
    func testShouldMaskToBounds() {
        XCTAssertTrue(checkmark.layer.masksToBounds)
    }
    
    func testShouldResizeZeroFrameToMinimumSize() {
        let largestLabelSize = titles.map({ self.sizeForText($0, font: self.checkmark.titleFont) })
            .sorted({ $0.width > $1.width}).first!
        let bestWidth = Int(largestLabelSize.width) * titles.count
        let bestHeight = Int(largestLabelSize.height + CheckmarkSegmentedControl.minCheckmarkHeight)
        
        let resultSize = checkmark.sizeThatFits(CGSizeZero)

        XCTAssertEqual(Int(resultSize.width), bestWidth)
        XCTAssertEqual(Int(resultSize.height), bestHeight)
    }
    
    func testShouldNotChangeCorrectSize() {
        let additionalLength = 50
        let largestLabelSize = titles.map({ self.sizeForText($0, font: self.checkmark.titleFont) })
            .sorted({ $0.width > $1.width}).first!
        
        let bestWidth = Int(largestLabelSize.width) * titles.count
        let bestHeight = Int(largestLabelSize.height + CheckmarkSegmentedControl.minCheckmarkHeight)
        
        let size = CGSize(width: bestWidth + additionalLength, height: bestHeight + additionalLength)
        let resultSize = checkmark.sizeThatFits(size)
        
        XCTAssertEqual(resultSize.width, size.width)
        XCTAssertEqual(resultSize.height, size.height)
    }
    
    func testShouldReturnSameSizeIfNoElementsToDisplay() {
        checkmark.options.removeAll()
        
        let size = CGSize(width: 100, height:100)
        let resultSize = checkmark.sizeThatFits(size)
        
        XCTAssertEqual(resultSize.width, size.width)
        XCTAssertEqual(resultSize.height, size.height)
    }
    
    func testShouldDrawEachOptionWithDefaultFillColor() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<titles.count) {
            let layerIndex = (index * numberOfLayers) + 1
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            
            XCTAssertTrue(CGColorEqualToColor(circleLayer.backgroundColor, UIColor.lightGrayColor().CGColor))
        }
    }
    
    func testShouldDrawEachOptionWithCorrectFillColor() {
        checkmark.options = [CheckmarkOption(title: "Option", fillColor: UIColor.redColor()),
            CheckmarkOption(title: "Another option", fillColor: UIColor.blueColor())]
        
        checkmark.drawRect(checkmark.frame)

        for index in (0..<titles.count) {
            let layerIndex = (index * numberOfLayers) + 1
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            
            XCTAssertTrue(CGColorEqualToColor(circleLayer.backgroundColor, checkmark.options[index].fillColor.CGColor))
        }
    }
    
    func testShouldSelectedOptionBorderWithDefaultFillColor() {
        checkmark.drawRect(checkmark.frame)
        
        let layerIndex = 2
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers[layerIndex] as! CAShapeLayer
            
        XCTAssertTrue(CGColorEqualToColor(borderLayer.strokeColor, UIColor.blackColor().CGColor))
        
    }
    
    func testShouldSelectedOptionBorderWithCustomFillColor() {
        checkmark.options = [CheckmarkOption(title: "Option", borderColor: UIColor.redColor()),
            CheckmarkOption(title: "Another option", borderColor: UIColor.blueColor())]
        checkmark.drawRect(checkmark.frame)
        
        let layerIndex = 2
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers[layerIndex] as! CAShapeLayer
        XCTAssertTrue(CGColorEqualToColor(borderLayer.strokeColor, UIColor.redColor().CGColor))
        
    }
    
    private func sizeForText(option: CheckmarkOption, font: UIFont) -> CGSize {
        let textAttributes = [NSFontAttributeName : font]
        let string: NSString = option.title

        return string.sizeWithAttributes(textAttributes)
    }
    
    private func expectedFrameFor(layer: CALayer, frame: CGRect, index: Int) -> CGRect {
        let sectionSize: CGSize = CGSizeMake(checkmark.frame.width / CGFloat(titles.count), checkmark.frame.height)
        let titleSize: CGSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
        let containerFrame = CGRectMake(sectionSize.width * CGFloat(index), 0, sectionSize.width, sectionSize.height)
        let circleLayerFrame = CGRectInset(containerFrame, checkmark.titleLabelTopMargin/2.0, 0)
        let circleSideLength = circleLayerFrame.height - titleSize.height - checkmark.titleLabelTopMargin
        let middleX = CGRectGetMidX(circleLayerFrame)
        let expectedFrame = CGRectMake(middleX - circleSideLength/2, 0, circleSideLength, circleSideLength)
        
        return expectedFrame
    }
}

class StubTouch: UITouch {
    let location: CGPoint
    
    init(location: CGPoint) {
        self.location = location
    }
    
    override func locationInView(view: UIView?) -> CGPoint {
        return location
    }
}
