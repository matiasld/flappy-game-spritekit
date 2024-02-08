//
//  FlappyImage.swift
//  UalaFlappy
//
//  Created by Matias LaDelfa on 18/03/2022.
//

//import UalaUI
//import UalaCore
import Foundation
import UIKit

public class FlappyImage: BundleImage {
    convenience public init?(named: FlappyAsset) {
        let bundle = BundleUtils.getBundleFromFlappy()
        guard let image = UIImage(named: named.rawValue,
                                  in: bundle,
                                  compatibleWith: nil)?.cgImage else { return nil }
        
        self.init(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
    }
    
    convenience public init?(named: String) {
        let bundle = BundleUtils.getBundleFromFlappy()
        guard let image = UIImage(named: named,
                                  in: bundle,
                                  compatibleWith: nil)?.cgImage else { return nil }
        
        self.init(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
    }
}

public enum FlappyAsset: String {
    case pixelUala = "pixel_logo"
    case player1 = "r_player1"
    case pipe = "pipe-green"
    case cap = "cap-green"
    case ualaLogo = "pixel-uala+logo"
    case flappyLogo = "flappy-uala"
    case airadventurelevel4
}

// MARK: - Bundle Extension
extension BundleUtils {
    public static func getBundleFromFlappy() -> Bundle {
        let stringTable = "Flappy"
        let identifier = "org.cocoapods.UalaFlappy"
        guard let tableBundle = Bundle(identifier: identifier) else { return Bundle.main }

        guard let resourceURL = tableBundle.resourceURL?.appendingPathComponent(stringTable + ".bundle"),
              let resourseBundle = Bundle(url: resourceURL) else {
            guard let resourceURL = tableBundle.resourceURL,
                  let resourseBundle = Bundle(url: resourceURL) else { return Bundle.main }
            return resourseBundle
        }
        
        return resourseBundle
    }
}

open class BundleImage: UIImage {
  convenience public init?(bundle: StringTables, named: String) {
    
    let bundle = BundleUtils.getBundle(from: bundle)
    guard let image = UIImage(named: named,
                              in: bundle,
                              compatibleWith: nil)?.cgImage else { return nil }
    
    self.init(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
  }
}

public class BundleUtils {
  public static func getBundle(from table: StringTables?) -> Bundle {
    let map = ["Loans": "org.cocoapods.UalaLoans",
               "Common": "org.cocoapods.UalaUI",
               "Core": "org.cocoapods.UalaCore",
               "Investments": "org.cocoapods.UalaInvestment",
               "PinFlow": "org.cocoapods.UalaPinFlow",
               "Transactions": "org.cocoapods.UalaTransactions",
               "SignUp": "org.cocoapods.UalaSignUp",
               "Exchange": "org.cocoapods.UalaExchange",
               "Transfers": "org.cocoapods.UalaTransfers",
               "AccountCharge": "org.cocoapods.UalaAccountCharge",
               "Acquiring": "org.cocoapods.UalaAcquiring",
               "UalaHelp": "org.cocoapods.UalaHelp",
               "Cards": "org.cocoapods.UalaCards",
               "Loyalty": "org.cocoapods.UalaLoyalty",
               "Taxes": "org.cocoapods.UalaTaxCalculator",
               "Remittances": "org.cocoapods.UalaRemittances",
               "Insurance": "org.cocoapods.UalaInsurance",
               "Crypto": "org.cocoapods.UalaCrypto",
               "UalaSoftoken": "org.cocoapods.UalaSoftoken",
               "Tracking": "org.cocoapods.UalaCardTracking",
               "Payments": "org.cocoapods.UalaPayments",
               "Cedears": "org.cocoapods.UalaCedears",
               "CreditCard": "org.cocoapods.UalaCreditCard"]
    
    guard let stringTable = table?.rawValue,
          let identifier = map[stringTable],
          let tableBundle = Bundle(identifier: identifier) else { return Bundle.main }
    
    guard let resourceURL = tableBundle.resourceURL?.appendingPathComponent(stringTable + ".bundle"),
          let resourseBundle = Bundle(url: resourceURL) else {
      guard let resourceURL = tableBundle.resourceURL,
            let resourseBundle = Bundle(url: resourceURL) else { return Bundle.main }
      return resourseBundle
    }
    
    return resourseBundle
  }
}

public enum StringTables: String {
  case Common, Core, Investments, Loans, PinFlow, Transactions, SignUp, Exchange, AccountCharge, Transfers, Acquiring, UalaHelp, Cards, Loyalty, Portfolio, Taxes, Crypto, Remittances, Insurance, UalaSoftoken, Cedears, Tracking, Payments, CreditCard
}
