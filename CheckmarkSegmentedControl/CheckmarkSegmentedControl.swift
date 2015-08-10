//
//  CheckmarkSegmentedControl.swift
//  CheckmarkSegmentedControl
//
//  Created by Grzegorz Tatarzyn on 27/04/2015.
//  Copyright (c) 2015 gregttn. All rights reserved.
//

import UIKit

class CheckmarkSegmentedControl: UIControl {
    static let minCheckmarkHeight: CGFloat = 20.0
    
    var options: [CheckmarkOption] = []
    var titleFont: UIFont = UIFont.systemFontOfSize(12.0)
    var titleColor: UIColor = UIColor.blackColor()
    var titleLabelTopMargin: CGFloat = 6.0
    var strokeColor: UIColor = UIColor.blackColor() {
        didSet {
            options = options.map({CheckmarkOption(title: $0.title, borderColor: self.strokeColor, fillColor: $0.fillColor)})
        }
    }
    
    var lineWidth: CGFloat = 3.0 {
        didSet {
            self.tickLineWidth = lineWidth
            self.circleBorderLineWidth = lineWidth * 2
            
            setNeedsDisplay()
        }
    }
    
    var animationLength: CFTimeInterval = 0.4
    
    var selectedIndex: Int {
        get {
            return _selectedIndex
        }
        
        set {
            switch newValue{
                case 0..<options.count:
                    _selectedIndex = newValue
                case let v where v >= options.count:
                    _selectedIndex = options.count - 1
                default:
                    _selectedIndex = 0
            }
        }
    }
    
    private var tickLineWidth: CGFloat = 0
    private var circleBorderLineWidth: CGFloat = 0
    private var _selectedIndex = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let largestLabelSize = options.map({ self.sizeForLabel($0.title) })
                                    .sorted({ $0.width > $1.width}).first
        
        if let largestLabelSize = largestLabelSize {
            let minAllowedSize = CGSizeMake(largestLabelSize.width * CGFloat(options.count), largestLabelSize.height + CheckmarkSegmentedControl.minCheckmarkHeight)
            var width: CGFloat = size.width
            var height: CGFloat = size.height
            
            if (size.width < minAllowedSize.width) {
                width = minAllowedSize.width
            }
            
            if (size.height < minAllowedSize.height) {
                height = minAllowedSize.height
            }
            
            return CGSize(width: width, height: height)
        }
        
