//
//  GameOverScene.swift
//  Breakout
//
//  Created by Daniel Flax on 2/5/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import SpriteKit

let GameOverLabelCategoryName = "gameOverLabel"

class GameOverScene: SKScene {
	var gameWon : Bool = false {
		// 1.
		didSet {
			let gameOverLabel = childNodeWithName(GameOverLabelCategoryName) as SKLabelNode!

			gameOverLabel.text = gameWon ? "Game Won" : "Game Over"
		}
	}

	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		if let view = view {
			// 2.
			let gameScene = GameScene.unarchiveFromFile("GameScene") as GameScene!
			view.presentScene(gameScene)
		}
	}


}