//
//  GameScene.swift
//  FireworksNight
//
//  Created by Paul Richardson on 25/05/2021.
//

import SpriteKit


class GameScene: SKScene {

	var gameTimer: Timer?
	var fireworks = [SKNode]()

	let leftEdge = -22
	let rightEdge = 1024 + 22
	let bottomEdge = -22

	var score = 0 {
		didSet {

		}
	}

	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)

		gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)

	}

	@objc func launchFireworks(xMovement: CGFloat, x: Int, y: Int) {
		//
	}

	func createFirework() {
		//
	}

}
