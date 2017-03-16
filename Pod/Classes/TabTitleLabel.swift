//
//  TabTitleLabel.swift
//  Pods
//
//  Created by xperi on 2016. 7. 21..
//
//

import UIKit

open class TabTitleLabel: UILabel, TabTitleViewProtocol {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    open func highlightTitle(_ option: TabPageOption?) {
        self.textColor = option?.currentColor
        if let fontSize = option?.fontSize {
            self.font = UIFont.boldSystemFont(ofSize: fontSize)
        }

    }

    open func unHighlightTitle(_ option: TabPageOption?) {
        self.textColor = option?.defaultColor
        if let fontSize = option?.fontSize {
            self.font = UIFont.boldSystemFont(ofSize: fontSize)
        }
    }
}
