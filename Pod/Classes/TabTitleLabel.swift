//
//  TabTitleLabel.swift
//  Pods
//
//  Created by xperi on 2016. 7. 21..
//
//

import UIKit

public class TabTitleLabel: UILabel, TabTitleViewProtocol {
    public func highlightTitle(option: TabPageOption?) {
        self.textColor = option?.currentColor
        if let fontSize = option?.fontSize {
            self.font = UIFont.boldSystemFontOfSize(fontSize)
        }

    }

    public func unHighlightTitle(option: TabPageOption?) {
        self.textColor = option?.defaultColor
        if let fontSize = option?.fontSize {
            self.font = UIFont.boldSystemFontOfSize(fontSize)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let superViewBounds = self.superview?.bounds {
            self.frame = superViewBounds
        }
    }
}
