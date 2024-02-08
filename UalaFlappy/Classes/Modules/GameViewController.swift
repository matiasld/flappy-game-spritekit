//
//  GameViewController.swift
//  ios-spritekit-flappy-flying-bird
//
//  Created by Astemir Eleev on 02/05/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

//import UalaUI
//import UalaCore
import Foundation
import UIKit
import SpriteKit
import GameplayKit

enum Scenes: String {
    case title = "TitleScene"
    case game = "GameScene"
    case setting = "SettingsScene"
    case score = "ScoreScene"
    case pause = "PauseScene"
    case failed = "FailedScene"
    case characters = "CharactersScene"
}

extension Scenes {
    func getName() -> String {
        let padId = " iPad"
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        return isPad ? self.rawValue + padId : self.rawValue
    }
}

enum NodeScale: Float {
    case gameBackgroundScale
}

extension NodeScale {
    
    func getValue() -> Float {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        switch self {
        case .gameBackgroundScale:
            return isPad ? 4.5 : 4.05
        }
    }
}

extension CGPoint {
    init(x: Float, y: Float) {
        self.init()
        self.x = CGFloat(x)
        self.y = CGFloat(y)
    }
}

// MARK: - View
class GameViewController: UIViewController {
    
    @IBOutlet weak var contentView: SKView!
    @IBOutlet weak var ualaLogo: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!
    
    var currentScene: SKScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, for: .isSoundOn)
        ualaLogo.image = FlappyImage(named: .ualaLogo)
        initFonts()
        
        // SKScene sizing: https://stackoverflow.com/questions/44732696/spritekit-cant-understand-what-size-to-make-background
        let sceneSize = CGSize(width: 750, height: 1434)
        let newScene = GameScene(size: sceneSize)
        newScene.scaleMode = .aspectFill
        currentScene = newScene
        contentView.presentScene(newScene)
        contentView.ignoresSiblingOrder = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func initFonts() {
        registerFont(withName: "Pixel Digivolve", fileExtension: "otf")
//        registerFont(withName: "flappy-font", fileExtension: "ttf")
    }
    
    func registerFont(withName filenameString: String, fileExtension: String = "ttf") {
        let bundle = BundleUtils.getBundleFromFlappy()
        
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: fileExtension) else {
            print("UIFont+Uala: Failed to register font \(filenameString) - path for resource not found.")
            return
        }

        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+Uala: Failed to register font \(filenameString) - font data could not be loaded.")
            return
        }

        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+Uala: Failed to register font \(filenameString) - data provider could not be loaded.")
            return
        }

        guard let font = CGFont(dataProvider) else {
            print("UIFont+Uala: Failed to register font \(filenameString) - font could not be loaded.")
            return
        }

        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+Uala: Failed to register font \(filenameString) - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
    
    @IBAction func dismissHandler() {
        currentScene?.removeFromParent()
        contentView.presentScene(nil)
        dismiss(animated: true)
    }
}
