//
//  CheckmarkSegmentedControl.swift
//  CheckmarkSegmentedControl
//
//  Created by Grzegorz Tatarzyn on 27/04/2015.
//  Copyright (c) 2015 gregttn. All rights reserved.
//

import UIKit

class CheckmarkSegmentedControl: UIControl {
    var titles: [String] = []
    var titleFont: UIFont = UIFont.systemFontOfSize(12.0)
    var titleColor: UIColor = UIColor.blackColor()
    var titleLabelTopMargin: CGFloat = 12.0
    var strokeColor: UIColor = UIColor.blackColor()
    var selectedIndex: Int = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func drawRect(rect: CGRect) {
        let sectionSize: CGSize = CGSizeMake(rect.width / CGFloat(titles.count), rect.height)
        
        for index in (0..<titles.count) {
            let containerFrame = CGRectMake(sectionSize.width * CGFloat(index), 0, sectionSize.width, sectionSize.height)
            
            let label = createTitleLabel(containerFrame, content: titles[index])
            layer.addSublayer(label)
            
            let circleLayer = createCircleLayer(containerFrame, titleLabelFrame: label.frame)
            layer.addSublayer(circleLayer)
            
            if index == selectedIndex {
                let borderLayer = createCircleBorder(circleLayer.frame, bounds: circleLayer.bounds)
                layer.addSublayer(borderLayer)
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
        
        return label
    }
    
    private func createCircleLayer(containerFrame: CGRect, titleLabelFrame: CGRect) -> CALayer {
        let frame = CGRectInset(containerFrame, titleLabelTopMargin/2.0, (titleLabelFrame.height + titleLabelTopMargin)/2)
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
        borderLayer.lineWidth = 3
        borderLayer.fillColor = UIColor.clearColor().CGColor
        borderLayer.strokeColor = strokeColor.CGColor
        borderLayer.strokeEnd = 1.0
        borderLayer.path = UIBezierPath(ovalInRect:bounds).CGPath
        
        return borderLayer
    }
    
    private func sizeForLabel(text: String) -> CGSize {
        let textAttributes = [NSFontAttributeName : titleFont]
        let string: NSString = text
        
        return string.sizeWithAttributes(textAttributes)
    }
}