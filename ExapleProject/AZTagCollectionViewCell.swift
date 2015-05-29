//
//  AZTagCollectionViewCell.swift
//  TagsView
//
//  Created by Alex Zimin on 02/05/15.
//  Copyright (c) 2015 Alex. All rights reserved.
//

import UIKit

class AZTagCollectionViewCell: UICollectionViewCell {
    
    var label: UILabel!
    static var space: CGPoint = CGPoint(x: 0, y: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        label = UILabel()
        
        label.frame = labelSize
        label.textColor = UIColor.darkGrayColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(14)
        
        contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        label.frame = labelSize
    }
    
    private var labelSize: CGRect {
        let space = AZTagCollectionViewCell.space
        return CGRectInset(self.bounds, space.x, space.y)
    }
}
