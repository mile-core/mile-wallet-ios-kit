//
//  Utils.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit
import EFQRCode

public extension String {
    public static let numberFormatter = NumberFormatter()
    public var floatValue: Float {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.floatValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.floatValue
            }
        }
        return 0
    }
}

public func groupBy<C: Collection, K: Hashable>(_ xs: C, key: (C.Iterator.Element) -> K) -> [K:[C.Iterator.Element]] {
    var gs: [K:[C.Iterator.Element]] = [:]
    for x in xs {
        let k = key(x)
        var ys = gs[k] ?? []
        ys.append(x)
        gs.updateValue(ys, forKey: k)
    }
    return gs
}

public extension UIImage {
    
    public var base64:String? {
        return UIImagePNGRepresentation(self)?.base64EncodedString() 
    }

    public var imageSrc:String {
        if let b = base64 { 
            return "data:image/png;base64,\(b)"
        }
        return ""
    }
    
    public static func qrCode(for content: String) -> UIImage? {
        if let tryImage = EFQRCode.generate(content: content) {
            return UIImage(cgImage: tryImage, scale: 1, orientation: UIImageOrientation.up)
        } 
        return nil
    }        
}

public extension String {
    
    public var qrCodeImage:UIImage? {
        return UIImage.qrCode(for: self)
    }
    
    public var qrCodeImageSrc: String {
        return UIImage.qrCode(for: self)?.imageSrc ?? ""
    }
    
    public func qrCodeImage(with prefix:String) -> UIImage? {
        return UIImage.qrCode(for: prefix+self)
    }
    
    public func qrCodeImageSrc(with prefix:String) -> String {
        return self.qrCodeImage(with: prefix)?.imageSrc ?? ""
    }
}

public extension String {
    
    public var qrCodePayment:(publicKey:String, assets:String?, amount:String?, name:String?)? {
        
        if self.hasPrefix(Config.Shared.Payment.amount) {            
            let array = self.replacingOccurrences(of: Config.Shared.Payment.amount, with: "").components(separatedBy: ":")                            
            if array.count == 4 {
                return (array[0],array[1],array[2],array[3])
            }            
        }
        else if self.hasPrefix(Config.Shared.Payment.publicKey) {
            let pk = self.replacingOccurrences(of: Config.Shared.Payment.publicKey, with: "")
            return (pk,nil,nil,nil)
        }
        else if self.hasPrefix(Config.Shared.Wallet.publicKey) {
            let pk = self.replacingOccurrences(of: Config.Shared.Wallet.publicKey, with: "")
            return (pk,nil,nil,nil)
        }
        
        return nil
    }
    
}

public extension UIAlertController {
    
    @discardableResult
    func addAction(title: String?, style: UIAlertActionStyle = .default, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        addAction(UIAlertAction(title: title, style: style, handler: handler))
        return self
    }
    
    func present(by viewController: UIViewController) {
        viewController.present(self, animated: true)
    }
}
