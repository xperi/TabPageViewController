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
    var option: TabPageOption = TabPageOption() {
        didSet {

            self.currentBarView.backgroundColor = option.currentBarColor
            self.contentView.backgroundColor = option.tabBackgroundColor
            layoutIfNeeded()
        }
    }
    var titleItem: TabTitleViewProtocol? {
        didSet {

            if let titleItem = self.titleItem as? UIView {
                if titleItem is TabTitleViewProtocol {
                    titleItem.sizeToFit()
                    titleItem.frame.size.height = option.tabHeight
                    itemContainer.frame.size.width = titleItem.frame.size.width
                    itemContainer.subviews.forEach({ $0.removeFromSuperview() })
                    itemContainer.addSubview(titleItem)
                }
            }

        }
    }

    var isCurrent: Bool = false

    init() {
        super.init(frame: CGRect.zero)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isCurrent = false
        hideCurrentBarView()
        unHighlightTitle()
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
        } else {
            width = itemContainer.frame.size.width
        }
        let size = CGSizeMake(width, option.tabHeight)
        itemContainer.frame.size = size
        itemContainer.subviews.forEach({ $0.frame.size = size })
        itemContainer.layoutIfNeeded()
        touchButton.frame.size = size
        currentBarView.frame = CGRect(x: 0, y: size.height - option.currentBarHeight, width: width, height: option.currentBarHeight)

    }
   
    // option.tabWidth 가 정의되지 않을때 셀 사이즈 가져오는 메소드
    override func sizeThatFits(size: CGSize) -> CGSize {
        
        return CGSize(width: itemContainer.frame.size.width, height: size.height)
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
