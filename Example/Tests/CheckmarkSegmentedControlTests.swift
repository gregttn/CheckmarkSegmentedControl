//
//  CheckmarkSegmentedControlTests.swift
//  CheckmarkSegmentedControlTests
//
//  Created by Grzegorz Tatarzyn on 27/04/2015.
//  Copyright (c) 2015 gregttn. All rights reserved.
//

import UIKit
import XCTest
import Nimble
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
            let layerIndex: Int = index * numberOfLayers
            let titleLayer: CATextLayer = checkmark.layer.sublayers![layerIndex] as! CATextLayer
            let sectionContainerWidth = checkmark.frame.width / CGFloat(checkmark.options.count)
            let expectedSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
            let expectedOrigin = CGPoint(x: CGFloat(index) * sectionContainerWidth, y:checkmark.frame.height - expectedSize.height)
            
            let expectedFrame = CGRectIntegral(CGRectMake(expectedOrigin.x, expectedOrigin.y, sectionContainerWidth, expectedSize.height))
            
            expect(titleLayer.frame) == expectedFrame
        }
    }
    
    func testTitleLablesShouldHaveCorrectTitels() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers![index * numberOfLayers] as! CATextLayer
            
            expect(titleLayer.string as? String) == checkmark.options[index].title
        }
    }
    
    func testTitleLabelContentIsCentered() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers![index * numberOfLayers] as! CATextLayer
            
            expect(titleLayer.alignmentMode) == kCAAlignmentCenter
        }
    }
    
    func testShouldChangeTitleColor() {
        checkmark.titleColor = UIColor.blueColor()
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers![index * numberOfLayers] as! CATextLayer
            
            expect(titleLayer.foregroundColor).to(beColor(.blueColor()))
        }
    }
    
    func testShouldDrawCirlceAboveTitleLabel() {
        checkmark.titleLabelTopMargin = 15.0
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            let expectedFrame = expectedFrameFor(circleLayer, frame: checkmark.frame, index: index)
            
            expect(circleLayer.frame) == expectedFrame
        }
    }
    
    func testCircleLayerMasksToBounds() {
        checkmark.titleLabelTopMargin = 15.0
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            
            expect(circleLayer.masksToBounds).to(beTrue())
        }
    }
    
    func testUseFrameWidthInsteadOfHeightIfSmallerThanHeightForCircleFrame() {
        let frame = CGRectMake(0, 0, 100, 500)
        checkmark.drawRect(frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let sectionSize: CGSize = CGSizeMake(frame.width / CGFloat(checkmark.options.count), frame.height)
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            
            let titleSize: CGSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
            let containerFrame = CGRectMake(sectionSize.width * CGFloat(index), 0, sectionSize.width, sectionSize.height)
            let circleLayerFrame = CGRectInset(containerFrame, 0, (titleSize.height + checkmark.titleLabelTopMargin)/2)
            let middleX = CGRectGetMidX(circleLayerFrame)
            let expectedFrame = CGRectMake(middleX - circleLayerFrame.width/2, 0, circleLayerFrame.width, circleLayerFrame.width)
            
            expect(circleLayer.frame) == expectedFrame
        }
    }
    
    func testBorderLayerHasDoubleTheSetLineWidth() {
        checkmark.lineWidth = 2.0
        
        checkmark.drawRect(checkmark.frame)
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.Circle.rawValue] as! CAShapeLayer
        
        expect(borderLayer.lineWidth) == 4
    }
    
    func testShouldPresentFirstOptionAsSelectedByDefault() {
        checkmark.strokeColor = UIColor.blueColor()
        checkmark.drawRect(checkmark.frame)
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.Circle.rawValue] as! CAShapeLayer
        
        let expectedFrame = expectedFrameFor(borderLayer, frame: checkmark.frame, index: 0)
        
        expect(borderLayer.strokeColor).to(beColor(UIColor.blueColor()))
        expect(borderLayer.fillColor).to(beColor(UIColor.clearColor()))
        expect(borderLayer.strokeEnd) == 1.0
        expect(borderLayer.frame) == expectedFrame
    }
    
    func testShouldAllowToSetSelectedOption() {
        checkmark.strokeColor = UIColor.blueColor()
        checkmark.selectedIndex = 1
        
        checkmark.drawRect(checkmark.frame)
        
        let firstLayerIndex = LayerIndex.Circle.rawValue
        expect(self.checkmark.layer.sublayers![firstLayerIndex].isKindOfClass(CAShapeLayer)).to(beTrue())
        let layer = self.checkmark.layer.sublayers![firstLayerIndex] as! CAShapeLayer
        expect(layer.strokeEnd) == 0.0
        
        let layerIndex = LayerIndex.Circle.rawValue * (checkmark.selectedIndex*numberOfLayers)
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![layerIndex] as! CAShapeLayer
        let expectedFrame = expectedFrameFor(borderLayer, frame: checkmark.frame, index: 1)
        
        expect(borderLayer.strokeColor).to(beColor(UIColor.blueColor()))
        expect(borderLayer.fillColor).to(beColor(UIColor.clearColor()))
        expect(borderLayer.strokeEnd) == 1.0
        expect(borderLayer.frame) == expectedFrame
    }
    
    func testShouldClearSubleyersBeforeDrawing() {
        checkmark.strokeColor = UIColor.blueColor()
        checkmark.selectedIndex = 1
        
        checkmark.drawRect(checkmark.frame)
        expect(self.checkmark.layer.sublayers!.count) == 5
        
        checkmark.drawRect(checkmark.frame)
        expect(self.checkmark.layer.sublayers!.count) == 5
    }
    
    func testShouldNotAllowNegativeValueToBeAssignedToSelectedIndex() {
        checkmark.selectedIndex = -1
        
        expect(self.checkmark.selectedIndex) == 0
    }
    
    func testShouldSetSelectedToMaxIndexOfTitlesIfGreaterValuePassed() {
        checkmark.selectedIndex = defaultOptions.count
        
        expect(self.checkmark.selectedIndex) == 1
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
        
        let captor: EventCaptor = EventCaptor()
        checkmark.addTarget(captor, action: "capture", forControlEvents: UIControlEvents.ValueChanged)
        checkmark.touchesBegan([touch], withEvent: UIEvent())
        
        expect(captor.captured).to(beTrue())
    }
    
    func testShouldResizeZeroFrameToMinimumSize() {
        let largestLabelSize = defaultOptions.map({ self.sizeForText($0, font: self.checkmark.titleFont) })
            .sort({ $0.width > $1.width}).first!
        let bestWidth: CGFloat = largestLabelSize.width * CGFloat(checkmark.options.count)
        let bestHeight: CGFloat = largestLabelSize.height + CGFloat(CheckmarkSegmentedControl.minCheckmarkHeight)
        
        let resultSize = checkmark.sizeThatFits(CGSizeZero)
        
        expect(resultSize.width).to(equal(bestWidth))
        expect(resultSize.height).to(equal(bestHeight))
    }
    
    func testShouldNotChangeCorrectSize() {
        let additionalLength = 50
        let largestLabelSize = defaultOptions.map({ self.sizeForText($0, font: self.checkmark.titleFont) })
            .sort({ $0.width > $1.width}).first!
        
        let bestWidth = Int(largestLabelSize.width) * checkmark.options.count
        let bestHeight = Int(largestLabelSize.height + CheckmarkSegmentedControl.minCheckmarkHeight)
        
        let size = CGSize(width: bestWidth + additionalLength, height: bestHeight + additionalLength)
        let resultSize = checkmark.sizeThatFits(size)
        
        expect(resultSize) == size
    }
    
    func testShouldReturnSameSizeIfNoElementsToDisplay() {
        checkmark.options.removeAll()
        
        let size = CGSize(width: 100, height:100)
        let resultSize = checkmark.sizeThatFits(size)
        
        expect(resultSize) == size
    }
    
    func testShouldDrawEachOptionWithDefaultFillColor() {
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            expect(circleLayer.backgroundColor).to(beColor(.lightGrayColor()))
        }
    }
    
    func testShouldDrawEachOptionWithCorrectFillColor() {
        checkmark.options = coloredOptiones
        
        checkmark.drawRect(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.Circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            
            expect(circleLayer.backgroundColor).to(beColor(checkmark.options[index].fillColor))
        }
    }
    
    func testShouldDrawSelectedOptionBorderWithDefaultFillColor() {
        checkmark.drawRect(checkmark.frame)
        
        let layerIndex = LayerIndex.Circle.rawValue
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![layerIndex] as! CAShapeLayer
        
        expect(borderLayer.strokeColor).to(beColor(.blackColor()))
    }
    
    func testShouldDrawSelectedOptionBorderWithCustomFillColor() {
        checkmark.options = coloredOptiones
        checkmark.drawRect(checkmark.frame)
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.Circle.rawValue] as! CAShapeLayer
        expect(borderLayer.strokeColor).to(beColor(checkmark.options[0].borderColor))
    }
    
    func testShouldSelectedOptionBorderWithDefaultFillColor() {
        checkmark.drawRect(checkmark.frame)
        
        let tickLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.Tick.rawValue] as! CAShapeLayer
        expect(tickLayer.fillColor).to(beColor(.blackColor()))
    }
    
    func testShouldDrawSelectedOptionTickBorderWithCustomFillColor() {
        checkmark.options = coloredOptiones
        checkmark.drawRect(checkmark.frame)
        
        let tickLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.Tick.rawValue] as! CAShapeLayer
        expect(tickLayer.fillColor).to(beColor(checkmark.options[0].borderColor))
    }
    
    func testShouldMaskToBounds() {
        expect(self.checkmark.layer.masksToBounds).to(beTrue())
    }
    
    func testContentModeSetToRedraw() {
        expect(self.checkmark.contentMode) == UIViewContentMode.Redraw
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
    
    func beColor(expectedColor: UIColor) -> NonNilMatcherFunc<CGColor> {
        return NonNilMatcherFunc {
            actualExpression, failureMessage in
            failureMessage.postfixMessage = "be equal to color \(expectedColor)"
            
            if let value = try actualExpression.evaluate() {
                return CGColorEqualToColor(value, expectedColor.CGColor)
            }
            
            
            return false
        }
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
