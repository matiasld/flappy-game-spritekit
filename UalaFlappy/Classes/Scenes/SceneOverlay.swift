//
//  SceneOverlay.swift
//  ios-spritekit-flappy-flying-bird
//
//  Created by Astemir Eleev on 07/05/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import SpriteKit

func *(lhs: CGSize, value: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * value, height: lhs.height * value)
}

class SceneOverlay {
    
    // MARK: Properties
    
    let backgroundNode: SKSpriteNode
    let contentNode: SKSpriteNode
    
    // MARK: Intialization
    
    init(overlaySceneFileName fileName: String, zPosition: CGFloat, sceneView: UIView? = nil) {
        // Load the scene and get the overlay node from it.
//        let overlayScene = SKScene(fileNamed: fileName)!
        guard let sceneView = sceneView else {
            backgroundNode = SKSpriteNode(color: .black, size: CGSize())
            contentNode = SKSpriteNode(color: .black, size: CGSize())
            return
        }
        let overlayScene = FailedScene(size: sceneView.bounds.size)
        overlayScene.scaleMode = .aspectFill
        let contentTemplateNode = overlayScene.childNode(withName: "Overlay") as! SKSpriteNode
        
        // Create a background node with the same color as the template.
        backgroundNode = SKSpriteNode(color: contentTemplateNode.color, size: contentTemplateNode.size * UIScreen.main.scale)
        backgroundNode.zPosition = zPosition

        // Copy the template node into the background node.
        contentNode = contentTemplateNode.copy() as! SKSpriteNode
        contentNode.position = .zero
        backgroundNode.addChild(contentNode)
        
        // Set the content node to a clear color to allow the background node to be seen through it.
        contentNode.color = .clear
    }

}
