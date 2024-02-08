//
//  ExampleView.swift
//  UalaFlappy_Example
//
//  Created by Matias LaDelfa on 27/03/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import UalaFlappy

class ExampleView: UIViewController {
    
    override func viewDidLoad() {
        let view = FlappyModule.build()
        view.modalPresentationStyle = .fullScreen
        self.present(view, animated: true)
    }
}
