//
//  TabPageViewController.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

public protocol TabViewDataSource: NSObjectProtocol {
    func tabViewItemCount(tabView: TabView) -> Int
    func tabView(tabView: TabView, viewForIndexPath index: Int) -> TabTitleViewProtocol
}

public protocol TabTitleViewProtocol: NSObjectProtocol {
    func highlightTitle(option: TabPageOption?)
    func unHighlightTitle(option: TabPageOption?)
}
public protocol TabPageViewControllerDelegate: NSObjectProtocol {
    func tabPageViewController(tabPageViewController: TabPageViewController, didPressedViewController: UIViewController, isCurrentPage: Bool)
    func tabPageViewController(tabPageViewController: TabPageViewController, willSelectViewController: UIViewController)
    func tabPageViewController(tabPageViewController: TabPageViewController, didSelectViewController: UIViewController)
    func tabPageViewController(tabPageViewController: TabPageViewController, didMoveViewController: UIViewController)
}

public class TabPageViewController: UIPageViewController {
    public var tabPageViewControllerDelegate: TabPageViewControllerDelegate?
    public var isInfinity: Bool = false
    public var option: TabPageOption = TabPageOption()
    public var tabItems: [UIViewController] = [] {
        didSet {
            tabItemsCount = tabItems.count
        }
    }
    public var tabViewDataSource: TabViewDataSource?
    public var tabPageScrollEnable = true {
        didSet {
            let scrollView = view.subviews.flatMap { $0 as? UIScrollView }.first
            scrollView?.scrollEnabled = tabPageScrollEnable
        }
    }

    public var currentIndex: Int? {
        guard let viewController = viewControllers?.first else {
            return nil
        }
        return tabItems.indexOf(viewController)
    }

    public var tabViewContentInset: UIEdgeInsets? {
        didSet {
            guard let tabViewContentInset = tabViewContentInset else {
                return
            }
            tabView.collectionView.contentInset = tabViewContentInset
        }
    }

    public var tabViewContentOffset: CGPoint? {
        didSet {
            guard let tabViewContentOffset = tabViewContentOffset else {
                return
            }
            tabView.collectionView.contentOffset = tabViewContentOffset
        }
    }
    
    public var tabViewContentSize: CGSize? {
        return tabView.collectionView.contentSize
    }

    private var beforeIndex: Int = 0
    private var tabItemsCount: Int = 0
    // 제스처로 뷰컨트롤러 움직일때 사용하는 플래그
    private var isMovingViewController = false
    private var defaultContentOffsetX: CGFloat {
        return self.view.bounds.width
    }

    private var shouldScrollCurrentBar: Bool = true {
        didSet {
            tabView.shouldScrollCurrentBar = shouldScrollCurrentBar
        }
    }
    
    lazy private var tabView: TabView = self.configuredTabView()

    public override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: options)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupScrollView()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if tabView.superview == nil {
            tabView = configuredTabView()
        }

        if let currentIndex = currentIndex where isInfinity {
            tabView.updateCurrentIndex(currentIndex, shouldScroll: true)
        }
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // 정상적으로 뷰컨트롤러가 이동되지 않고 화면이 사라질때 복구
        if self.isMovingViewController {
            if beforeIndex < tabItemsCount {
                self.shouldScrollCurrentBar = true
                displayControllerWithIndex(beforeIndex, direction: .Forward, animated: false, useDelegateCallBack: false)
            }
            tabView.updateCollectionViewUserInteractionEnabled(true)
            self.isMovingViewController = false
        }
        // 화면에서 사라질때 터치가 막혀있으면 터치 가능하도록
        self.view.userInteractionEnabled = true
    }
}


// MARK: - Public Interface

public extension TabPageViewController {

    public func displayControllerWithIndex(index: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool, didComplete: (Void -> Void)? = nil, useDelegateCallBack: Bool = true) {
        
        guard tabItems.count > index && shouldScrollCurrentBar else {
            return
        }

        let nextViewControllers: [UIViewController] = [tabItems[index]]
        beforeIndex = index
        shouldScrollCurrentBar = false
        self.view.userInteractionEnabled = false
        let completion: (Bool -> Void) = { [weak self] _ in
            /// 자식컨트롤러 선택시 델리게이트 애니메이션 후
            if let tabPageViewController = self, tabPageViewControllerDelegate = tabPageViewController.tabPageViewControllerDelegate
                where (nextViewControllers.count == 1 && useDelegateCallBack) {
                tabPageViewControllerDelegate.tabPageViewController(tabPageViewController, didSelectViewController:nextViewControllers[0])
            }
            didComplete?()
            self?.beforeIndex = index
            self?.shouldScrollCurrentBar = true
            self?.view.userInteractionEnabled = true
        }
        /// 자식컨트롤러 선택시 델리게이트 애니메이션 전
        if let tabPageViewControllerDelegate = self.tabPageViewControllerDelegate
            where (nextViewControllers.count == 1 && useDelegateCallBack) {
            tabPageViewControllerDelegate.tabPageViewController(self, willSelectViewController:nextViewControllers[0])
        }
        
        setViewControllers(
            nextViewControllers,
            direction: direction,
            animated: animated,
            completion: completion)
        
        
    }

    public func reloadData() {

        setupPageViewController()
        setupScrollView()
        tabView.dataSource = self.tabViewDataSource
        tabView.reloadData()

    }

