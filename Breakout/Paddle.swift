//
//  Paddle.swift
//  Breakout
//
//  Created by Brian Jewkes on 7/7/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import Foundation

class Paddle {
    
    
    var paddleSize:CGSize {
        let size = gameView.bounds.size.width / 10
        return CGSize(width: size, height: size / 2 )
    }
    
    lazy var paddlePosition: CGPoint = {
        let view = self.gameView
        return CGPoint(x: view.bounds.midX - self.paddleSize.width / 2, y: view.bounds.height - view.bounds.height / 10)
        }()
    
}
