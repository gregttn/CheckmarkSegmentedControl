//
//  CheckmarkSegmentedControl.swift
//  CheckmarkSegmentedControl
//
//  Created by Grzegorz Tatarzyn on 27/04/2015.
//  Copyright (c) 2015 gregttn. All rights reserved.
//

import UIKit

@IBDesignable
open class CheckmarkSegmentedControl: UIControl {
    open static let minCheckmarkHeight: CGFloat = 20.0
    
    open var options: [CheckmarkOption] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var animationLength: CFTimeInterval = 0.4
    open var titleFont: UIFont = UIFont.systemFont(ofSize: 12.0)
    @IBInspectable open var titleColor: UIColor = UIColor.black
    open var titleLabelTopMargin: CGFloat = 6.0
    open var strokeColor: UIColor = UIColor.black {
        didSet {
            options = options.map({CheckmarkOption(title: $0.title, borderColor: self.strokeColor, fillColor: $0.fillColor)})
        }
    }
    
    open var lineWidth: CGFloat = 3.0 {
        didSet {
            self.tickLineWidth = lineWidth
            self.circleBorderLineWidth = lineWidth * 2
            
            setNeedsDisplay()
        }
    }
    
    open var selectedIndex: Int {
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
    
    fileprivate var tickLineWidth: CGFloat = 0
    fileprivate var circleBorderLineWidth: CGFloat = 0
    fileprivate var _selectedIndex = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup() {
        contentMode = UIViewContentMode.redraw
        layer.masksToBounds = true
        lineWidth = 3.0
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let largestLabelSize = options.map({ self.sizeForLabel($0.title) })
                                    .sorted(by: { $0.width > $1.width}).first
        
        if let largestLabelSize = largestLabelSize {
            let minAllowedSize = CGSize(width: largestLabelSize.width * CGFloat(options.count), height: largestLabelSize.height + CheckmarkSegmentedControl.minCheckmarkHeight)
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
    
    override open func draw(_ rect: CGRect) {
        let sectionSize: CGSize = CGSize(width: rect.width / CGFloat(options.count), height: rect.height)
        
        self.layer.sublayers = nil
        
        for index in (0..<options.count) {
            let option = options[index]
            let containerFrame = CGRect(x: sectionSize.width * CGFloat(index), y: 0, width: sectionSize.width, height: sectionSize.height).integral
            
            let label = createTitleLabel(containerFrame, content: option.title)
            layer.addSublayer(label)
            
            let remainingContainerFrame = containerFrame.insetBy(dx: 0, dy: (label.frame.height + titleLabelTopMargin)/2).integral
            let borderLayer = createCircleLayer(remainingContainerFrame, option: option)
            layer.addSublayer(borderLayer)
            
            if index == _selectedIndex {
                animateCircleBorder(borderLayer)
                
                let tickLayer = createTick(borderLayer.frame, strokeColor: option.borderColor)
                layer.addSublayer(tickLayer)
            }
        }
    }
    
    override open func prepareForInterfaceBuilder() {
        options = [
            CheckmarkOption(title:"Option 1"), // by default black border and light gray colour as background
            CheckmarkOption(title: "Option 2", borderColor: UIColor.orange, fillColor: UIColor.brown),
            CheckmarkOption(title: "Option 3", borderColor: UIColor.brown, fillColor: UIColor.orange),
            CheckmarkOption(title: "Option 4", borderColor: UIColor.green, fillColor: UIColor.blue)
        ]
    }
    
    fileprivate func createTitleLabel(_ containerFrame: CGRect, content: String) -> CATextLayer {
        let labelSize = sizeForLabel(content)
        let labelFrame = CGRect(x: containerFrame.origin.x, y: containerFrame.height - labelSize.height, width: containerFrame.width, height: labelSize.height)
        
        let label: CATextLayer = CATextLayer()
        label.frame = labelFrame.integral
        label.font = titleFont
        label.fontSize = titleFont.pointSize
        label.string = content
        label.alignmentMode = kCAAlignmentCenter
        label.foregroundColor = titleColor.cgColor
        
        adjustScale(label)
        
        return label
    }
    
    fileprivate func createCircleLayer(_ containerFrame: CGRect, option: CheckmarkOption) -> CAShapeLayer {
        let height = min(containerFrame.width, containerFrame.height)
        let xOffset = containerFrame.midX - height/2
        let frame = CGRect(x: xOffset, y: 0, width: height, height: height)
        let cornerRadius = ceil(frame.height/2)
        
        let borderLayer: CAShapeLayer = CAShapeLayer()
        borderLayer.frame = frame
        borderLayer.lineWidth = circleBorderLineWidth
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.backgroundColor = option.fillColor.cgColor
        borderLayer.cornerRadius = cornerRadius
        borderLayer.strokeColor = option.borderColor.cgColor
        borderLayer.strokeEnd = 0
        borderLayer.masksToBounds = true
        
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: cornerRadius).cgPath
        
        adjustScale(borderLayer)
        
        return borderLayer
    }
    
    fileprivate func createTick(_ containerFrame: CGRect, strokeColor: UIColor) -> CAShapeLayer {
        let tickPath = UIBezierPath()
        tickPath.move(to: CGPoint(x: 0, y: 0))
        tickPath.addLine(to: CGPoint(x: 0, y: tickLineWidth * 3))
        tickPath.addLine(to: CGPoint(x: tickLineWidth * 5, y: tickLineWidth * 3))
        tickPath.addLine(to: CGPoint(x: tickLineWidth * 5, y: tickLineWidth * 2))
        tickPath.addLine(to: CGPoint(x: tickLineWidth, y: tickLineWidth * 2))
        tickPath.addLine(to: CGPoint(x: tickLineWidth, y: 0))
        tickPath.close()
        tickPath.apply(CGAffineTransform(rotationAngle: CGFloat(-(Double.pi / 4))))
        
        let tickBorderLayer: CAShapeLayer = CAShapeLayer()
        tickBorderLayer.frame = CGRect(x: containerFrame.midX - (5*tickLineWidth)/2.0, y: containerFrame.midY, width: containerFrame.width, height: containerFrame.height)
        tickBorderLayer.lineWidth = 1
        tickBorderLayer.fillColor = strokeColor.cgColor
        tickBorderLayer.path = tickPath.cgPath
        
        adjustScale(tickBorderLayer)
        
        return tickBorderLayer
    }
    
    fileprivate func adjustScale(_ layer: CALayer) {
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.contentsScale = UIScreen.main.scale
    }
    
    // MARK: animations
    fileprivate func animateCircleBorder(_ layer: CAShapeLayer) {
        layer.strokeEnd = 1.0
        let animationKey = "strokeEnd"
        let animation: CABasicAnimation = CABasicAnimation(keyPath: animationKey)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = animationLength
        animation.fromValue = 0.0
        animation.toValue = 1.0

        layer.add(animation, forKey: animationKey)
    }
    
    // MARK: respond to touches
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch: UITouch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        
        if bounds.contains(location) {
            let sectionWidth = self.bounds.width / CGFloat(options.count)
            let index = Int(location.x / sectionWidth)
            
            if selectedIndex != index {
                selectedIndex = index
                
                sendActions(for: UIControlEvents.valueChanged)
            }
            
        }
    }
    
    fileprivate func sizeForLabel(_ text: String) -> CGSize {
        let textAttributes = [NSAttributedStringKey.font : titleFont]
        let string: NSString = text as NSString
        
        return string.size(withAttributes: textAttributes)
    }
}

public struct CheckmarkOption: CustomStringConvertible {
    public let title: String
    public let borderColor: UIColor
    public let fillColor: UIColor
    public var description: String {
        return "CheckmarkOption[title: \(title)]"
    }
    
    public init(title: String, borderColor: UIColor = UIColor.black, fillColor: UIColor = UIColor.lightGray) {
        self.title = title
        self.borderColor = borderColor
        self.fillColor = fillColor
    }
}
