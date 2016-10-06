//
//  TabCollectionCell.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

class TabCollectionCell: UICollectionViewCell {
    @IBOutlet private weak var itemContainer: UIView!
    @IBOutlet private weak var currentBarView: UIView!
    @IBOutlet private weak var touchButton: UIButton!

    var tabItemButtonPressedBlock: (Void -> Void)?
    var option: TabPageOption = TabPageOption()
    var titleItem: TabTitleViewProtocol? {
        didSet {

            if let titleItem = self.titleItem as? UIView {
                if titleItem is TabTitleViewProtocol {
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


    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = option.tabBackgroundColor
        currentBarView.hidden = true
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
    @IBAction private func tabItemTouchUpInside(button: UIButton) {
        tabItemButtonPressedBlock?()
    }
}
