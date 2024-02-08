//
//  FlappyModule.swift
//  UalaFlappy
//
//  Created by Matias LaDelfa on 27/03/2022.
//

//import UalaCore
import Foundation
import UIKit

// MARK: - Builder
public class FlappyModule {
    public static func build() -> UIViewController {
        let view: GameViewController = GameViewController.loadXib()
        return view
    }
}

// MARK: - UIViewControllerExtension
public extension UIViewController {
  
  static func loadXib<T: UIViewController>() -> T {
    let bundle = Bundle(for: T.self)
    return T(nibName: "\(self)", bundle: bundle)
  }
}

// MARK: - NibName as Controller name

extension UIViewController {
  static var nibName: String { String(describing: Self.self) }
}
