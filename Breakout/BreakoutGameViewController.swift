//
//  BreakoutGameViewController.swift
//  Breakout
//
//  Created by Brian Jewkes on 7/7/15.
//  Copyright (c) 2015 Brian Jewkes. All rights reserved.
//

import UIKit

class BreakoutGameViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {

    @IBOutlet weak var gameView: BezierPathView!

    private lazy var animator: UIDynamicAnimator = {
        let dynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        dynamicAnimator.delegate = self
        return dynamicAnimator
    }()
    
    private let breakoutBehaviors = BreakoutBehavior()
    
    struct BoundaryPathName{
        static let paddle = "Paddle"
        static let ball = "Ball"
    }
    
    private var boundViewsByPathName = [String:UIView]()
    
    private var paddleSize:CGSize {
        let size = gameView.bounds.size.width / 10
        return CGSize(width: size, height: size / 2 )
    }
    
    private var paddlePosition: CGPoint {
        return CGPoint(x: (view.bounds.midX - self.paddleSize.width / 2) + paddlePositionOffset, y: view.bounds.height - view.bounds.height / 10)
    }
    
    private var paddlePositionOffset: CGFloat = 0 {
        didSet {
            updatePaddle()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for (pathName, view) in boundViewsByPathName{
            drawBoundaryNamed(pathName, rect: view.frame)
        }
        placeBricks()
        updatePaddle()
        
    }
    
    private func drawBoundaryNamed(pathName: String, rect: CGRect){
        var path: UIBezierPath
        if pathName == BoundaryPathName.paddle{
            path = UIBezierPath(roundedRect: rect, cornerRadius: rect.width/3)
        }
        
        else {
            path = UIBezierPath(rect: rect)
        }
        gameView.setPath(path, name: pathName)
        breakoutBehaviors.setBoundary(path, named: pathName)
        animator.updateItemUsingCurrentState(boundViewsByPathName[pathName]!)
    }
    
    @IBAction func paddlePan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Changed:
            pan(sender.translationInView(gameView).x)
            sender.setTranslation(CGPoint(x: 0, y: 0), inView: gameView)
        default:
            break
        }
    }
    
    private func pan(translation: CGFloat)
    {
        paddlePositionOffset += translation
    }
    
    //MARK: ViewController Lifecycle
    
    override func viewDidLoad(){
        super.viewDidLoad()
        animator.addBehavior(breakoutBehaviors)
        let paddleView = UIView(frame: CGRect(origin: paddlePosition, size: paddleSize))
        paddleView.backgroundColor = UIColor.blueColor()
        gameView.addSubview(paddleView)
        boundViewsByPathName[BoundaryPathName.paddle] = paddleView
        updatePaddle()
        makeBall()
        makeBricks()
        breakoutBehaviors.setCollisionDelegate(self)
    }
    
    func updatePaddle()
    {
        //Prevent the paddle from going outside of the bounds
        if paddlePositionOffset > (gameView.bounds.width - paddleSize.width) / 2 {
            paddlePositionOffset = (gameView.bounds.width - paddleSize.width) / 2
        } else if  paddlePositionOffset < -(gameView.bounds.width - paddleSize.width) / 2 {
                paddlePositionOffset = -(gameView.bounds.width - paddleSize.width) / 2
        }
        boundViewsByPathName[BoundaryPathName.paddle]!.frame = CGRect(origin: paddlePosition, size: paddleSize)
        drawBoundaryNamed(BoundaryPathName.paddle,
            rect:  boundViewsByPathName[BoundaryPathName.paddle]!.frame)
        
    }
    
    func makeBall()
    {
        let ballView = UIView()
        ballView.frame = CGRect(origin: gameView.center, size: CGSize(width: 10, height: 10) )
        ballView.backgroundColor = UIColor.redColor()
        gameView.addSubview(ballView)
        breakoutBehaviors.addViewToAnimate(ballView)
        breakoutBehaviors.addVelocityToView(ballView, velocity: GameSettings.ballVelocityInitial)
    }
    
    struct GameSettings{
        static let bricksPerRow = 8
        static let rowsOfBricks = 4
        static let brickSpacing: CGFloat = 5
        static let ballVelocityInitial = CGPoint(x: 0, y: 250)
        static let ballVelocityFromPaddle = CGPoint(x: 0, y: -150)
    }

    private var verticalOffset: CGFloat {
        return gameView.bounds.height / 10
    }
    
    private var bricks = [UIView?]()
    
    func makeBricks(){
        for row in 0..<GameSettings.rowsOfBricks{
            for column in 0..<GameSettings.bricksPerRow {
                let brickView = UIView(frame: brickFrameForPath(row: row, column: column))
                gameView.addSubview(brickView)
                brickView.backgroundColor = UIColor.redColor()
                let brickID = "Brick\(row)x\(column)"
                boundViewsByPathName[brickID] = brickView
                bricks.append(brickView)
            }
        }
    }
    
    private func brickFrameForPath(#row: Int, column: Int) -> CGRect {
        let brickSize = CGSize(width: ((gameView.bounds.width) / CGFloat(GameSettings.bricksPerRow)) - GameSettings.brickSpacing,height: (gameView.bounds.height) / 20)
        let brickOrigin = CGPoint(x: (GameSettings.brickSpacing + (brickSize.width + GameSettings.brickSpacing) * CGFloat(column)) - GameSettings.brickSpacing / 2,
            y: verticalOffset + (brickSize.height + GameSettings.brickSpacing) * CGFloat(row))
        return CGRect(origin: brickOrigin, size: brickSize)
    }
    
    private func placeBricks()
    {
        for (index, item) in  enumerate(bricks) {
            let row = index / (GameSettings.bricksPerRow)
            let column = index % GameSettings.bricksPerRow
            if let brick = item {
                brick.frame = brickFrameForPath(row: row, column: column)
            } else { //the brick has been destroyed, carry on
                continue
            }
        }
    }
    
    private func removeBoundaryViewByName(pathName: String){
        let view = boundViewsByPathName[pathName]
        view?.removeFromSuperview()
        boundViewsByPathName[pathName] = nil
        breakoutBehaviors.destroyBoundary(pathName)
        gameView.setPath(nil, name: pathName)
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying) {
        let identifierOp: NSCopying? = identifier
        if let pathName = identifierOp as? String {
            if pathName == BoundaryPathName.paddle{
                breakoutBehaviors.addVelocityToView(item as! UIView, velocity: GameSettings.ballVelocityFromPaddle)
            } else if pathName.rangeOfString("Brick") != nil{
                removeBoundaryViewByName(pathName)
            }
        }
    }
}
