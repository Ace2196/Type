//
//  UberOverlayView.swift
//  TastyImitationKeyboard
//
//  Created by Jingrong (: on 10/10/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation
import LiquidFloatingActionButton

class UberOverlayView: UIView, LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate {
    
    var cells: [LiquidFloatingCell] = []
    var floatingActionButton: LiquidFloatingActionButton!
    
    func viewDidLoad() {
        self.backgroundColor = UIColor.clearColor()
        //        self.view.backgroundColor = UIColor(red: 55 / 255.0, green: 55 / 255.0, blue: 55 / 255.0, alpha: 1.0)
        // Do any additional setup after loading the view, typically from a nib.
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = LiquidFloatingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            return floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            // Get drivers face
            return LiquidFloatingCell(icon: UIImage(named: "Driver")!)
        }
        // Calling asset ( Lower )
        cells.append(cellFactory("Call"))
        // Messaging asset ( Upper )
        cells.append(cellFactory("Info"))
        
        let frameExpandUpFrame = CGFloat(40.0)
        let bottomLeftPadding = CGFloat(16.0)
        
        let floatingFrame = CGRect(x: self.frame.width - frameExpandUpFrame - bottomLeftPadding, y: self.frame.height - frameExpandUpFrame - bottomLeftPadding, width: frameExpandUpFrame, height: frameExpandUpFrame)
        
        
        let bottomRightButton = createButton(floatingFrame, .Up)
        
        self.addSubview(bottomRightButton)
    }
    
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        print ("did Tapped! \(index)")
        
        
        if (index == 0) {
            // Lower button pressed
            
            
        } else if (index == 1) {
            // Upper button pressed
            
        }
        
        liquidFloatingActionButton.close()
        
    }
    
}