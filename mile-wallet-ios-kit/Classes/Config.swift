//
//  Config.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

public struct Config {
    public static let mileHosts = ["https://wallet.mile.global", "http://localhost:4000", "https://mile-wallet.karma.red", "https://149.28.162.70:4000"]
        
    public static let api = "https://wallet.mile.global/v1"
    
    public static let publicKeyQrPrefix    = api+"/qrcode/public/key/"
    public static let privateKeyQrPrefix   = api+"/qrcode/private/key/"
    public static let noteQrPrefix         = api+"/qrcode/note/"
    public static let nameQrPrefix         = api+"/qrcode/note/name/"
    public static let secretPhraseQrPrefix = api+"/qrcode/secret/phrase/"
    public static let amountQrPrefix       = api+"/qrcode/amount/"
    public static let paymentQrPrefix      = api+"/qrcode/payment/"        
}