        return size
    }
    
    private func setup() {
        layer.masksToBounds = true
        lineWidth = 3.0
    }
    
    override func drawRect(rect: CGRect) {
        let sectionSize: CGSize = CGSizeMake(rect.width / CGFloat(options.count), rect.height)
        
        self.layer.sublayers = nil
        
        for index in (0..<options.count) {
            let option = options[index]
            let containerFrame = CGRectIntegral(CGRectMake(sectionSize.width * CGFloat(index), 0, sectionSize.width, sectionSize.height))
            
            let label = createTitleLabel(containerFrame, content: option.title)
            layer.addSublayer(label)
            
            let remainingContainerFrame = CGRectIntegral(CGRectInset(containerFrame, 0, (label.frame.height + titleLabelTopMargin)/2))
            let borderLayer = createCircleLayer(remainingContainerFrame, option: option)
            layer.addSublayer(borderLayer)
            
            if index == _selectedIndex {
                animateCircleBorder(borderLayer)
                
                let tickLayer = createTick(borderLayer.frame, strokeColor: option.borderColor)
                layer.addSublayer(tickLayer)
            }
        }
    }
    
    private func createTitleLabel(containerFrame: CGRect, content: String) -> CATextLayer {
        let labelSize = sizeForLabel(content)
        let labelFrame = CGRectMake(containerFrame.origin.x, containerFrame.height - labelSize.height, containerFrame.width, labelSize.height)
        
        let label: CATextLayer = CATextLayer()
        label.frame = CGRectIntegral(labelFrame)
        label.font = titleFont
        label.fontSize = titleFont.pointSize
        label.string = content
        label.alignmentMode = kCAAlignmentCenter
        label.foregroundColor = titleColor.CGColor
        
        adjustScale(label)
        
        return label
    }
    
    private func createCircleLayer(containerFrame: CGRect, option: CheckmarkOption) -> CAShapeLayer {
        let height = min(containerFrame.width, containerFrame.height)
        let xOffset = CGRectGetMidX(containerFrame) - height/2
        let frame = CGRectMake(xOffset, 0, height, height)
        let cornerRadius = ceil(frame.height/2)
        
        let borderLayer: CAShapeLayer = CAShapeLayer()
        borderLayer.frame = frame
        borderLayer.lineWidth = circleBorderLineWidth
        borderLayer.fillColor = UIColor.clearColor().CGColor
        borderLayer.backgroundColor = option.fillColor.CGColor
        borderLayer.cornerRadius = cornerRadius
        borderLayer.strokeColor = option.borderColor.CGColor
        borderLayer.strokeEnd = 0
        borderLayer.masksToBounds = true
        
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: cornerRadius).CGPath
        
        adjustScale(borderLayer)
        
        return borderLayer
    }
    
    private func createTick(containerFrame: CGRect, strokeColor: UIColor) -> CAShapeLayer {
        let tickPath = UIBezierPath()
        tickPath.moveToPoint(CGPointMake(0, 0))
        tickPath.addLineToPoint(CGPointMake(0, tickLineWidth * 3))
        tickPath.addLineToPoint(CGPointMake(tickLineWidth * 5, tickLineWidth * 3))
        tickPath.addLineToPoint(CGPointMake(tickLineWidth * 5, tickLineWidth * 2))
        tickPath.addLineToPoint(CGPointMake(tickLineWidth, tickLineWidth * 2))
        tickPath.addLineToPoint(CGPointMake(tickLineWidth, 0))
        tickPath.closePath()
        tickPath.applyTransform(CGAffineTransformMakeRotation(CGFloat(-M_PI_4)))
        
        let tickBorderLayer: CAShapeLayer = CAShapeLayer()
        tickBorderLayer.frame = CGRectMake(CGRectGetMidX(containerFrame) - (5*tickLineWidth)/2.0, CGRectGetMidY(containerFrame), containerFrame.width, containerFrame.height)
        tickBorderLayer.lineWidth = 1
        tickBorderLayer.fillColor = strokeColor.CGColor
        tickBorderLayer.path = tickPath.CGPath
        
        adjustScale(tickBorderLayer)
        
        return tickBorderLayer
    }
    
    private func adjustScale(layer: CALayer) {
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.contentsScale = UIScreen.mainScreen().scale
    }
    
    // MARK: animations
    private func animateCircleBorder(layer: CAShapeLayer) {
        layer.strokeEnd = 1.0
        let animationKey = "strokeEnd"
        let animation: CABasicAnimation = CABasicAnimation(keyPath: animationKey)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = animationLength
        animation.fromValue = 0.0
        animation.toValue = 1.0

        layer.addAnimation(animation, forKey: animationKey)
    }
    
    // MARK: respond to touches

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch: UITouch = touches.first as! UITouch
        let location = touch.locationInView(self)

        if CGRectContainsPoint(bounds, location) {
            let sectionWidth = self.bounds.width / CGFloat(options.count)
            let index = Int(location.x / sectionWidth)
            
            if selectedIndex != index {
                selectedIndex = index
                
                sendActionsForControlEvents(UIControlEvents.ValueChanged)
            }
            
        }
    }
    
    private func sizeForLabel(text: String) -> CGSize {
        let textAttributes = [NSFontAttributeName : titleFont]
        let string: NSString = text
        
        return string.sizeWithAttributes(textAttributes)
    }
}

struct CheckmarkOption: Printable {
    let title: String
    let borderColor: UIColor
    let fillColor: UIColor
    var description: String {
        return "CheckmarkOption[title: \(title)]"
    }
    
    init(title: String, borderColor: UIColor = UIColor.blackColor(), fillColor: UIColor = UIColor.lightGrayColor()) {
        self.title = title
        self.borderColor = borderColor
        self.fillColor = fillColor
    }
}