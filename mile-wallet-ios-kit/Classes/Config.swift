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
        
    public static let api         = "https://wallet.mile.global"    
    public static let version     = "1"
    public static let baseUrlPath = api + "/v" + version 
    public static let appSchema   = "mile-core:"
    
    public struct Shared {
        public static let path = "shared"
        
        public struct Wallet {
            public static let publicKey    = baseUrlPath+"/" + Shared.path + "/wallet/key/public/"
            public static let privateKey   = baseUrlPath+"/" + Shared.path + "/wallet/key/private/"
            public static let note         = baseUrlPath+"/" + Shared.path + "/wallet/note/"
            public static let name         = baseUrlPath+"/" + Shared.path + "/wallet/note/name/"
            public static let secretPhrase = baseUrlPath+"/" + Shared.path + "/wallet/secret/phrase/"
            public static let amount       = baseUrlPath+"/" + Shared.path + "/wallet/amount/"
        }
        
        public struct Payment {
            public static let publicKey   = baseUrlPath+"/" + Shared.path + "/payment/key/public/"                        
            public static let amount      = baseUrlPath+"/" + Shared.path + "/payment/amount/"                        
        }
    }
}
