//
//  CollectionViewCell.swift
//  WebsocketTest
//
//  Created by Jonathan McAllister on 05/08/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import UIKit

class SpeechCell: UICollectionViewCell {
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.frame = self.bounds
        
    }
//    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        let attributes = super.preferredLayoutAttributesFittingAttributes(layoutAttributes).copy() as! UICollectionViewLayoutAttributes
//        let newSize = self.systemLayoutSizeFittingSize(CGSize(width: 320, height: layoutAttributes.size.height), withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
//        var newFrame = attributes.frame
//        newFrame.size.height = newSize.height
//        attributes.frame = newFrame
//        return attributes
//    }
    
}
