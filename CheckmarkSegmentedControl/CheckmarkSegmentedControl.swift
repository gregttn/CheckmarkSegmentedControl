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
    var titleLabelTopMargin: CGFloat = 12.0
    var strokeColor: UIColor = UIColor.blackColor()
    var lineWidth: CGFloat = 3.0
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
    }
    
    override func drawRect(rect: CGRect) {
        let sectionSize: CGSize = CGSizeMake(rect.width / CGFloat(options.count), rect.height)
        
        self.layer.sublayers = nil
        
        for index in (0..<options.count) {
            let containerFrame = CGRectMake(sectionSize.width * CGFloat(index), 0, sectionSize.width, sectionSize.height)
            
            let label = createTitleLabel(containerFrame, content: options[index].title)
            layer.addSublayer(label)
            
            let circleLayer = createCircleLayer(containerFrame, titleLabelFrame: label.frame)
            layer.addSublayer(circleLayer)
            
            if index == _selectedIndex {
                let borderLayer = createCircleBorder(circleLayer.frame, bounds: circleLayer.bounds)
                animateCircleBorder(borderLayer)
                layer.addSublayer(borderLayer)
                
                let tickLayer = createTick(circleLayer.frame)
                layer.addSublayer(tickLayer)
            }
        }
    }
    
    private func createTitleLabel(containerFrame: CGRect, content: String) -> CATextLayer {
        let labelSize = sizeForLabel(content)
        let labelFrame = CGRectMake(containerFrame.origin.x, containerFrame.height - labelSize.height, containerFrame.width, labelSize.height)
        
        let label: CATextLayer = CATextLayer()
        label.frame = labelFrame
        label.font = titleFont
        label.fontSize = titleFont.pointSize
        label.string = content
        label.alignmentMode = kCAAlignmentCenter
        label.foregroundColor = titleColor.CGColor
        label.contentsScale = UIScreen.mainScreen().scale
        
        return label
    }
    
    private func createCircleLayer(containerFrame: CGRect, titleLabelFrame: CGRect) -> CALayer {
        let frame = CGRectInset(containerFrame, titleLabelTopMargin/2, (titleLabelFrame.height + titleLabelTopMargin)/2)
        let height = frame.height > frame.width ? frame.width : frame.height
        
        let circleLayer: CALayer = CALayer()
        circleLayer.frame = CGRectMake(CGRectGetMidX(frame) - height/2, 0, height, height)
        circleLayer.cornerRadius = height/2
        circleLayer.backgroundColor = UIColor.lightGrayColor().CGColor
        
        return circleLayer
    }
    
    private func createCircleBorder(frame: CGRect, bounds: CGRect) -> CAShapeLayer {
        let borderLayer: CAShapeLayer = CAShapeLayer()
        borderLayer.frame = frame
        borderLayer.lineWidth = lineWidth
        borderLayer.fillColor = UIColor.clearColor().CGColor
        borderLayer.strokeColor = strokeColor.CGColor
        borderLayer.strokeEnd = 1.0
        borderLayer.path = UIBezierPath(ovalInRect:CGRectInset(bounds, lineWidth/2, lineWidth/2)).CGPath
        
        return borderLayer
    }
    
    private func createTick(containerFrame: CGRect) -> CAShapeLayer {
        let tickBorderLayer: CAShapeLayer = CAShapeLayer()
        tickBorderLayer.frame = CGRectMake(CGRectGetMidX(containerFrame) - (5*lineWidth)/2.0, CGRectGetMidY(containerFrame), containerFrame.width, containerFrame.height)
        tickBorderLayer.lineWidth = 1
        tickBorderLayer.fillColor = strokeColor.CGColor
        
        let tickPath = UIBezierPath()
        let tickWidth: CGFloat = lineWidth
        tickPath.moveToPoint(CGPointMake(0, 0))
        tickPath.addLineToPoint(CGPointMake(0, tickWidth * 3))
        tickPath.addLineToPoint(CGPointMake(tickWidth * 5, tickWidth * 3))
        tickPath.addLineToPoint(CGPointMake(tickWidth * 5, tickWidth * 2))
        tickPath.addLineToPoint(CGPointMake(tickWidth, tickWidth * 2))
        tickPath.addLineToPoint(CGPointMake(tickWidth, 0))
        tickPath.closePath()
        
        tickPath.applyTransform(CGAffineTransformMakeRotation(CGFloat(-M_PI_4)))
        
        tickBorderLayer.path = tickPath.CGPath
        
        return tickBorderLayer
    }
    
    // MARK: animations
    
    private func animateCircleBorder(layer: CAShapeLayer) {
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
            }
        }
    }
    
    private func sizeForLabel(text: String) -> CGSize {
        let textAttributes = [NSFontAttributeName : titleFont]
        let string: NSString = text
        
        return string.sizeWithAttributes(textAttributes)
    }
}

struct CheckmarkOption {
    let title: String
    let borderColor: UIColor
    let fillColor: UIColor
    
    init(title: String, borderColor: UIColor = UIColor.blackColor(), fillColor: UIColor = UIColor.lightGrayColor()) {
        self.title = title
        self.borderColor = borderColor
        self.fillColor = fillColor
    }
}