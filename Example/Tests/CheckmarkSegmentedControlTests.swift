//
//  CheckmarkSegmentedControlTests.swift
//  CheckmarkSegmentedControlTests
//
//  Created by Grzegorz Tatarzyn on 27/04/2015.
//  Copyright (c) 2015 gregttn. All rights reserved.
//

import UIKit
import XCTest
import CheckmarkSegmentedControl

class CheckmarkSegmentedControlTests: XCTestCase {
    enum LayerIndex: Int {
        case Text = 0
        case Circle = 1
        case Tick = 2
    }
    
    var checkmark: CheckmarkSegmentedControl!
    let defaultOptions: [CheckmarkOption] = [CheckmarkOption(title:"option"), CheckmarkOption(title:"another option")]
    let coloredOptiones: [CheckmarkOption] = [CheckmarkOption(title: "Option", fillColor: UIColor.whiteColor(), borderColor: UIColor.redColor()),
        CheckmarkOption(title: "Another option", fillColor: UIColor.yellowColor(), borderColor: UIColor.blueColor())]
    let numberOfLayers = 3
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        checkmark = CheckmarkSegmentedControl(frame: CGRectMake(0, 0, 500, 60))
        checkmark.options = defaultOptions
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShouldPlaceTitlesAtTheBottomOfTheContainer() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<defaultOptions.count) {
            let layerIndex = index * numberOfLayers
            let titleLayer: CATextLayer = checkmark.layer.sublayers[layerIndex] as! CATextLayer
            let sectionContainerWidth = checkmark.frame.width / CGFloat(checkmark.options.count)
            let expectedSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
            let expectedOrigin = CGPoint(x: CGFloat(index) * sectionContainerWidth, y:checkmark.frame.height - expectedSize.height)
            
            let expectedFrame = CGRectIntegral(CGRectMake(expectedOrigin.x, expectedOrigin.y, sectionContainerWidth, expectedSize.height))
            
            XCTAssertEqualWithAccuracy(titleLayer.frame.origin.x, expectedFrame.origin.x, 0.1, "Incorrect x origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.origin.y, expectedFrame.origin.y, 0.1, "Incorrect y origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.width, expectedFrame.width, 0.1, "Incorrect width for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(titleLayer.frame.height, expectedFrame.height, 0.1, "Incorrect height for: \(checkmark.options[index])")
        }
    }
    
    func testTitleLablesShouldHaveCorrectTitels() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index * numberOfLayers] as! CATextLayer
            
            XCTAssertEqual(titleLayer.string as! String, checkmark.options[index].title)
        }
    }

    func testTitleLabelContentIsCentered() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index * numberOfLayers] as! CATextLayer
            
            XCTAssertEqual(titleLayer.alignmentMode, kCAAlignmentCenter)
        }
    }
    
    func testShouldChangeTitleColor() {
        checkmark.titleColor = UIColor.blueColor()
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers[index * numberOfLayers] as! CATextLayer
            
            XCTAssertTrue(CGColorEqualToColor(titleLayer.foregroundColor, UIColor.blueColor().CGColor))
        }
    }
    
    func testShouldDrawCirlceAboveTitleLabel() {
        checkmark.titleLabelTopMargin = 15.0
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            let expectedFrame = expectedFrameFor(circleLayer, frame: checkmark.frame, index: index)
            
            XCTAssertEqualWithAccuracy(circleLayer.frame.origin.x, expectedFrame.origin.x, 0.1, "Incorrect circle x origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(circleLayer.frame.origin.y, expectedFrame.origin.y, 0.1, "Incorrect circle y origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(circleLayer.frame.width, expectedFrame.width, 0.1, "Incorrect circle w origin for: \(checkmark.options[index])")
            XCTAssertEqualWithAccuracy(circleLayer.frame.height, expectedFrame.height, 0.1, "Incorrect circle height for: \(checkmark.options[index])")
        }
    }
    
    func testCircleLayerMasksToBounds() {
        checkmark.titleLabelTopMargin = 15.0
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            
            XCTAssertTrue(circleLayer.masksToBounds)
        }
    }
    
    func testUseFrameWidthInsteadOfHeightIfSmallerThanHeightForCircleFrame() {
        let frame = CGRectMake(0, 0, 100, 500)
        checkmark.drawRect(frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let sectionSize: CGSize = CGSizeMake(frame.width / CGFloat(checkmark.options.count), frame.height)
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            
            let titleSize: CGSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
            let containerFrame = CGRectMake(sectionSize.width * CGFloat(index), 0, sectionSize.width, sectionSize.height)
            let circleLayerFrame = CGRectInset(containerFrame, 0, (titleSize.height + checkmark.titleLabelTopMargin)/2)
            let middleX = CGRectGetMidX(circleLayerFrame)
            let expectedFrame = CGRectMake(middleX - circleLayerFrame.width/2, 0, circleLayerFrame.width, circleLayerFrame.width)
            
            XCTAssertEqual(circleLayer.frame, expectedFrame)
        }
    }
    
    func testBorderLayerHasDoubleTheSetLineWidth() {
        checkmark.lineWidth = 2.0
        
        checkmark.drawRect(checkmark.frame)
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers[LayerIndex.Circle.rawValue] as! CAShapeLayer
        
        XCTAssertEqual(borderLayer.lineWidth , 4)
    }
    
    func testShouldPresentFirstOptionAsSelectedByDefault() {
        checkmark.strokeColor = UIColor.blueColor()
        checkmark.drawRect(checkmark.frame)
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers[LayerIndex.Circle.rawValue] as! CAShapeLayer
        
        let expectedFrame = expectedFrameFor(borderLayer, frame: checkmark.frame, index: 0)
        
        XCTAssertTrue(CGColorEqualToColor(borderLayer.strokeColor, UIColor.blueColor().CGColor))
        XCTAssertTrue(CGColorEqualToColor(borderLayer.fillColor, UIColor.clearColor().CGColor))
        XCTAssertEqual(borderLayer.strokeEnd, 1.0)
        XCTAssertEqual(borderLayer.frame, expectedFrame)
    }
    
    func testShouldAllowToSetSelectedOption() {
        checkmark.strokeColor = UIColor.blueColor()
        checkmark.selectedIndex = 1
        
        checkmark.drawRect(checkmark.frame)
        
        let firstLayerIndex = LayerIndex.Circle.rawValue
        XCTAssertTrue(checkmark.layer.sublayers[firstLayerIndex].isKindOfClass(CAShapeLayer))
        XCTAssertEqual(checkmark.layer.sublayers[firstLayerIndex].strokeEnd, 0.0)
        
        let layerIndex = LayerIndex.Circle.rawValue * (checkmark.selectedIndex*numberOfLayers)
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers[layerIndex] as! CAShapeLayer
        let expectedFrame = expectedFrameFor(borderLayer, frame: checkmark.frame, index: 1)
        
        XCTAssertTrue(CGColorEqualToColor(borderLayer.strokeColor, UIColor.blueColor().CGColor))
        XCTAssertTrue(CGColorEqualToColor(borderLayer.fillColor, UIColor.clearColor().CGColor))
        XCTAssertEqual(borderLayer.strokeEnd, 1.0)
        XCTAssertEqual(borderLayer.frame, expectedFrame)
    }
    
    func testShouldClearSubleyersBeforeDrawing() {
        checkmark.strokeColor = UIColor.blueColor()
        checkmark.selectedIndex = 1
        
        checkmark.drawRect(checkmark.frame)
        
        XCTAssertEqual(checkmark.layer.sublayers.count, 5)
        
        checkmark.drawRect(checkmark.frame)
        
        XCTAssertEqual(checkmark.layer.sublayers.count, 5)
    }
    
    func testShouldNotAllowNegativeValueToBeAssignedToSelectedIndex() {
        checkmark.selectedIndex = -1
        
        XCTAssertEqual(checkmark.selectedIndex, 0)
    }
    
    func testShouldSetSelectedToMaxIndexOfTitlesIfGreaterValuePassed() {
        checkmark.selectedIndex = defaultOptions.count
        
        XCTAssertEqual(checkmark.selectedIndex, 1)
    }
    
    func testShouldChangeSelectedElementOnTap() {
        let point = CGPointMake(checkmark.frame.width/CGFloat(checkmark.options.count) + 10 ,10)
        let touch = StubTouch(location: point)
        
        checkmark.touchesBegan([touch], withEvent: UIEvent())
        
        XCTAssertEqual(checkmark.selectedIndex, 1)
    }
    
    func testShouldSendValueChangedEventWhenNewValueselected() {
        let point = CGPointMake(checkmark.frame.width/CGFloat(checkmark.options.count) + 10 ,10)
        let touch = StubTouch(location: point)
        
        var captor: EventCaptor = EventCaptor()
        checkmark.addTarget(captor, action: "capture", forControlEvents: UIControlEvents.ValueChanged)
        checkmark.touchesBegan([touch], withEvent: UIEvent())
        
        XCTAssertTrue(captor.captured)
    }
    
    func testShouldResizeZeroFrameToMinimumSize() {
        let largestLabelSize = defaultOptions.map({ self.sizeForText($0, font: self.checkmark.titleFont) })
            .sorted({ $0.width > $1.width}).first!
        let bestWidth = Int(largestLabelSize.width) * checkmark.options.count
        let bestHeight = Int(largestLabelSize.height + CheckmarkSegmentedControl.minCheckmarkHeight)
        
        let resultSize = checkmark.sizeThatFits(CGSizeZero)

        XCTAssertEqual(Int(resultSize.width), bestWidth)
        XCTAssertEqual(Int(resultSize.height), bestHeight)
    }
    
    func testShouldNotChangeCorrectSize() {
        let additionalLength = 50
        let largestLabelSize = defaultOptions.map({ self.sizeForText($0, font: self.checkmark.titleFont) })
            .sorted({ $0.width > $1.width}).first!
        
        let bestWidth = Int(largestLabelSize.width) * checkmark.options.count
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
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            
            XCTAssertTrue(CGColorEqualToColor(circleLayer.backgroundColor, UIColor.lightGrayColor().CGColor))
        }
    }
    
    func testShouldDrawEachOptionWithCorrectFillColor() {
        checkmark.options = coloredOptiones
        
        checkmark.drawRect(checkmark.frame)

        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers[layerIndex] as! CALayer
            
            XCTAssertTrue(CGColorEqualToColor(circleLayer.backgroundColor, checkmark.options[index].fillColor.CGColor))
        }
    }
    
    func testShouldDrawSelectedOptionBorderWithDefaultFillColor() {
        checkmark.drawRect(checkmark.frame)
        
        let layerIndex = LayerIndex.Circle.rawValue
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers[layerIndex] as! CAShapeLayer
        
        XCTAssertTrue(CGColorEqualToColor(borderLayer.strokeColor, UIColor.blackColor().CGColor))
        
    }
    
    func testShouldDrawSelectedOptionBorderWithCustomFillColor() {
        checkmark.options = coloredOptiones
        checkmark.drawRect(checkmark.frame)
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers[LayerIndex.Circle.rawValue] as! CAShapeLayer
        XCTAssertTrue(CGColorEqualToColor(borderLayer.strokeColor, checkmark.options[0].borderColor.CGColor))
    }
    
    func testShouldSelectedOptionBorderWithDefaultFillColor() {
        checkmark.drawRect(checkmark.frame)
        
        let tickLayer: CAShapeLayer = checkmark.layer.sublayers[LayerIndex.Tick.rawValue] as! CAShapeLayer
        
        XCTAssertTrue(CGColorEqualToColor(tickLayer.fillColor, UIColor.blackColor().CGColor))
        
    }
    
    func testShouldDrawSelectedOptionTickBorderWithCustomFillColor() {
        checkmark.options = coloredOptiones
        checkmark.drawRect(checkmark.frame)
        
        let tickLayer: CAShapeLayer = checkmark.layer.sublayers[LayerIndex.Tick.rawValue] as! CAShapeLayer
        XCTAssertTrue(CGColorEqualToColor(tickLayer.fillColor, checkmark.options[0].borderColor.CGColor))
    }
    
    func testShouldMaskToBounds() {
        XCTAssertTrue(checkmark.layer.masksToBounds)
    }
    
    func testContentModeSetToRedraw() {
        XCTAssertEqual(checkmark.contentMode, UIViewContentMode.Redraw)
    }
    
    // helpers
    private func sizeForText(option: CheckmarkOption, font: UIFont) -> CGSize {
        let textAttributes = [NSFontAttributeName : font]
        let string: NSString = option.title

        return string.sizeWithAttributes(textAttributes)
    }
    
    private func expectedFrameFor(layer: CALayer, frame: CGRect, index: Int) -> CGRect {
        let sectionSize: CGSize = CGSizeMake(checkmark.frame.width / CGFloat(checkmark.options.count), checkmark.frame.height)
        let containerFrame = CGRectIntegral(CGRectMake(sectionSize.width * CGFloat(index), 0, sectionSize.width, sectionSize.height))
        
        let titleSize: CGSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
        let titleFrame = CGRectIntegral(CGRectMake(0, 0, titleSize.width, titleSize.height))
        
        let circleLayerFrame = CGRectIntegral(CGRectInset(containerFrame, checkmark.titleLabelTopMargin/2, (titleFrame.height + checkmark.titleLabelTopMargin)/2))
        let middleX = CGRectGetMidX(circleLayerFrame)
        let expectedFrame = CGRectIntegral(CGRectMake(middleX - circleLayerFrame.height/2, 0, circleLayerFrame.height, circleLayerFrame.height))
        
        return expectedFrame
    }
}

class EventCaptor: NSObject {
    var captured = false
    
    func capture() {
        self.captured = true
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
