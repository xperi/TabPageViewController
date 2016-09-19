//
//  TabCollectionCell.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

class TabCollectionCell: UICollectionViewCell {
    public var itemContainer =  UIView()
    private var currentBarView = UIView()
    private var touchButton = UIButton()
    var tabItemButtonPressedBlock: (Void -> Void)?
    var option: TabPageOption = TabPageOption()
    var titleItem: TabTitleViewProtocol? {
        didSet {

            if let titleItem = self.titleItem as? UIView {
                if titleItem is TabTitleViewProtocol {
                    titleItem.sizeToFit()
                    itemContainer.subviews.forEach({ $0.removeFromSuperview() })
                    itemContainer.addSubview(titleItem)
                }
            }

        }
    }

    var isCurrent: Bool = false {
        didSet {
            if isCurrent {
                highlightTitle()
            } else {
                unHighlightTitle()
            }
            currentBarView.backgroundColor = option.currentBarColor
            layoutIfNeeded()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        self.contentView.backgroundColor = option.tabBackgroundColor
        currentBarView.hidden = true
        touchButton.addTarget(self, action: #selector(TabCollectionCell.tabItemTouchUpInside(_:)), forControlEvents: .TouchUpInside)
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

    deinit {
        touchButton.removeTarget(self, action: #selector(TabCollectionCell.tabItemTouchUpInside(_:)), forControlEvents: .TouchUpInside)
    }

    class func cellIdentifier() -> String {
        return "TabCollectionCell"
    }
}


// MARK: - View

extension TabCollectionCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var width: CGFloat = 0.0
        if let tabWidth = option.tabWidth where tabWidth > 0.0 {
            width = tabWidth
        }
        let size = CGSizeMake(width, option.tabHeight)
        itemContainer.frame.size = size
        itemContainer.subviews.forEach({ $0.frame.size = size })
        touchButton.frame.size = size
        currentBarView.frame = CGRect(x: 0, y: size.height - option.currentBarHeight, width: width, height: option.currentBarHeight)
        
    }

    func hideCurrentBarView() {
        currentBarView.hidden = true
    }

    func showCurrentBarView() {
        currentBarView.hidden = false
    }
    func highlightTitle() {
        titleItem?.highlightTitle(option)
    }

    func unHighlightTitle() {
        titleItem?.unHighlightTitle(option)
    }
}


// MARK: - IBAction

extension TabCollectionCell {
    @objc private func tabItemTouchUpInside(button: UIButton) {
        tabItemButtonPressedBlock?()
    }
}
