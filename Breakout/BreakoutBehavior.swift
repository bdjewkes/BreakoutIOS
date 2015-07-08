//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Brian Jewkes on 7/7/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    
    private lazy var gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior()
        gravity.magnitude = 0.05
        return gravity
    }()
    
    private lazy var collision: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
        }()
    
    private lazy var breakoutBehaviors: UIDynamicItemBehavior = {
        let behaviors = UIDynamicItemBehavior()
        behaviors.elasticity = 0.95
        behaviors.allowsRotation = false
        return behaviors
    }()
    
    override init(){
        super.init()
        addChildBehavior(collision)
        addChildBehavior(breakoutBehaviors)
        addChildBehavior(gravity)
    }
    
    func setBoundary(path: UIBezierPath, named name: String){
        collision.removeBoundaryWithIdentifier(name)
        collision.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func destroyBoundary(name: String) {
        collision.removeBoundaryWithIdentifier(name)
    }
    
    func addViewToAnimate(view: UIView){
        collision.addItem(view)
        breakoutBehaviors.addItem(view)
        gravity.addItem(view)
    }
    
    func removeViewFromAnimation(view: UIView) {
        collision.removeItem(view)
        breakoutBehaviors.removeItem(view)
        gravity.addItem(view)
    }
        
    func addVelocityToView(view: UIView, velocity: CGPoint) {
        breakoutBehaviors.addLinearVelocity(velocity, forItem: view)
    }
    
    func setCollisionDelegate(delegate: UICollisionBehaviorDelegate){
        collision.collisionDelegate = delegate
    }
}
