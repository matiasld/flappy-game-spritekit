//
//  MyScene.swift
//  UalaFlappy
//
//  Created by Matias LaDelfa on 18/03/2022.
//

import UIKit
import SpriteKit

class MyScene: SKScene {
    var background = SKSpriteNode(imageNamed: "")
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = UIColor(red: 199.0/255.0, green: 246.0/255.0, blue: 248.0/255.0, alpha: 1.0)
        
        let center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        guard let image = FlappyImage(named: .pixelUala) else { return }
        let texture = SKTexture(image: image)
        let sprite = SKSpriteNode(texture: texture)
        background = sprite
        background.position = center
        addChild(background)
        
        let playerSize = CGSize(width: 200, height: 200)
        let birdNode = BirdNode(animationTimeInterval: 0.1, withTextureAtlas: FlappyAsset.player1.rawValue, size: playerSize)
        birdNode.isAffectedByGravity = false
        birdNode.position = center
//        birdNode.zPosition = 0
        scene?.addChild(birdNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let box = SKSpriteNode(color: SKColor.red, size: CGSize(width: 50, height: 50))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        addChild(box)
    }
    
}


