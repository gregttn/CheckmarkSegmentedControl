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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func drawRect(rect: CGRect) {
        let sectionSize: CGSize = CGSizeMake(rect.width / CGFloat(titles.count), rect.height)
    
        for index in (0..<titles.count) {
            let sectionOffset = CGPoint(x: sectionSize.width * CGFloat(index), y: 0)

            let label = createTitleLabel(sectionSize, containerOffset: sectionOffset, content: titles[index])
            layer.addSublayer(label)
        }
    }
    
    private func createTitleLabel(containerSize: CGSize, containerOffset: CGPoint, content: String) -> CATextLayer {
        let labelSize = sizeForLabel(content)
        let labelFrame = CGRectMake(containerOffset.x, containerSize.height - labelSize.height, containerSize.width, labelSize.height)
        
        let label: CATextLayer = CATextLayer()
        label.frame = labelFrame
        label.font = titleFont
        label.fontSize = titleFont.pointSize
        label.string = content
        label.alignmentMode = kCAAlignmentCenter
        label.foregroundColor = titleColor.CGColor
        
        return label
    }
    
    private func sizeForLabel(text: String) -> CGSize {
        let textAttributes = [NSFontAttributeName : titleFont]
        let string: NSString = text
        
        return string.sizeWithAttributes(textAttributes)
    }
}