    public func updateTabViewIndex() {
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
    }


}


// MARK: - View

extension TabPageViewController {

    private func setupPageViewController() {
        dataSource = self
        delegate = self
        automaticallyAdjustsScrollViewInsets = false

        if tabItems.count > 0 && beforeIndex < tabItems.count {
            setViewControllers([tabItems[beforeIndex]],
                               direction: .Forward,
                               animated: false,
                               completion: nil)
        }

    }

    private func setupScrollView() {
        // Disable PageViewController's ScrollView bounce
        let scrollView = view.subviews.flatMap { $0 as? UIScrollView }.first
        scrollView?.scrollsToTop = false
        scrollView?.delegate = self
        scrollView?.backgroundColor = option.pageBackgoundColor
    }

    /**
     Update NavigationBar
     */

    public func updateNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.shadowImage = UIImage()
            navigationBar.setBackgroundImage(option.tabBackgroundImage, forBarMetrics: .Default)
        }
    }

    private func configuredTabView() -> TabView {
        let tabView = TabView(isInfinity: isInfinity, option: option)
        tabView.translatesAutoresizingMaskIntoConstraints = false

        let height = NSLayoutConstraint(item: tabView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Height,
            multiplier: 1.0,
            constant: option.tabHeight)
        tabView.addConstraint(height)
        view.addSubview(tabView)

        let top = NSLayoutConstraint(item: tabView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topLayoutGuide,
            attribute: .Bottom,
            multiplier:1.0,
            constant: option.tabViewTopMargin)

        let left = NSLayoutConstraint(item: tabView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Leading,
            multiplier: 1.0,
            constant: option.tabViewLeftMargin)

        let right = NSLayoutConstraint(item: view,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: tabView,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: option.tabViewRightMargin)
        view.addConstraints([top, left, right])

        tabView.dataSource = self.tabViewDataSource
        tabView.updateCurrentIndex(beforeIndex, animated: false, shouldScroll: true)

        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewControllerNavigationDirection, isCurrentPage: Bool) in
            
            if let tabPageViewController = self, nextViewController = self?.tabItems[index] {
                tabPageViewController.tabPageViewControllerDelegate?.tabPageViewController(tabPageViewController, didPressedViewController:nextViewController, isCurrentPage:isCurrentPage)
            }
            
            if !isCurrentPage {
                self?.displayControllerWithIndex(index, direction: direction, animated: true)
            }
        }

        return tabView
    }
}


// MARK: - UIPageViewControllerDataSource

extension TabPageViewController: UIPageViewControllerDataSource {

    private func nextViewController(viewController: UIViewController, isAfter: Bool) -> UIViewController? {

        guard var index = tabItems.indexOf(viewController) else {
            return nil
        }

        if isAfter {
            index += 1
        } else {
            index -= 1
        }

        if isInfinity {
            if index < 0 {
                index = tabItems.count - 1
            } else if index == tabItems.count {
                index = 0
            }
        }

        if index >= 0 && index < tabItems.count {
            return tabItems[index]
        }
        return nil
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: true)
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: false)
    }
}


// MARK: - UIPageViewControllerDelegate

extension TabPageViewController: UIPageViewControllerDelegate {

    public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        self.isMovingViewController = true
        tabView.scrollToHorizontalCenter()
        // Order to prevent the the hit repeatedly during animation
        tabView.updateCollectionViewUserInteractionEnabled(false)

    }

    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.isMovingViewController = false
        if let currentIndex = currentIndex where currentIndex < tabItemsCount {
            tabView.updateCurrentIndex(currentIndex, shouldScroll: false)
            beforeIndex = currentIndex
            if let nextViewControllers: [UIViewController] = [tabItems[currentIndex]], nextViewController = nextViewControllers.first {
                self.tabPageViewControllerDelegate?.tabPageViewController(self, didMoveViewController:nextViewController)
            }
        }
        tabView.updateCollectionViewUserInteractionEnabled(true)
    }
}


// MARK: - UIScrollViewDelegate

extension TabPageViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        // UIPageViewController 기본보다 더 움직이고  shouldScrollCurrentBar(움직임 가능 플래그) 가 True일때만
        guard scrollView.contentOffset.x != defaultContentOffsetX && shouldScrollCurrentBar else {
            return
        }
        var index: Int
        if scrollView.contentOffset.x > defaultContentOffsetX {
            // 오른쪽으로 이동
            index = beforeIndex + 1
        } else {
            // 왼쪽으로 이동
            index = beforeIndex - 1
        }

        if index == tabItemsCount {
            index = 0
        } else if index < 0 {
            index = tabItemsCount - 1
        }
        let scrollOffsetX = scrollView.contentOffset.x - view.frame.width
        tabView.scrollCurrentBarView(index, contentOffsetX: scrollOffsetX)
    }
    // 스크롤이 움직였을때 현재 인덱스를 업데이트 shouldScroll은 자동으로 tabview 가운데로 스크롤할지 정하는 플래그
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
        shouldScrollCurrentBar = true
        self.view.userInteractionEnabled = true

    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        shouldScrollCurrentBar = false
        self.view.userInteractionEnabled = false

    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        shouldScrollCurrentBar = true
        self.view.userInteractionEnabled = true
    }
}
