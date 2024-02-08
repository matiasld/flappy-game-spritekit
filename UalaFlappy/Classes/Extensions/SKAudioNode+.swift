//
//  SKAudioNode+.swift
//  UalaFlappy-Flappy
//
//  Created by Matias LaDelfa on 27/03/2022.
//

import SpriteKit
import GameplayKit
//import UalaCore
import Foundation
import UIKit

extension SKAudioNode {
    convenience init(named: AudioAsset) {
        let bundle = BundleUtils.getBundleFromFlappy()
        let name = named.rawValue.components(separatedBy: ".")
        let url = bundle.url(forResource: name[0], withExtension: name[1])
        guard let url = url else {
            self.init(fileNamed: "")
            return
        }
        self.init(url: url)
    }
    
    convenience init(named: String, ext: String = "mp3") {
        let bundle = BundleUtils.getBundleFromFlappy()
        let url = bundle.url(forResource: named, withExtension: ext)
        guard let url = url else {
            self.init(fileNamed: "")
            return
        }
        self.init(url: url)
    }
}

enum AudioAsset: String {
    case mainTheme = "main-theme1.mp3"
    case coin = "Coin.wav"
    case hit = "Hit_Hurt.wav"
    case click = "click1.mp3"
}
