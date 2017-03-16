//
//  TabView.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

open class TabView: UIView {

    var pageItemPressedBlock: ((_ index: Int, _ direction: UIPageViewControllerNavigationDirection, _ isCurrentPage: Bool) -> Void)?
    open var isInfinity: Bool = false
    var shouldScrollCurrentBar = true

    open weak var dataSource: TabViewDataSource? = nil {
        didSet {
            pageTabItemsCount = dataSource?.tabViewItemCount(self) ?? 0
            let tabViewItemCount =  dataSource?.tabViewItemCount(self) ?? 0
            beforeIndex = tabViewItemCount - 1
        }
    }


    fileprivate var option: TabPageOption = TabPageOption()
    fileprivate var beforeIndex: Int = 0
    fileprivate var currentIndex: Int = 0
    fileprivate var pageTabItemsCount: Int = 0
    fileprivate var shouldScrollToItem: Bool = false
    fileprivate var isMoveCurrentBarView: Bool = false
    fileprivate var pageTabItemsWidth: CGFloat = 0.0
    fileprivate var collectionViewContentOffsetX: CGFloat = 0.0
    fileprivate var currentBarViewWidth: CGFloat = 0.0

    @IBOutlet var contentView: UIView!
    @IBOutlet open weak var collectionView: UICollectionView!
    var currentBarView: UIView!

