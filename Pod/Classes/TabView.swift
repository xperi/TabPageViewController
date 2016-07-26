//
//  TabView.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

public class TabView: UIView {

    var pageItemPressedBlock: ((index: Int, direction: UIPageViewControllerNavigationDirection) -> Void)?
    public var isInfinity: Bool = false
    public weak var dataSource: TabViewDataSource? = nil {
        didSet {
            pageTabItemsCount = dataSource?.tabViewItemCount(self) ?? 0
            let tabViewItemCount =  dataSource?.tabViewItemCount(self) ?? 0
            beforeIndex = tabViewItemCount - 1
        }
    }

    
    private var option: TabPageOption = TabPageOption()
    private var beforeIndex: Int = 0
    private var currentIndex: Int = 0
    private var pageTabItemsCount: Int = 0
    private var shouldScrollToItem: Bool = false
    private var pageTabItemsWidth: CGFloat = 0.0
    private var collectionViewContentOffsetX: CGFloat = 0.0
    private var currentBarViewWidth: CGFloat = 0.0
    private var cachedCellSizes: [NSIndexPath: CGSize] = [:]

    @IBOutlet var contentView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!

    init(isInfinity: Bool, option: TabPageOption) {
       super.init(frame: CGRect.zero)
        self.option = option
        self.isInfinity = isInfinity
        NSBundle(forClass: TabView.self).loadNibNamed("TabView", owner: self, options: nil)
        addSubview(contentView)
        contentView.backgroundColor = option.tabBackgroundColor

        let top = NSLayoutConstraint(item: contentView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0.0)

        let left = NSLayoutConstraint(item: contentView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Leading,
            multiplier: 1.0,
            constant: 0.0)

        let bottom = NSLayoutConstraint (item: self,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0)

        let right = NSLayoutConstraint(item: self,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0.0)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([top, left, bottom, right])

        let bundle = NSBundle(forClass: TabView.self)
        collectionView.scrollsToTop = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.registerClass(TabCollectionCell.self, forCellWithReuseIdentifier: TabCollectionCell.cellIdentifier())
        
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// MARK: - View

extension TabView {

    /**
     Called when you swipe in isInfinityTabPageViewController, moves the contentOffset of collectionView

     - parameter index: Next Index
     - parameter contentOffsetX: contentOffset.x of scrollView of isInfinityTabPageViewController
     */
    func scrollCurrentBarView(index: Int, contentOffsetX: CGFloat) {
        var nextIndex = isInfinity ? index + pageTabItemsCount : index
        if isInfinity && index == 0 && (beforeIndex - pageTabItemsCount) == pageTabItemsCount - 2 {
            // Calculate the index at the time of transition to the first item from the last item of pageTabItems
            nextIndex = pageTabItemsCount * 2
        } else if isInfinity && (index == pageTabItemsCount - 1) && (beforeIndex - pageTabItemsCount) == -1 {
            // Calculate the index at the time of transition from the first item of pageTabItems to the last item
            nextIndex = pageTabItemsCount - 1
        }
        
        if collectionViewContentOffsetX == 0.0 {
            collectionViewContentOffsetX = collectionView.contentOffset.x
        }

        let currentIndexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
        let nextIndexPath = NSIndexPath(forItem: nextIndex, inSection: 0)
        if let currentCell = collectionView.cellForItemAtIndexPath(currentIndexPath) as? TabCollectionCell, nextCell = collectionView.cellForItemAtIndexPath(nextIndexPath) as? TabCollectionCell {

            let distance = (currentCell.frame.width / 2.0) + (nextCell.frame.width / 2.0)
            let scrollRate = contentOffsetX / frame.width
            let width = fabs(scrollRate) * (nextCell.frame.width - currentCell.frame.width)
            if isInfinity {
                let scroll = scrollRate * distance
                collectionView.contentOffset.x = collectionViewContentOffsetX + scroll
            }
        }
    }

    /**
     Center the current cell after page swipe
     */
    func scrollToHorizontalCenter() {

        let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
        if isScrollToItemAble(indexPath) {
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
            collectionViewContentOffsetX = collectionView.contentOffset.x
        }

    }

    /**
     Called in after the transition is complete pages in isInfinityTabPageViewController in the process of updating the current

     - parameter index: Next Index
     */
    func updateCurrentIndex(index: Int, shouldScroll: Bool) {
        deselectVisibleCells()

        currentIndex = isInfinity ? index + pageTabItemsCount : index

        let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
        moveCurrentBarView(indexPath, animated: !isInfinity, shouldScroll: shouldScroll)
    }

    /**
     Make the tapped cell the current if isInfinity is true

     - parameter index: Next IndexPath√
     */
    private func updateCurrentIndexForTap(index: Int) {
        deselectVisibleCells()

        if isInfinity && (index < pageTabItemsCount) || (index >= pageTabItemsCount * 2) {
            currentIndex = (index < pageTabItemsCount) ? index + pageTabItemsCount : index - pageTabItemsCount
            shouldScrollToItem = true
        } else {
            currentIndex = index
        }
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        moveCurrentBarView(indexPath, animated: true, shouldScroll: true)
    }

    /**
     Move the collectionView to IndexPath of Current

     - parameter indexPath: Next IndexPath
     - parameter animated: true when you tap to move the isInfinityTabCollectionCell
     - parameter shouldScroll:
     */
    private func moveCurrentBarView(indexPath: NSIndexPath, animated: Bool, shouldScroll: Bool) {

        if shouldScroll && isScrollToItemAble(indexPath) {
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
            layoutIfNeeded()
            collectionViewContentOffsetX = 0.0
            currentBarViewWidth = 0.0
            updateCollectionViewUserInteractionEnabled(true)
        }
        if let currentCell = self.collectionView.cellForItemAtIndexPath(indexPath) as? TabCollectionCell {
                currentCell.isCurrent = true
        }
        
        
    }
    
    private func updateCurrentPageItem() {
        var offset = collectionView.contentOffset
        offset.x = offset.x + collectionView.center.x
        if let indexPath = self.collectionView.indexPathForItemAtPoint(offset), cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? TabCollectionCell {
            moveCurrentBarView(indexPath, animated: true, shouldScroll: true)

            let fixedIndex = isInfinity ? indexPath.item % pageTabItemsCount : indexPath.item
            var direction: UIPageViewControllerNavigationDirection = .Forward
            

            if isInfinity && fixedIndex == 0 && (beforeIndex - pageTabItemsCount) == pageTabItemsCount - 1 {
                direction = .Forward
            } else if isInfinity && (fixedIndex == pageTabItemsCount - 1) && (beforeIndex - pageTabItemsCount) == 0 {
                direction = .Reverse
            } else {
                if beforeIndex > currentIndex {
                    direction = .Reverse
                }
            }
            self.pageItemPressedBlock?(index: fixedIndex, direction: direction)
        }
    }


    /**
     Touch event control of collectionView

     - parameter userInteractionEnabled: collectionViewに渡すuserInteractionEnabled
     */
    func updateCollectionViewUserInteractionEnabled(userInteractionEnabled: Bool) {
        collectionView.userInteractionEnabled = userInteractionEnabled
    }

    /**
     Update all of the cells in the display to the unselected state
     */
    private func deselectVisibleCells() {
        collectionView
            .visibleCells()
            .flatMap { $0 as? TabCollectionCell }
            .forEach { $0.isCurrent = false }
    }

    private func isScrollToItemAble(indexPath: NSIndexPath) -> Bool {

        return pageTabItemsCount > 0

    }
}


// MARK: - UICollectionViewDataSource

extension TabView: UICollectionViewDataSource {

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isInfinity ? pageTabItemsCount * 3 : pageTabItemsCount
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = TabCollectionCell()
        if var tabCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier(TabCollectionCell.cellIdentifier(), forIndexPath: indexPath) as? TabCollectionCell {
            cell = tabCollectionCell
        }
        configureCell(cell, indexPath: indexPath)
        return cell
    }

    private func configureCell(cell: TabCollectionCell, indexPath: NSIndexPath) {
        let fixedIndex = isInfinity ? indexPath.item % pageTabItemsCount : indexPath.item
        cell.titleItem = self.dataSource?.tabView(self, viewForIndexPath: fixedIndex)
        cell.option = option
        cell.isCurrent = fixedIndex == (currentIndex % pageTabItemsCount)
        cell.tabItemButtonPressedBlock = { [weak self, weak cell] in
            var direction: UIPageViewControllerNavigationDirection = .Forward
            if let pageTabItemsCount = self?.pageTabItemsCount, currentIndex = self?.currentIndex {
                if self?.isInfinity == true {
                    if (indexPath.item < pageTabItemsCount) || (indexPath.item < currentIndex) {
                        direction = .Reverse
                    }
                } else {
                    if indexPath.item < currentIndex {
                        direction = .Reverse
                    }
                }
            }
            self?.pageItemPressedBlock?(index: fixedIndex, direction: direction)

            if cell?.isCurrent == false {
                // Not accept touch events to scroll the animation is finished
                self?.updateCollectionViewUserInteractionEnabled(false)
            }
            self?.updateCurrentIndexForTap(indexPath.item)
        }
    }
}


// MARK: - UIScrollViewDelegate

extension TabView: UICollectionViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {

        guard isInfinity else {
            return
        }
        if pageTabItemsWidth == 0.0 {
            pageTabItemsWidth = floor(scrollView.contentSize.width / 3.0)
        }

        if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > pageTabItemsWidth * 2.0) {
            scrollView.contentOffset.x = pageTabItemsWidth
        }
        var offset = scrollView.contentOffset
        offset.x = offset.x + scrollView.frame.width / 2
        beforeIndex = currentIndex - 1
        if let nextIndexPath = self.collectionView.indexPathForItemAtPoint(offset) {
            let nextIndex = isInfinity ? nextIndexPath.item % pageTabItemsCount : nextIndexPath.item

            if let nextCell = collectionView.cellForItemAtIndexPath(nextIndexPath) as? TabCollectionCell {
                deselectVisibleCells()
                nextCell.isCurrent = true
            }
            let newCurrentIndex = isInfinity ? nextIndex + pageTabItemsCount : nextIndex
            if newCurrentIndex != currentIndex {
                beforeIndex = currentIndex
                currentIndex = newCurrentIndex
            }
        }
    }

    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // Accept the touch event because animation is complete
        updateCollectionViewUserInteractionEnabled(true)

        guard isInfinity else {
            return
        }

        let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
        if shouldScrollToItem && isScrollToItemAble(indexPath) {
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
            shouldScrollToItem = false
        }
    }
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard isInfinity else {
            return
        }
        if !decelerate {
            updateCurrentPageItem()
        }
    }
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard isInfinity else {
            return
        }
        updateCurrentPageItem()
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension TabView: UICollectionViewDelegateFlowLayout {

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        if let size = cachedCellSizes[indexPath] {
            return size
        }
        let cellForSize = TabCollectionCell()
        configureCell(cellForSize, indexPath: indexPath)

        let size = cellForSize.sizeThatFits(CGSizeMake(collectionView.bounds.width, option.tabHeight))
        cachedCellSizes[indexPath] = size

        return size
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
}
