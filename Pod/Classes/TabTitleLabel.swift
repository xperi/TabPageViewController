//
//  TabTitleLabel.swift
//  Pods
//
//  Created by xperi on 2016. 7. 21..
//
//

import UIKit

public class TabTitleLabel: UILabel, TabTitleViewProtocol {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        self.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }

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
}