    init(isInfinity: Bool, option: TabPageOption) {
       super.init(frame: CGRect.zero)
        self.option = option
        self.isInfinity = isInfinity
        Bundle(for: TabView.self).loadNibNamed("TabView", owner: self, options: nil)
        addSubview(contentView)
        contentView.backgroundColor = option.tabBackgroundColor

        let top = NSLayoutConstraint(item: contentView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0.0)

        let left = NSLayoutConstraint(item: contentView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0.0)

        let bottom = NSLayoutConstraint (item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0.0)

        let right = NSLayoutConstraint(item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0.0)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([top, left, bottom, right])

        let bundle = Bundle(for: TabView.self)
        collectionView.scrollsToTop = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.register(TabCollectionCell.self, forCellWithReuseIdentifier: TabCollectionCell.cellIdentifier())

        currentBarView = UIView()
        currentBarView.frame.size.height = option.currentBarHeight
        currentBarView.frame.size.width = option.tabWidth ?? 0
        currentBarView.backgroundColor =  option.currentBarColor
        currentBarView.isHidden = true
        collectionView.addSubview(currentBarView)

    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open func reloadData() {
        collectionView.reloadData()
        scrollToHorizontalCenter()
    }
    override open func layoutSubviews() {
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
    func scrollCurrentBarView(_ index: Int, contentOffsetX: CGFloat) {
        let fixedIndex = isInfinity ? index + pageTabItemsCount : index
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
        let currentIndexPath = IndexPath(item: (isJumpCicle && beforeIndex != fixedIndex ? beforeIndex : currentIndex), section: 0)
        let nextIndexPath = IndexPath(item: nextIndex, section: 0)
        if let currentCell = collectionView.cellForItem(at: currentIndexPath) as? TabCollectionCell, let nextCell = collectionView.cellForItem(at: nextIndexPath) as? TabCollectionCell {
            let distance = (currentCell.frame.width / 2.0) + (nextCell.frame.width / 2.0)
            var scrollRate = contentOffsetX / frame.width
            scrollRate = scrollRate > 1 ? 1 : scrollRate
            scrollRate = scrollRate < -1 ? -1 : scrollRate

            let width = fabs(scrollRate) * (nextCell.frame.width - currentCell.frame.width)
            if !self.isInfinity && self.option.currentBarAnimation {
                nextCell.hideCurrentBarView()
                currentCell.hideCurrentBarView()
                currentBarView.isHidden = false

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

        let indexPath = IndexPath(item: currentIndex, section: 0)
        if isScrollToItemAble(indexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            collectionViewContentOffsetX = collectionView.contentOffset.x
        }

    }

    /**
     Called in after the transition is complete pages in isInfinityTabPageViewController in the process of updating the current

     - parameter index: Next Index
     */
    func updateCurrentIndex(_ index: Int, animated: Bool? = nil, shouldScroll: Bool) {

        currentIndex = isInfinity ? index + pageTabItemsCount : index

        let indexPath = IndexPath(item: currentIndex, section: 0)
        self.deselectVisibleCells(unHighlightTitle: true)
        moveCurrentBarView(indexPath, animated: animated ?? !isInfinity, shouldScroll: shouldScroll)
    }

    /**
     Make the tapped cell the current if isInfinity is true

     - parameter index: Next IndexPath√
     */
    fileprivate func updateCurrentIndexForTap(_ index: Int) {
        if !isInfinity {
            //deselectVisibleCells(true, unHighlightTitle: true)
        }
        shouldScrollToItem = true
        if isInfinity && (index < pageTabItemsCount) || (index >= pageTabItemsCount * 2) {
            currentIndex = (index < pageTabItemsCount) ? index + pageTabItemsCount : index - pageTabItemsCount

        } else {
            currentIndex = index
        }
        let indexPath = IndexPath(item: index, section: 0)
        moveCurrentBarView(indexPath, animated: true, shouldScroll: true)
    }

    /**
     Move the collectionView to IndexPath of Current

     - parameter indexPath: Next IndexPath
     - parameter animated: true when you tap to move the isInfinityTabCollectionCell
     - parameter shouldScroll: shouldScroll은 자동으로 tabview 가운데로 스크롤할지 정하는 플래그
     */

    fileprivate func moveCurrentBarView(_ indexPath: IndexPath, animated: Bool, shouldScroll: Bool) {

        if shouldScroll && isScrollToItemAble(indexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            layoutIfNeeded()
            collectionViewContentOffsetX = 0.0
            currentBarViewWidth = 0.0
            updateCollectionViewUserInteractionEnabled(true)
        }
        if !self.isInfinity {
            // 무한이 아니면 모든 보이는 셀들의 하단바를 숨김
            self.deselectVisibleCells(hideCurrentBar: true)
        }
        if let currentCell = self.collectionView.cellForItem(at: indexPath) as? TabCollectionCell {

            let completion: ((Bool) -> Void) = { [weak self] _ in
                self?.deselectVisibleCells(hideCurrentBar: true, unHighlightTitle: true)

                currentCell.isCurrent = true
                currentCell.showCurrentBarView()
                currentCell.highlightTitle()
                self?.currentBarView.isHidden = true
                self?.isMoveCurrentBarView = false
            }
            if animated && self.option.currentBarAnimation && !isInfinity && !shouldScrollCurrentBar {
                self.isMoveCurrentBarView = true
                if self.currentBarView.frame.size.width == 0 {
                    let prevIndexPath = IndexPath(item: beforeIndex, section: 0)
                    if let prevCell = collectionView.cellForItem(at: prevIndexPath) as? TabCollectionCell {
                         self.currentBarView.frame.size.width = prevCell.frame.size.width
                    }
                }

                UIView.animate(withDuration: self.option.currentBarAnimationDuration, animations: {

                    self.currentBarView.isHidden = false
                    self.currentBarView.frame.origin.x = currentCell.frame.origin.x
                    self.currentBarView.frame.size.width = currentCell.frame.size.width

                    }, completion: completion)
            } else {
                completion(true)
            }

        }


    }

    fileprivate func updateCurrentPageItem() {
        var offset = collectionView.contentOffset
        offset.x = offset.x + collectionView.center.x
        if let indexPath = self.collectionView.indexPathForItem(at: offset), let cell = self.collectionView.cellForItem(at: indexPath) as? TabCollectionCell {
            moveCurrentBarView(indexPath, animated: true, shouldScroll: true)

            let fixedIndex = isInfinity ? indexPath.item % pageTabItemsCount : indexPath.item
            var direction: UIPageViewControllerNavigationDirection = .forward

            if isInfinity && fixedIndex == 0 && (beforeIndex - pageTabItemsCount) == pageTabItemsCount - 1 {
                direction = .forward
            } else if isInfinity && (fixedIndex == pageTabItemsCount - 1) && (beforeIndex - pageTabItemsCount) == 0 {
                direction = .reverse
            } else {
                if beforeIndex > currentIndex {
                    direction = .reverse
                }
            }
            self.pageItemPressedBlock?(fixedIndex, direction, false)
        }
    }


    /**
     Touch event control of collectionView

     - parameter userInteractionEnabled: collectionViewに渡すuserInteractionEnabled
     */
    func updateCollectionViewUserInteractionEnabled(_ userInteractionEnabled: Bool) {
        collectionView.isUserInteractionEnabled = userInteractionEnabled
    }

    /**
     Update all of the cells in the display to the unselected state
     */
    fileprivate func deselectVisibleCells(hideCurrentBar: Bool = true, unHighlightTitle: Bool = false,
                                                     exceptionCell: TabCollectionCell? = nil) {
        collectionView
            .visibleCells
            .flatMap { $0 as? TabCollectionCell }
            .filter ({ (cell: TabCollectionCell) -> (Bool) in
                if let exceptionCell = exceptionCell, cell == exceptionCell {

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

    fileprivate func isScrollToItemAble(_ indexPath: IndexPath) -> Bool {

        return pageTabItemsCount > 0 && pageTabItemsCount > indexPath.item

    }
}


// MARK: - UICollectionViewDataSource

extension TabView: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isInfinity ? pageTabItemsCount * 3 : pageTabItemsCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = TabCollectionCell()
        if let tabCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCollectionCell.cellIdentifier(), for: indexPath) as? TabCollectionCell {
            cell = tabCollectionCell
        }
        configureCell(cell, indexPath: indexPath)
        return cell
    }

    fileprivate func configureCell(_ cell: TabCollectionCell, indexPath: IndexPath) {
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
            guard let shouldScrollCurrentBar = self?.shouldScrollCurrentBar, shouldScrollCurrentBar,
                let isMoveCurrentBarView = self?.isMoveCurrentBarView, !isMoveCurrentBarView, let cell = cell else {
                
                return
            }
            
            if cell.isCurrent {
                self?.pageItemPressedBlock?(fixedIndex, .forward, true)
                return
            }

            var direction: UIPageViewControllerNavigationDirection = .forward
            if let pageTabItemsCount = self?.pageTabItemsCount, let currentIndex = self?.currentIndex {
                if self?.isInfinity == true {
                    if (indexPath.item < pageTabItemsCount) || (indexPath.item < currentIndex) {
                        direction = .reverse
                    }
                } else {
                    if indexPath.item < currentIndex {
                        direction = .reverse
                    }
                }
            }
            self?.pageItemPressedBlock?(fixedIndex, direction, false)

            // Not accept touch events to scroll the animation is finished
            self?.updateCollectionViewUserInteractionEnabled(false)

            self?.updateCurrentIndexForTap(indexPath.item)
        }
        cell.setNeedsLayout()
    }
}


// MARK: - UIScrollViewDelegate

extension TabView: UICollectionViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

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
        if let nextIndexPath = self.collectionView.indexPathForItem(at: offset) {
            let nextIndex = isInfinity ? nextIndexPath.item % pageTabItemsCount : nextIndexPath.item

            if let nextCell = collectionView.cellForItem(at: nextIndexPath) as? TabCollectionCell {
                moveCurrentBarView(nextIndexPath, animated: false, shouldScroll: false)
            }
            let newCurrentIndex = isInfinity ? nextIndex + pageTabItemsCount : nextIndex
            if newCurrentIndex != currentIndex {
                beforeIndex = currentIndex
                currentIndex = newCurrentIndex
            }
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Accept the touch event because animation is complete
        updateCollectionViewUserInteractionEnabled(true)

        guard isInfinity else {
            return
        }

        let indexPath = IndexPath(item: currentIndex, section: 0)
        if shouldScrollToItem && isScrollToItemAble(indexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            shouldScrollToItem = false
        }
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard isInfinity else {
            return
        }
        if !decelerate {
            updateCurrentPageItem()
        }
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard isInfinity else {
            return
        }
        updateCurrentPageItem()
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension TabView: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var cell = TabCollectionCell()
        configureCell(cell, indexPath: indexPath)
        let tabWidth: CGFloat? = option.tabWidth
        if let tabWidth = tabWidth {
            return CGSize(width: tabWidth, height: option.tabHeight)

        }
        return cell.sizeThatFits(CGSize(width: collectionView.bounds.width, height: option.tabHeight))
    }


    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
