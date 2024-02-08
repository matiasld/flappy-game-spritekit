//
//  GameSceneAdapter.swift
//  UalaFlappy
//
//  Created by Matias LaDelfa on 18/03/2022.
//

import SpriteKit
import GameplayKit
import Foundation
import UIKit
import AVFAudio
import AVFoundation

class GameSceneAdapter: NSObject, GameSceneProtocol {
    
    // MARK: - Properties
    
    private let overlayDuration: TimeInterval = 0.25
    private var player: AVAudioPlayer = AVAudioPlayer()

    let gravity: CGFloat = -5.0
    let playerSize = CGSize(width: 100, height: 58)
    let backgroundResourceName = "background02"
    let floorDistance: CGFloat = 0
    
    let isSoundOn: Bool = {
        return UserDefaults.standard.bool(for: .isSoundOn)
    }()
    
    var score: Int = 0
    private(set) var scoreLabel: SKLabelNode?
    private(set) var highScoreLabel: SKLabelNode?
    private(set) var flappyLogo: SKSpriteNode?

    typealias PlayableCharacter = (PhysicsContactable & Updatable & Touchable & Playable & SKNode)
    var bird: BirdNode?
    var playerCharacter: PlayableCharacter?
    
    private(set) lazy var menuAudio: SKAudioNode = {
        let audioNode = SKAudioNode(named: "")
        audioNode.autoplayLooped = true
        audioNode.name = "manu audio"
        return audioNode
    }()
    
    private(set) lazy var playingAudio: SKAudioNode = {
        let audioNode = SKAudioNode(named: .mainTheme)
        audioNode.autoplayLooped = true
        audioNode.name = "playing audio"
        return audioNode
    }()
    
    // MARK: - GameSceneProtocol
    
    weak var scene: SKScene?
    var stateMahcine: GKStateMachine?
    
    var updatables = [Updatable]()
    var touchables = [Touchable]()
    
    /// All buttons currently in the scene. Updated by assigning the result of `findAllButtonsInScene()`.
    var buttons = [ButtonNode]()
    
