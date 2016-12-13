//
//  PDHorizontalFlowLayout.swift
//
//  Created by iParth on 12/13/16.
//  Copyright © 2016 iParth. All rights reserved.
//

import UIKit

class PDHorizontalFlowLayout: UICollectionViewFlowLayout {

//        self = super.init()
//        if(self){
//            self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//            self.nbColumns = -1;
//            self.nbLines = -1;
//        }
//        return self;
    
    /*
    var nbColumns:NSInteger = -1
    var nbLines:NSInteger = -1
    
    override func prepareLayout() {
        super.prepareLayout()
        self.scrollDirection = .Horizontal;
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let nbColumns = self.nbColumns != -1 ? self.nbColumns : Int(self.collectionView!.frame.size.width / self.itemSize.width)
        let nbLines = self.nbLines != -1 ? self.nbLines : Int(self.collectionView!.frame.size.height / self.itemSize.height)
        let idxPage = Int(indexPath.row) / (nbColumns * nbLines)
        let O = indexPath.row - (idxPage * nbColumns * nbLines)
        let xD = Int(O / nbColumns)
        let yD = O % nbColumns
        let D = xD + yD * nbLines + idxPage * nbColumns * nbLines
        let fakeIndexPath = NSIndexPath(forItem: D, inSection: indexPath.section)
        let attributes = super.layoutAttributesForItemAtIndexPath(fakeIndexPath)!
        
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?  {
        
        let newX: CGFloat = min(0, rect.origin.x - rect.size.width / 2)
        let newWidth: CGFloat = rect.size.width * 2 + (rect.origin.x - newX)
        let newRect = CGRectMake(newX, rect.origin.y, newWidth, rect.size.height)
        // Get all the attributes for the elements in the specified frame
        let allAttributesInRect = super.layoutAttributesForElementsInRect(newRect)! /* copyItems: true */
        for attr: UICollectionViewLayoutAttributes in allAttributesInRect {
            let newAttr = self.layoutAttributesForItemAtIndexPath(attr.indexPath)!
            attr.frame = newAttr.frame
            attr.center = newAttr.center
            attr.bounds = newAttr.bounds
            attr.hidden = newAttr.hidden
            attr.size = newAttr.size
        }
        return allAttributesInRect
    }
    
    override func collectionViewContentSize() -> CGSize {
        let size = super.collectionViewContentSize()
        let collectionViewWidth: CGFloat = self.collectionView!.frame.size.width
        let nbOfScreens = Int(ceil((size.width / collectionViewWidth)))
        let newSize = CGSizeMake((collectionViewWidth * CGFloat(nbOfScreens)), size.height)
        return newSize

    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    */
    
//    override var itemSize = CGSizeZero {
//        get {
//            return self()
//        }
//        set {
//            self() = !newValue
//        }
//        didSet {
//            invalidateLayout()
//        }
//    }
    private var cellCount = 0
    private var boundsSize = CGSizeZero
    
    override func prepareLayout() {
        cellCount = self.collectionView!.numberOfItemsInSection(0)
        boundsSize = self.collectionView!.bounds.size
    }
    
    override func collectionViewContentSize() -> CGSize {
        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        
        let itemsPerPage = verticalItemsCount * horizontalItemsCount
        let numberOfItems = cellCount
        let numberOfPages = Int(ceil(Double(numberOfItems) / Double(itemsPerPage)))
        
        var size = boundsSize
        size.width = CGFloat(numberOfPages) * boundsSize.width
        return size
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for var i = 0; i < cellCount; i++ {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let attr = self.computeLayoutAttributesForCellAtIndexPath(indexPath)
            allAttributes.append(attr)
        }
        return allAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.computeLayoutAttributesForCellAtIndexPath(indexPath)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    func computeLayoutAttributesForCellAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        let row = indexPath.row
        let bounds = self.collectionView!.bounds
        
        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        let itemsPerPage = verticalItemsCount * horizontalItemsCount
        
        let columnPosition = row % horizontalItemsCount
        let rowPosition = (row/horizontalItemsCount)%verticalItemsCount
        let itemPage = Int(floor(Double(row)/Double(itemsPerPage)))
        
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        var frame = CGRectZero
        frame.origin.x = CGFloat(itemPage) * bounds.size.width + CGFloat(columnPosition) * itemSize.width
        frame.origin.y = CGFloat(rowPosition) * itemSize.height
        frame.size = itemSize
        attr.frame = frame
        
        return attr
    }
}
