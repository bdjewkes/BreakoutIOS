//
//  BezierPathView.swift
//  Breakout
//
//  Created by Brian Jewkes on 7/7/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class BezierPathView: UIView {

    
    private var namedPath = [String:UIBezierPath]()    
    
    func setPath(path: UIBezierPath?, name: String) {
        namedPath[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for (index,path) in namedPath {
            path.stroke()
        }
    
    }
    

}
