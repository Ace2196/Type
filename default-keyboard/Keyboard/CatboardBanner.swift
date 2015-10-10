//
//  CatboardBanner.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit

/*
This is the demo banner. The banner is needed so that the top row popups have somewhere to go. Might as well fill it
with something (or leave it blank if you like.)
*/

class TextFieldBanner: ExtraView {
    
    var catSwitch: UISwitch = UISwitch()
    var catLabel: UILabel = UILabel()
    var textField: UITextField!
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textField = UITextField(frame: CGRectMake(5, 5, self.frame.width - 10, self.frame.height))
        textField.layer.cornerRadius = 3.0
        textField.placeholder = " Hello World!"
        textField.backgroundColor = UIColor.whiteColor()
        self.addSubview(textField)
    }
}
