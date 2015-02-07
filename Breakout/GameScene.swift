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

// Set Category BitMasks
let BallCategory   : UInt32 = 0x1 << 0 // 00000000000000000000000000000001
let BottomCategory : UInt32 = 0x1 << 1 // 00000000000000000000000000000010
let BlockCategory  : UInt32 = 0x1 << 2 // 00000000000000000000000000000100
let PaddleCategory : UInt32 = 0x1 << 3 // 00000000000000000000000000001000

var isFingerOnPaddle = false

class GameScene: SKScene, SKPhysicsContactDelegate {
	override func didMoveToView(view: SKView) {

		// Configure the Physics World itself
		// 1. Create a physics body that borders the screen
		let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
		// 2. Set the friction of that physicsBody to 0
		borderBody.friction = 0
		// 3. Set physicsBody of scene to borderBody
		self.physicsBody = borderBody

		// Configure an edge based physics body for the bottom of the screen
		let bottomRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 1)
		let bottom = SKNode()
		bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
		addChild(bottom)

		// Establish the physicsWorld's gravity vector
		physicsWorld.gravity = CGVectorMake(0, 0)
		physicsWorld.contactDelegate = self

		// Set up blocks to attack!
		// 1. Store some useful constants
		let numberOfBlocks = 5
		let numberOfBlockRows = 3

		let blockWidth = SKSpriteNode(imageNamed: "block.png").size.width
		let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)

		let padding: CGFloat = 10.0
		let totalPadding = padding * CGFloat(numberOfBlocks - 1)

		// 2. Calculate the xOffset
		let xOffset = (CGRectGetWidth(frame) - totalBlocksWidth - totalPadding) / 2

		// 3. Create the blocks and add them to the scene
		for i in 0..<numberOfBlocks {
			let block = SKSpriteNode(imageNamed: "block.png")
			block.position = CGPointMake(xOffset + CGFloat(CGFloat(i) + 0.5)*blockWidth + CGFloat(i-1)*padding, CGRectGetHeight(frame) * 0.8)
			block.physicsBody = SKPhysicsBody(rectangleOfSize: block.frame.size)
			block.physicsBody!.allowsRotation = false
			block.physicsBody!.friction = 0.0
			block.physicsBody!.affectedByGravity = false
			block.name = BlockCategoryName
			block.physicsBody!.categoryBitMask = BlockCategory

			block.physicsBody!.collisionBitMask = 0

			addChild(block)
		}

		// Set up the ball with a physics body
		let ball = childNodeWithName(BallCategoryName) as SKSpriteNode
		ball.physicsBody!.applyImpulse(CGVectorMake(10, -10))

		// Establish the nodes and categories - even the ones created in Scene Builder
		let paddle = childNodeWithName(PaddleCategoryName) as SKSpriteNode!
		bottom.physicsBody!.categoryBitMask = BottomCategory
		ball.physicsBody!.categoryBitMask = BallCategory
		paddle.physicsBody!.categoryBitMask = PaddleCategory

		// Set the contact test bitMask for the ball
		ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory

		ball.physicsBody!.collisionBitMask = PaddleCategory

		super.didMoveToView(view)
	}

	// Check if game has been one
	func isGameWon() -> Bool {
		var numberOfBricks = 0
		self.enumerateChildNodesWithName(BlockCategoryName) {
			node, stop in
			numberOfBricks = numberOfBricks + 1
		}
		return numberOfBricks == 0
	}

	// Overide the update method to adjust and smooth out ball velocity
	override func update(currentTime: NSTimeInterval) {
		let ball = self.childNodeWithName(BallCategoryName) as SKSpriteNode!

		let maxSpeed: CGFloat = 1000.0
		let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)

		if speed > maxSpeed {
			ball.physicsBody!.linearDamping = 0.4
		} else {
			ball.physicsBody!.linearDamping = 0.0
		}
	}

	// Touch Handling
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

	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		isFingerOnPaddle = false
	}

	// Handle collisions and contact
	func didBeginContact(contact: SKPhysicsContact) {

		if isGameWon() {
			if let mainView = view {
				let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as GameOverScene!
				gameOverScene.gameWon = true
				mainView.presentScene(gameOverScene)
			}
		}

		// 1. Create local variables for two physics bodies
		var firstBody: SKPhysicsBody
		var secondBody: SKPhysicsBody

		// 2. Assign the two physics bodies so that the one with the lower category is always stored in firstBody
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}

		// 3. react to the contact between ball and bottom
		if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
			//TODO: Replace the log statement with display of Game Over Scene
			println("Hit bottom. First contact has been made.")

			if let mainView = view {
				let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as GameOverScene!
				gameOverScene.gameWon = false
				mainView.presentScene(gameOverScene)
			}
		}

		if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
			secondBody.node!.removeFromParent()
			//TODO: check if the game has been won
		}

	}




}
