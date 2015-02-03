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
}
