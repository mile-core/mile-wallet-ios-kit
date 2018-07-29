//
//  Config.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

public struct Config {
   
    public static var url         = "https://wallet.mile.global"
    public static var api:String {return url}
    public static let version     = "1"
    public static let baseUrlPath = api + "/v" + version 
    public static let appSchema   = "mile-core:"
    public static let nodesUrl    = url + "/v"+version+"/nodes.json"

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
