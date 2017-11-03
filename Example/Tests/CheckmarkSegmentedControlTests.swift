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
        case text = 0
        case circle = 1
        case tick = 2
    }
    
    var checkmark: CheckmarkSegmentedControl!
    let defaultOptions: [CheckmarkOption] = [CheckmarkOption(title:"option"), CheckmarkOption(title:"another option")]
    let coloredOptiones: [CheckmarkOption] = [CheckmarkOption(title: "Option", borderColor: UIColor.red, fillColor: UIColor.white),
        CheckmarkOption(title: "Another option", borderColor: UIColor.blue, fillColor: UIColor.yellow)]
    let numberOfLayers = 3
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        checkmark = CheckmarkSegmentedControl(frame: CGRect(x: 0, y: 0, width: 500, height: 60))
        checkmark.options = defaultOptions
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShouldPlaceTitlesAtTheBottomOfTheContainer() {
        checkmark.draw(checkmark.frame)
        
        for index in (0..<defaultOptions.count) {
            let layerIndex: Int = index * numberOfLayers
            let titleLayer: CATextLayer = checkmark.layer.sublayers![layerIndex] as! CATextLayer
            let sectionContainerWidth = checkmark.frame.width / CGFloat(checkmark.options.count)
            let expectedSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
            let expectedOrigin = CGPoint(x: CGFloat(index) * sectionContainerWidth, y:checkmark.frame.height - expectedSize.height)
            
            let expectedFrame = CGRect(x: expectedOrigin.x, y: expectedOrigin.y, width: sectionContainerWidth, height: expectedSize.height).integral
            
            expect(titleLayer.frame) == expectedFrame
        }
    }
    
    func testTitleLablesShouldHaveCorrectTitels() {
        checkmark.draw(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers![index * numberOfLayers] as! CATextLayer
            
            expect(titleLayer.string as? String) == checkmark.options[index].title
        }
    }
    
    func testTitleLabelContentIsCentered() {
        checkmark.draw(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers![index * numberOfLayers] as! CATextLayer
            
            expect(titleLayer.alignmentMode) == kCAAlignmentCenter
        }
    }
    
    func testShouldChangeTitleColor() {
        checkmark.titleColor = UIColor.blue
        checkmark.draw(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let titleLayer: CATextLayer = checkmark.layer.sublayers![index * numberOfLayers] as! CATextLayer
            
            expect(titleLayer.foregroundColor).to(beColor(.blue))
        }
    }
    
    func testShouldDrawCirlceAboveTitleLabel() {
        checkmark.titleLabelTopMargin = 15.0
        checkmark.draw(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            let expectedFrame = expectedFrameFor(circleLayer, frame: checkmark.frame, index: index)
            
            expect(circleLayer.frame) == expectedFrame
        }
    }
    
    func testCircleLayerMasksToBounds() {
        checkmark.titleLabelTopMargin = 15.0
        checkmark.draw(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            
            expect(circleLayer.masksToBounds).to(beTrue())
        }
    }
    
    func testUseFrameWidthInsteadOfHeightIfSmallerThanHeightForCircleFrame() {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 500)
        checkmark.draw(frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.circle.rawValue
            let sectionSize: CGSize = CGSize(width: frame.width / CGFloat(checkmark.options.count), height: frame.height)
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            
            let titleSize: CGSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
            let containerFrame = CGRect(x: sectionSize.width * CGFloat(index), y: 0, width: sectionSize.width, height: sectionSize.height)
            let circleLayerFrame = containerFrame.insetBy(dx: 0, dy: (titleSize.height + checkmark.titleLabelTopMargin)/2)
            let middleX = circleLayerFrame.midX
            let expectedFrame = CGRect(x: middleX - circleLayerFrame.width/2, y: 0, width: circleLayerFrame.width, height: circleLayerFrame.width)
            
            expect(circleLayer.frame) == expectedFrame
        }
    }
    
    func testBorderLayerHasDoubleTheSetLineWidth() {
        checkmark.lineWidth = 2.0
        
        checkmark.draw(checkmark.frame)
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.circle.rawValue] as! CAShapeLayer
        
        expect(borderLayer.lineWidth) == 4
    }
    
    func testShouldPresentFirstOptionAsSelectedByDefault() {
        checkmark.strokeColor = UIColor.blue
        checkmark.draw(checkmark.frame)
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.circle.rawValue] as! CAShapeLayer
        
        let expectedFrame = expectedFrameFor(borderLayer, frame: checkmark.frame, index: 0)
        
        expect(borderLayer.strokeColor).to(beColor(UIColor.blue))
        expect(borderLayer.fillColor).to(beColor(UIColor.clear))
        expect(borderLayer.strokeEnd) == 1.0
        expect(borderLayer.frame) == expectedFrame
    }
    
    func testShouldAllowToSetSelectedOption() {
        checkmark.strokeColor = UIColor.blue
        checkmark.selectedIndex = 1
        
        checkmark.draw(checkmark.frame)
        
        let firstLayerIndex = LayerIndex.circle.rawValue
        expect(self.checkmark.layer.sublayers![firstLayerIndex].isKind(of:CAShapeLayer.self)).to(beTrue())
        let layer = self.checkmark.layer.sublayers![firstLayerIndex] as! CAShapeLayer
        expect(layer.strokeEnd) == 0.0
        
        let layerIndex = LayerIndex.circle.rawValue * (checkmark.selectedIndex*numberOfLayers)
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![layerIndex] as! CAShapeLayer
        let expectedFrame = expectedFrameFor(borderLayer, frame: checkmark.frame, index: 1)
        
        expect(borderLayer.strokeColor).to(beColor(UIColor.blue))
        expect(borderLayer.fillColor).to(beColor(UIColor.clear))
        expect(borderLayer.strokeEnd) == 1.0
        expect(borderLayer.frame) == expectedFrame
    }
    
    func testShouldClearSubleyersBeforeDrawing() {
        checkmark.strokeColor = UIColor.blue
        checkmark.selectedIndex = 1
        
        checkmark.draw(checkmark.frame)
        expect(self.checkmark.layer.sublayers!.count) == 5
        
        checkmark.draw(checkmark.frame)
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
        let point = CGPoint(x: checkmark.frame.width/CGFloat(checkmark.options.count) + 10 ,y: 10)
        let touch = StubTouch(location: point)
        
        checkmark.touchesBegan([touch], with: UIEvent())
        
        XCTAssertEqual(checkmark.selectedIndex, 1)
    }
    
    func testShouldSendValueChangedEventWhenNewValueselected() {
        let point = CGPoint(x: checkmark.frame.width/CGFloat(checkmark.options.count) + 10 ,y: 10)
        let touch = StubTouch(location: point)
        
        let captor: EventCaptor = EventCaptor()
        checkmark.addTarget(captor, action: #selector(EventCaptor.capture), for: UIControlEvents.valueChanged)
        checkmark.touchesBegan([touch], with: UIEvent())
        
        expect(captor.captured).to(beTrue())
    }
    
    func testShouldResizeZeroFrameToMinimumSize() {
        let largestLabelSize = defaultOptions.map({ self.sizeForText($0, font: self.checkmark.titleFont) })
            .sorted(by: { $0.width > $1.width}).first!
        let bestWidth: CGFloat = largestLabelSize.width * CGFloat(checkmark.options.count)
        let bestHeight: CGFloat = largestLabelSize.height + CGFloat(CheckmarkSegmentedControl.minCheckmarkHeight)
        
        let resultSize = checkmark.sizeThatFits(CGSize.zero)
        
        expect(resultSize.width).to(equal(bestWidth))
        expect(resultSize.height).to(equal(bestHeight))
    }
    
    func testShouldNotChangeCorrectSize() {
        let additionalLength = 50
        let largestLabelSize = defaultOptions.map({ self.sizeForText($0, font: self.checkmark.titleFont) })
            .sorted(by: { $0.width > $1.width}).first!
        
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
        checkmark.draw(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            expect(circleLayer.backgroundColor).to(beColor(.lightGray))
        }
    }
    
    func testShouldDrawEachOptionWithCorrectFillColor() {
        checkmark.options = coloredOptiones
        
        checkmark.draw(checkmark.frame)
        
        for index in (0..<checkmark.options.count) {
            let layerIndex = (index * numberOfLayers) + LayerIndex.circle.rawValue
            let circleLayer: CALayer = checkmark.layer.sublayers![layerIndex]
            
            expect(circleLayer.backgroundColor).to(beColor(checkmark.options[index].fillColor))
        }
    }
    
    func testShouldDrawSelectedOptionBorderWithDefaultFillColor() {
        checkmark.draw(checkmark.frame)
        
        let layerIndex = LayerIndex.circle.rawValue
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![layerIndex] as! CAShapeLayer
        
        expect(borderLayer.strokeColor).to(beColor(.black))
    }
    
    func testShouldDrawSelectedOptionBorderWithCustomFillColor() {
        checkmark.options = coloredOptiones
        checkmark.draw(checkmark.frame)
        
        let borderLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.circle.rawValue] as! CAShapeLayer
        expect(borderLayer.strokeColor).to(beColor(checkmark.options[0].borderColor))
    }
    
    func testShouldSelectedOptionBorderWithDefaultFillColor() {
        checkmark.draw(checkmark.frame)
        
        let tickLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.tick.rawValue] as! CAShapeLayer
        expect(tickLayer.fillColor).to(beColor(.black))
    }
    
    func testShouldDrawSelectedOptionTickBorderWithCustomFillColor() {
        checkmark.options = coloredOptiones
        checkmark.draw(checkmark.frame)
        
        let tickLayer: CAShapeLayer = checkmark.layer.sublayers![LayerIndex.tick.rawValue] as! CAShapeLayer
        expect(tickLayer.fillColor).to(beColor(checkmark.options[0].borderColor))
    }
    
    func testShouldMaskToBounds() {
        expect(self.checkmark.layer.masksToBounds).to(beTrue())
    }
    
    func testContentModeSetToRedraw() {
        expect(self.checkmark.contentMode) == UIViewContentMode.redraw
    }
    
    // helpers
    fileprivate func sizeForText(_ option: CheckmarkOption, font: UIFont) -> CGSize {
        let textAttributes = [NSAttributedStringKey.font : font]
        let string: NSString = option.title as NSString
        
        return string.size(withAttributes: textAttributes)
    }
    
    fileprivate func expectedFrameFor(_ layer: CALayer, frame: CGRect, index: Int) -> CGRect {
        let sectionSize: CGSize = CGSize(width: checkmark.frame.width / CGFloat(checkmark.options.count), height: checkmark.frame.height)
        let containerFrame = CGRect(x: sectionSize.width * CGFloat(index), y: 0, width: sectionSize.width, height: sectionSize.height).integral
        
        let titleSize: CGSize = sizeForText(checkmark.options[index], font: checkmark.titleFont)
        let titleFrame = CGRect(x: 0, y: 0, width: titleSize.width, height: titleSize.height).integral
        
        let circleLayerFrame = containerFrame.insetBy(dx: checkmark.titleLabelTopMargin/2, dy: (titleFrame.height + checkmark.titleLabelTopMargin)/2).integral
        let middleX = circleLayerFrame.midX
        let expectedFrame = CGRect(x: middleX - circleLayerFrame.height/2, y: 0, width: circleLayerFrame.height, height: circleLayerFrame.height).integral
        
        return expectedFrame
    }
    
    func beColor(_ expectedColor: UIColor) -> NonNilMatcherFunc<CGColor> {
        return NonNilMatcherFunc {
            actualExpression, failureMessage in
            failureMessage.postfixMessage = "be equal to color \(expectedColor)"
            
            if let value = try actualExpression.evaluate() {
                return value == expectedColor.cgColor
            }
            
            
            return false
        }
    }

}

class EventCaptor: NSObject {
    var captured = false
    
    @objc func capture() {
        self.captured = true
    }
}

class StubTouch: UITouch {
    let location: CGPoint
    
    init(location: CGPoint) {
        self.location = location
    }
    
    override func location(in view: UIView?) -> CGPoint {
        return location
    }
}
