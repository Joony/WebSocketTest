//
//  SpringFlowLayout.swift
//  WebsocketTest
//
//  Created by Jonathan McAllister on 08/08/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import UIKit

let kLength: CGFloat = 0.3
let kDamping: CGFloat = 0.8
let kFrequence: CGFloat = 1.3
let kResistence: CGFloat = 1000

class SpringFlowLayout: UICollectionViewFlowLayout {
    
    var dynamicAnimator: UIDynamicAnimator!
    var visibleIndexPathsSet: Set<NSIndexPath>!
    var latestDelta = CGFloat()
    
    override init() {
        super.init()
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    func setup() {
        self.dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
        self.visibleIndexPathsSet = []
    }
    
    // MARK - Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        // Need to overflow our actual visible rect slightly to avoid flickering.
        let visibleRect = CGRectInset(self.collectionView!.bounds, -100, -100)
        let itemsInVisibleRectArray = super.layoutAttributesForElementsInRect(visibleRect)!
        let itemsIndexPathsInVisibleRectSet = Set(itemsInVisibleRectArray.flatMap({ $0.indexPath }))
        
        // Step 1: Remove any behaviours that are no longer visible.
        let noLongerVisibleBehaviours = self.dynamicAnimator.behaviors.filter { behaviour -> Bool in
            let currentlyVisible = itemsIndexPathsInVisibleRectSet.contains(((behaviour as! UIAttachmentBehavior).items.first! as!  UICollectionViewLayoutAttributes).indexPath)
            return !currentlyVisible
        }
        
        noLongerVisibleBehaviours.forEach { behaviour in
            self.dynamicAnimator.removeBehavior(behaviour)
            self.visibleIndexPathsSet.remove(((behaviour as! UIAttachmentBehavior).items.first! as! UICollectionViewLayoutAttributes).indexPath)
        }
        
        // Step 2: Add any newly visible behaviours.
        // A "newly visible" item is one that is in the itemsInVisibleRect(Set|Array) but not in the visibleIndexPathsSet
        let newlyVisibleItems = itemsInVisibleRectArray.filter { item -> Bool in
            let currentlyVisible = self.visibleIndexPathsSet.contains(item.indexPath)
            return !currentlyVisible
        }
        
        let touchLocation = self.collectionView!.panGestureRecognizer.locationInView(self.collectionView)
        
        newlyVisibleItems.forEach { layoutAttributes in
//            layoutAttributes.frame.size = CGSizeMake(self.collectionView!.bounds.size.width - 20, 140)
            
            let item = layoutAttributes as UIDynamicItem
            let springBehaviour = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
            springBehaviour.length = kLength
            springBehaviour.damping = kDamping
            springBehaviour.frequency = kFrequence
            
            // If our touchLocation is not (0,0), we'll need to adjust our item's center "in flight"
            if !CGPointEqualToPoint(CGPointZero, touchLocation) {
                let yDistanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y)
                let scrollResistance = yDistanceFromTouch / kResistence
                
                let item = springBehaviour.items.first as! UICollectionViewLayoutAttributes
                var center = item.center
                
                if self.latestDelta < 0 {
                    center.y += max(self.latestDelta, self.latestDelta * scrollResistance)
                } else {
                    center.y += min(self.latestDelta, self.latestDelta * scrollResistance)
                }
                
                item.center = center
             }
            
            
            
            self.dynamicAnimator.addBehavior(springBehaviour)
            self.visibleIndexPathsSet.insert(layoutAttributes.indexPath)
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.dynamicAnimator.itemsInRect(rect) as? [UICollectionViewLayoutAttributes]
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.dynamicAnimator.layoutAttributesForCellAtIndexPath(indexPath)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        let scrollView = self.collectionView!
        let delta = newBounds.origin.y - scrollView.bounds.origin.y
        
        self.latestDelta = delta
        
        let touchLocation = self.collectionView!.panGestureRecognizer.locationInView(self.collectionView)
        
        self.dynamicAnimator.behaviors.forEach { behaviour in
            let springBehaviour = behaviour as! UIAttachmentBehavior
            let yDistanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y)
            let scrollResistance = yDistanceFromTouch / kResistence
            
            let item = springBehaviour.items.first as! UICollectionViewLayoutAttributes
            var center = item.center
            
            if self.latestDelta < 0 {
                center.y += max(self.latestDelta, self.latestDelta * scrollResistance)
            } else {
                center.y += min(self.latestDelta, self.latestDelta * scrollResistance)
            }
            
            item.center = center
            
            self.dynamicAnimator.updateItemUsingCurrentState(item)
        }
        
        return false
    }
}
