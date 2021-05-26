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
			scoreLabel.text = "Score: \(score)"
		}
	}

	var scoreLabel: SKLabelNode!

	let gameLength = 10
	var launches = 0 {
		didSet {
			if launches == gameLength {
				finishGame()
			}
		}
	}

	override func didMove(to view: SKView) {
		let background = SKSpriteNode(imageNamed: "background")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)

		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.fontSize = 48
		scoreLabel.text = "Score: \(score)"
		scoreLabel.position = CGPoint(x: 512, y: 20)
		addChild(scoreLabel)

		gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)

	}

	func createFirework(xMovement: CGFloat, x: Int, y: Int) {
		let node = SKNode()
		node.position = CGPoint(x: x, y: y)

		let firework = SKSpriteNode(imageNamed: "rocket")
		firework.colorBlendFactor = 1
		firework.name = "firework"
		node.addChild(firework)

		switch Int.random(in: 0...2) {
		case 0:
			firework.color = .cyan
		case 1:
			firework.color = .red
		case 2:
			firework.color = .green
		default:
			break
		}

		let path = UIBezierPath()
		path.move(to: .zero)
		path.addLine(to: CGPoint(x: xMovement, y: 1000))

		let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
		node.run(move)

		if let emitter = SKEmitterNode(fileNamed: "fuse") {
			emitter.position = CGPoint(x: 0, y: -22)
			node.addChild(emitter)
		}

		fireworks.append(node)
		addChild(node)

	}

	@objc func launchFireworks() {
		let movementAmount: CGFloat = 1800

		switch Int.random(in: 0...3) {
		case 0:
			// straight up
			createFirework(xMovement: 0, x: 512, y: bottomEdge)
			createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
			createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
			createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
			createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
		case 1:
			// fan
			createFirework(xMovement: 0, x: 512, y: bottomEdge)
			createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
			createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
			createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
			createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
		case 2:
			// left to right
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
		case 3:
			// right to left
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
		default:
			break
		}
		launches += 1
	}

	func checkTouches(_ touches: Set<UITouch>) {
		guard let touch = touches.first else { return }

		let location = touch.location(in: self)
		let nodesAtPoint = nodes(at: location)

		for case let node as SKSpriteNode in nodesAtPoint {
			guard node.name == "firework" else { return }
			for parent in fireworks {
				guard let firework = parent.children.first as? SKSpriteNode else { continue }
				if firework.name == "selected" && firework.color != node.color {
					firework.name = "firework"
					firework.colorBlendFactor = 1
				}
			}
			node.name = "selected"
			node.colorBlendFactor = 0
		}

	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		checkTouches(touches)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		checkTouches(touches)
	}

	override func update(_ currentTime: TimeInterval) {
		for (index, firework) in fireworks.enumerated().reversed() {
			if firework.position.y > 900 {
				fireworks.remove(at: index)
				firework.removeFromParent()
			}
		}
	}

	func explode(firework: SKNode) {
		if let emitter = SKEmitterNode(fileNamed: "explode") {
			emitter.position = firework.position
			addChild(emitter)
		}
		firework.removeFromParent()
	}

	func explodeFireworks() {
		var numExploded = 0

		for (index, fireworkContainer) in fireworks.enumerated().reversed() {
			guard let firework = fireworkContainer.children.first as? SKSpriteNode  else { continue }
			if firework.name == "selected" {
				explode(firework: fireworkContainer)
				fireworks.remove(at: index)
				numExploded += 1
			}
		}

		switch numExploded {
		case 0:
			break
		case 1:
			score += 200
		case 2:
			score += 500
		case 3:
			score += 1500
		case 4:
			score += 2500
		case 5:
			score += 4000
		default:
			break
		}
	}

	func finishGame() {
		gameTimer?.invalidate()
		let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
		gameOverLabel.fontSize = 64
		gameOverLabel.position = CGPoint(x: 512, y: 384)
		gameOverLabel.text = "Game over"
		gameOverLabel.horizontalAlignmentMode = .center
		gameOverLabel.alpha = 0
		let wait = SKAction.wait(forDuration: 6)
		let fadeIn = SKAction.fadeIn(withDuration: 0.8)
		let sequence = SKAction.sequence([wait, fadeIn])
		gameOverLabel.run(sequence)
		addChild(gameOverLabel)
	}
}
