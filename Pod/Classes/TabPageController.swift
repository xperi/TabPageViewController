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
    func intrinsicContentSize() -> CGSize
}


public class TabPageViewController: UIPageViewController {
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
    private var beforeIndex: Int = 0
    private var tabItemsCount: Int = 0
    private var defaultContentOffsetX: CGFloat {
        return self.view.bounds.width
    }

    private var shouldScrollCurrentBar: Bool = true
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
}


// MARK: - Public Interface

public extension TabPageViewController {

    public func displayControllerWithIndex(index: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool, didComplete: (Void -> Void)? = nil) {

        beforeIndex = index
        shouldScrollCurrentBar = false
        let nextViewControllers: [UIViewController] = [tabItems[index]]

        let completion: (Bool -> Void) = { [weak self] _ in
            self?.shouldScrollCurrentBar = true
            self?.beforeIndex = index
            didComplete?()
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
        tabView = self.configuredTabView()
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
            constant: 0.0)

        let left = NSLayoutConstraint(item: tabView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Leading,
            multiplier: 1.0,
            constant: 0.0)

        let right = NSLayoutConstraint(item: view,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: tabView,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0.0)

        view.addConstraints([top, left, right])

        tabView.dataSource = self.tabViewDataSource
        tabView.updateCurrentIndex(beforeIndex, animated: false, shouldScroll: true)

        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewControllerNavigationDirection) in
            self?.displayControllerWithIndex(index, direction: direction, animated: true)
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
        shouldScrollCurrentBar = true
        tabView.scrollToHorizontalCenter()

        // Order to prevent the the hit repeatedly during animation
        tabView.updateCollectionViewUserInteractionEnabled(false)
    }

    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentIndex = currentIndex where currentIndex < tabItemsCount {
            tabView.updateCurrentIndex(currentIndex, shouldScroll: false)
            beforeIndex = currentIndex
        }

        tabView.updateCollectionViewUserInteractionEnabled(true)
    }
}


// MARK: - UIScrollViewDelegate

extension TabPageViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x == defaultContentOffsetX || !shouldScrollCurrentBar {
            return
        }

        // (0..<tabItemsCount)
        var index: Int
        if scrollView.contentOffset.x > defaultContentOffsetX {
            index = beforeIndex + 1
        } else {
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

    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
    }
}
