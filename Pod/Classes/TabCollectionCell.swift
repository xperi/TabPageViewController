//
//  TabCollectionCell.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

class TabCollectionCell: UICollectionViewCell {
    private var itemContainer =  UIView()
    private var currentBarView = UIView()
    private var touchButton = UIButton()
    var tabItemButtonPressedBlock: (Void -> Void)?
    var option: TabPageOption = TabPageOption()
    var titleItem: TabTitleViewProtocol? {
        didSet {

            if let titleItem = self.titleItem as? UIView {
                if titleItem is TabTitleViewProtocol {
                    titleItem.backgroundColor = UIColor.redColor()
                    titleItem.sizeToFit()
                    itemContainer.subviews.forEach({ $0.removeFromSuperview() })
                    itemContainer.addSubview(titleItem)
                    itemContainer.frame = titleItem.frame
                } else {
                    print("error")
                }
            } else {
                print("error")
            }

        }
    }

    var isCurrent: Bool = false {
        didSet {
            currentBarView.hidden = !isCurrent
            if isCurrent {
                highlightTitle()
            } else {
                unHighlightTitle()
            }
            currentBarView.backgroundColor = option.currentColor
            currentBarView.backgroundColor = UIColor.brownColor()
            layoutIfNeeded()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        self.contentView.backgroundColor = UIColor.blackColor()
        currentBarView.hidden = true
        touchButton.addTarget(self, action: #selector(TabCollectionCell.tabItemTouchUpInside(_:)), forControlEvents: .TouchUpInside)
        itemContainer.backgroundColor = UIColor.greenColor()
        self.contentView.addSubview(itemContainer)
        self.contentView.addSubview(currentBarView)
        self.contentView.addSubview(touchButton)
    }

    override convenience init(frame: CGRect) {
        self.init()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }

    override func sizeThatFits(size: CGSize) -> CGSize {

        return intrinsicContentSize()
    }

    deinit {
        touchButton.removeTarget(self, action: #selector(TabCollectionCell.tabItemTouchUpInside(_:)), forControlEvents: .TouchUpInside)
    }

    class func cellIdentifier() -> String {
        return "TabCollectionCell"
    }
}


// MARK: - View

extension TabCollectionCell {
    override func intrinsicContentSize() -> CGSize {
        var width: CGFloat = 0.0
        if let tabWidth = option.tabWidth where tabWidth > 0.0 {
            width = tabWidth
        }

        width = max(width, itemContainer.frame.width + option.tabMargin * 2)

        let size = CGSizeMake(width, option.tabHeight)
        itemContainer.frame.size = size
        itemContainer.subviews.forEach({ $0.frame.size = size })
        touchButton.frame.size = size
        currentBarView.frame = CGRect(x: 0, y: size.height - option.currentBarHeight, width: width, height: option.currentBarHeight)
        
        return size
    }

    func hideCurrentBarView() {
        currentBarView.hidden = true
    }

    func showCurrentBarView() {
        currentBarView.hidden = false
    }
    func highlightTitle() {
        titleItem?.highlightTitle()
    }

    func unHighlightTitle() {
        titleItem?.unHighlightTitle()
    }
}


// MARK: - IBAction

extension TabCollectionCell {
    @objc private func tabItemTouchUpInside(button: UIButton) {
        tabItemButtonPressedBlock?()
    }
}