    /// The current scene overlay (if any) that is displayed over this scene.
    var overlay: SceneOverlay? {
        didSet {
            // Clear the `buttons` in preparation for new buttons in the overlay.
            buttons = []
            
            // Animate the old overlay out.
            oldValue?.backgroundNode.run(SKAction.fadeOut(withDuration: overlayDuration)) {
                debugPrint(#function + " remove old overlay")
                oldValue?.backgroundNode.removeFromParent()
            }
            
            if let overlay = overlay, let scene = scene {
                debugPrint(#function + " added overaly")
                overlay.backgroundNode.removeFromParent()
                scene.addChild(overlay.backgroundNode)
                
                // Animate the overlay in.
                overlay.backgroundNode.alpha = 1.0
                overlay.backgroundNode.run(SKAction.fadeIn(withDuration: overlayDuration))
                
                buttons = scene.findAllButtonsInScene()
            }
        }
    }
    
    private var _isHUDHidden: Bool = false
    var isHUDHidden: Bool {
        get {
            return _isHUDHidden
        }
        set(newValue) {
            _isHUDHidden = newValue
            
            if let world = self.scene?.childNode(withName: "world") {
                world.childNode(withName: "Score Node")?.isHidden = newValue
                world.childNode(withName: "Pause")?.isHidden = newValue
            }
        }
    }

    
    // MARK: - Private properties
    
    private(set) var infiniteBackgroundNode: InfiniteSpriteScrollNode?
    private let notification = UINotificationFeedbackGenerator()
    private let impact = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Initializers
    
    required init?(with scene: SKScene) {
        
        self.scene = scene
        super.init()
        
        guard let scene = self.scene else {
            debugPrint(#function + " could not unwrap the host SKScene instance")
            return nil
        }
        
        // Get access to the score node and then get the score label since it is a child node
        if let scoreNode = scene.childNode(withName: "world")?.childNode(withName: "Score Node") {
            scoreLabel = scoreNode.childNode(withName: "Score Label") as? SKLabelNode
        } else if scoreLabel == nil {
            var scoreLabel = SKLabelNode(fontNamed: "Pixel Digivolve")
            scoreLabel.text = "0"
            scoreLabel.fontSize = 70
            scoreLabel.name = "Score Label"
            scoreLabel.fontColor = SKColor.white
            self.scene?.addChild(scoreLabel)
            scoreLabel.zPosition = 999
            scoreLabel.horizontalAlignmentMode = .right
            let topInset = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
            scoreLabel.position = CGPoint(x: scene.frame.width - 90, y: scene.frame.height - 100 - topInset)
            self.scoreLabel = scoreLabel
        }
        
        // High score label
        var highScore = SKLabelNode(fontNamed: "Pixel Digivolve")
        let storedHighScore = UserDefaults.standard.integer(for: .bestScore)
        highScore.text = "High Score: \(storedHighScore)"
        highScore.fontSize = 35
        highScore.name = "High Score Label"
        highScore.fontColor = SKColor.white
        self.scene?.addChild(highScore)
        highScore.zPosition = 999
        highScore.horizontalAlignmentMode = .center
        let inset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        highScore.position = CGPoint(x: scene.frame.midX, y: 20 + inset)
        highScoreLabel = highScore
        
        // FlappyUala logo
        var logo = SKSpriteNode(asset: .flappyLogo)
        logo.position = CGPoint(x: scene.frame.midX, y: scene.frame.height * 0.725)
        logo.size = CGSize(width: scene.frame.width - 140, height: scene.frame.width / 3.15)
        logo.zPosition = 999
        self.scene?.addChild(logo)
        flappyLogo = logo
        
        prepareWorld(for: scene)
        prepareInfiniteBackgroundScroller(for: scene)
    }
    
    convenience init?(with scene: SKScene, stateMachine: GKStateMachine) {
        self.init(with: scene)
        self.stateMahcine = stateMachine
    }
    
    // MARK: - Helpers
    
    func resetScores() {
        scoreLabel?.text = "0"
    }
    
    func removePipes() {
        var nodes = [SKNode]()
        
        infiniteBackgroundNode?.children.forEach({ node in
            let nodeName = node.name
            if let doesContainNodeName = nodeName?.contains("pipe"), doesContainNodeName { nodes += [node] }
        })
        nodes.forEach { node in
            node.removeAllActions()
            node.removeAllChildren()
            node.removeFromParent()
        }
        nodes.removeAll()
    }
    
    func advanceSnowEmitter(for duration: TimeInterval) {
        let snowParticleEmitter = scene?.childNode(withName: "Snow Particle Emitter") as? SKEmitterNode
        snowParticleEmitter?.safeAdvanceSimulationTime(duration)
    }
    
    private func prepareWorld(for scene: SKScene) {
        scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: gravity)
        let rect = CGRect(x: 0, y: floorDistance, width: scene.size.width, height: scene.size.height - floorDistance)
        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        
        let boundary: PhysicsCategories = .boundary
        let player: PhysicsCategories = .player
        
        scene.physicsBody?.categoryBitMask = boundary.rawValue
        scene.physicsBody?.collisionBitMask = player.rawValue
        scene.physicsWorld.contactDelegate = self
    }
    
    private func prepareInfiniteBackgroundScroller(for scene: SKScene) {
        let scaleFactor = NodeScale.gameBackgroundScale.getValue()
        
        infiniteBackgroundNode = InfiniteSpriteScrollNode(fileName: backgroundResourceName, scaleFactor: CGPoint(x: scaleFactor, y: scaleFactor))
        infiniteBackgroundNode!.zPosition = 0
        
        scene.addChild(infiniteBackgroundNode!)
        updatables.append(infiniteBackgroundNode!)
    }
    
    private func playSound(named: AudioAsset) -> SKAction {
        return SKAction.run {
            let bundle = BundleUtils.getBundleFromFlappy()
            guard let path = bundle.path(forResource: named.rawValue, ofType: nil) else { return }
            
            let url = URL(fileURLWithPath: path)
            do {
                self.player = try AVAudioPlayer(contentsOf: url)
                self.player.volume = 1.0
                self.player.play()

            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Collision Handlers

extension GameSceneAdapter: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
        let player = PhysicsCategories.player.rawValue
        
        if collision == (player | PhysicsCategories.gap.rawValue) {
            score += 1
            scoreLabel?.text = "\(score)"
            UserDefaults.standard.setHighScoreIfNeeded(score: score)
            
            if isSoundOn { scene?.run(playSound(named: .coin)) }
            notification.notificationOccurred(.success)
        }
        
        if collision == (player | PhysicsCategories.pipe.rawValue) {
            // game over state, the player has touched a pipe
            handleDeadState()
        }
        
        if collision == (player | PhysicsCategories.boundary.rawValue) {
            // game over state, the player has touched the boundary of the world (floor or ceiling)
            // player's position needs to be set to the default one
            handleDeadState()
        }
    }
        
    private func handleDeadState() {
        debugPrint("handleDeadState")
        deadState()
        hit()
        
        // RESETTING SCENE:
        guard let scene = scene, let view = scene.view else { return }
        let gameScene = GameScene(size: scene.size)
        let transition = SKTransition.fade(withDuration: 0.7)
        gameScene.scaleMode = .aspectFill
        view.presentScene(gameScene, transition: transition)
    }
    
    private func deadState() {
        // Do not enter the same state twice
        if stateMahcine?.currentState is GameOverState { return }
        stateMahcine?.enter(GameOverState.self)
    }
    
    private func hit() {
        impact.impactOccurred()
        if isSoundOn { scene?.run(playSound(named: .hit)) }
    }
}
