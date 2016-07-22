//
//  TabTitleLabel.swift
//  Pods
//
//  Created by xperi on 2016. 7. 21..
//
//

import UIKit

public class TabTitleLabel: UILabel, TabTitleViewProtocol {
    public var option: TabPageOption?
    public func highlightTitle() {
        self.textColor = option?.currentColor
        if let fontSize = option?.fontSize {
            self.font = UIFont.boldSystemFontOfSize(fontSize)
        }

    }

    public func unHighlightTitle() {
        self.textColor = option?.defaultColor
        if let fontSize = option?.fontSize {
            self.font = UIFont.boldSystemFontOfSize(fontSize)
        }
    }

    public override func intrinsicContentSize() -> CGSize {
        return super.intrinsicContentSize()
    }
}
