//
//  GameScene.swift
//  Breakout
//
//  Created by Daniel Flax on 2/2/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import SpriteKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let BlockNodeCategoryName = "blockNode"

var isFingerOnPaddle = false

class GameScene: SKScene {
	override func didMoveToView(view: SKView) {

		// Configure the Physics World itself
		// 1. Create a physics body that borders the screen
		let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
		// 2. Set the friction of that physicsBody to 0
		borderBody.friction = 0
		// 3. Set physicsBody of scene to borderBody
		self.physicsBody = borderBody
		physicsWorld.gravity = CGVectorMake(0, 0)

		// Set up the ball with a physics body
		let ball = childNodeWithName(BallCategoryName) as SKSpriteNode
		ball.physicsBody!.applyImpulse(CGVectorMake(10, -10))

		super.didMoveToView(view)
	}

	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		var touch = touches.anyObject() as UITouch!
		var touchLocation = touch.locationInNode(self)

		if let body = physicsWorld.bodyAtPoint(touchLocation) {
			if body.node!.name == PaddleCategoryName {
				println("Began touch on paddle")
				isFingerOnPaddle = true
			}
		}
	}

	override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
		// 1. Check whether user touched the paddle
		if isFingerOnPaddle {
			// 2. Get touch location
			var touch = touches.anyObject() as UITouch!
			var touchLocation = touch.locationInNode(self)
			var previousLocation = touch.previousLocationInNode(self)

			// 3. Get node for paddle
			var paddle = childNodeWithName(PaddleCategoryName) as SKSpriteNode!

			// 4. Calculate new position along x for paddle
			var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)

			// 5. Limit x so that paddle won't leave screen to left or right
			paddleX = max(paddleX, paddle.size.width/2)
			paddleX = min(paddleX, size.width - paddle.size.width/2)

			// 6. Update paddle position
			paddle.position = CGPointMake(paddleX, paddle.position.y)
		}
	}

}
