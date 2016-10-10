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
    var shouldScrollCurrentBar = false
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
    private var isMoveCurrentBarView: Bool = false
    private var pageTabItemsWidth: CGFloat = 0.0
    private var collectionViewContentOffsetX: CGFloat = 0.0
    private var currentBarViewWidth: CGFloat = 0.0

    @IBOutlet var contentView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    var currentBarView: UIView!

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

        currentBarView = UIView()
        currentBarView.frame.size.height = option.currentBarHeight
        currentBarView.frame.size.width = option.tabWidth ?? 0
        currentBarView.backgroundColor =  option.currentBarColor
        currentBarView.hidden = true
        collectionView.addSubview(currentBarView)

    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func reloadData() {
        collectionView.reloadData()
        scrollToHorizontalCenter()
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        currentBarView.frame.origin.y = collectionView.frame.height - option.currentBarHeight
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
        var fixedIndex = isInfinity ? index + pageTabItemsCount : index
        var nextIndex = fixedIndex
        var isJumpCicle = false
        if isInfinity && index == 0 && contentOffsetX > 0 {
            // Calculate the index at the time of transition to the first item from the last item of pageTabItems
            nextIndex = pageTabItemsCount * 2
            isJumpCicle = true
        } else if isInfinity && ((index == pageTabItemsCount - 1) || index == 0) && contentOffsetX < 0 {
            // Calculate the index at the time of transition from the first item of pageTabItems to the last item
            nextIndex = pageTabItemsCount - 1
            isJumpCicle = true
        }
        if collectionViewContentOffsetX == 0.0 {
            collectionViewContentOffsetX = collectionView.contentOffset.x
        }
        let currentIndexPath = NSIndexPath(forItem: (isJumpCicle && beforeIndex != fixedIndex ? beforeIndex : currentIndex), inSection: 0)
        let nextIndexPath = NSIndexPath(forItem: nextIndex, inSection: 0)
        if let currentCell = collectionView.cellForItemAtIndexPath(currentIndexPath) as? TabCollectionCell, nextCell = collectionView.cellForItemAtIndexPath(nextIndexPath) as? TabCollectionCell {
            let distance = (currentCell.frame.width / 2.0) + (nextCell.frame.width / 2.0)
            var scrollRate = contentOffsetX / frame.width
            scrollRate = scrollRate > 1 ? 1 : scrollRate
            scrollRate = scrollRate < -1 ? -1 : scrollRate
            
            let width = fabs(scrollRate) * (nextCell.frame.width - currentCell.frame.width)
            if !self.isInfinity && self.option.currentBarAnimation {
                nextCell.hideCurrentBarView()
                currentCell.hideCurrentBarView()
                currentBarView.hidden = false

                if currentBarViewWidth == 0.0 {
                    currentBarViewWidth = currentCell.frame.width
                }
                
                if fabs(scrollRate) > 0.6 {
                    nextCell.highlightTitle()
                    currentCell.unHighlightTitle()
                } else {
                    nextCell.unHighlightTitle()
                    currentCell.highlightTitle()
                }
            }

            if isInfinity {
                let scroll = scrollRate * distance
                collectionView.contentOffset.x = collectionViewContentOffsetX + scroll
            } else {
                if scrollRate > 0 {
                    currentBarView.frame.origin.x = currentCell.frame.minX + scrollRate * currentCell.frame.width
                } else {
                    currentBarView.frame.origin.x = currentCell.frame.minX + nextCell.frame.width * scrollRate
                }

            }
            currentBarView.frame.size.width = currentBarViewWidth + width


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
    func updateCurrentIndex(index: Int, animated: Bool? = nil, shouldScroll: Bool) {
        if !isInfinity {
            //deselectVisibleCells()
        }
        currentIndex = isInfinity ? index + pageTabItemsCount : index

        let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
        moveCurrentBarView(indexPath, animated: animated ?? !isInfinity, shouldScroll: shouldScroll)
    }

    /**
     Make the tapped cell the current if isInfinity is true

     - parameter index: Next IndexPath√
     */
    private func updateCurrentIndexForTap(index: Int) {
        if !isInfinity {
            //deselectVisibleCells(true, unHighlightTitle: true)
        }
        shouldScrollToItem = true
        if isInfinity && (index < pageTabItemsCount) || (index >= pageTabItemsCount * 2) {
            currentIndex = (index < pageTabItemsCount) ? index + pageTabItemsCount : index - pageTabItemsCount

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
        if !self.isInfinity {
            self.deselectVisibleCells(hideCurrentBar: true)
        }
        if let currentCell = self.collectionView.cellForItemAtIndexPath(indexPath) as? TabCollectionCell {

            let completion: (Bool -> Void) = { [weak self] _ in
                self?.deselectVisibleCells(hideCurrentBar: true, unHighlightTitle: true)

                currentCell.isCurrent = true
                currentCell.showCurrentBarView()
                currentCell.highlightTitle()
                self?.currentBarView.hidden = true
                self?.isMoveCurrentBarView = false
            }
            if animated && self.option.currentBarAnimation && !isInfinity && !shouldScrollCurrentBar {
                self.isMoveCurrentBarView = true
                UIView.animateWithDuration(self.option.currentBarAnimationDuration, animations: {
                    
                    self.currentBarView.hidden = false
                    self.currentBarView.frame.origin.x = currentCell.frame.origin.x
                    self.currentBarView.frame.size.width = currentCell.frame.size.width

                    }, completion: completion)
            } else {
                completion(true)
            }

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
    private func deselectVisibleCells(hideCurrentBar hideCurrentBar: Bool = true, unHighlightTitle: Bool = false,
                                                     exceptionCell: TabCollectionCell? = nil) {
        collectionView
            .visibleCells()
            .flatMap { $0 as? TabCollectionCell }
            .filter ({ (cell: TabCollectionCell) -> (Bool) in
                if let exceptionCell = exceptionCell where cell == exceptionCell {
                    
                    return false
                }
                return true
            })
            .forEach {
                $0.isCurrent = false
                if hideCurrentBar {
                    $0.hideCurrentBarView()
                }
                if unHighlightTitle {
                    $0.unHighlightTitle()
                }
            }
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
        cell.option = option
        cell.titleItem = self.dataSource?.tabView(self, viewForIndexPath: fixedIndex)
        cell.isCurrent = fixedIndex == (currentIndex % pageTabItemsCount)
        if cell.isCurrent {
            cell.highlightTitle()
            cell.showCurrentBarView()
        } else {
            cell.unHighlightTitle()
            cell.hideCurrentBarView()
        }
        cell.tabItemButtonPressedBlock = { [weak self, weak cell] in

            guard let shouldScrollCurrentBar = self?.shouldScrollCurrentBar where shouldScrollCurrentBar,
                let isMoveCurrentBarView = self?.isMoveCurrentBarView where !isMoveCurrentBarView,
                let cell = cell where !cell.isCurrent  else {
                return
            }

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

            // Not accept touch events to scroll the animation is finished
            self?.updateCollectionViewUserInteractionEnabled(false)
            
            self?.updateCurrentIndexForTap(indexPath.item)
        }
        cell.setNeedsLayout()
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
        if let nextIndexPath = self.collectionView.indexPathForItemAtPoint(offset) {
            let nextIndex = isInfinity ? nextIndexPath.item % pageTabItemsCount : nextIndexPath.item

            if let nextCell = collectionView.cellForItemAtIndexPath(nextIndexPath) as? TabCollectionCell {
                moveCurrentBarView(nextIndexPath, animated: false, shouldScroll: false)
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
        
        var cell = TabCollectionCell()
        configureCell(cell, indexPath: indexPath)
        let tabWidth: CGFloat? = option.tabWidth
        if let tabWidth = tabWidth {
            return CGSizeMake(tabWidth, option.tabHeight)

        }
        return cell.sizeThatFits(CGSizeMake(collectionView.bounds.width, option.tabHeight))
    }


    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
}
