//
//  Config.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import UIKit

public struct Config {
   
    public static let version            = "1"
    public static let appSchema          = "mile-core:"
    public static var url                = "https://wallet.mile.global"
    public static var api:String         { return url }
    public static var baseUrlPath:String { return api + "/v" + version }
    public static var nodesUrl:String    { return url + "/v" + version + "/nodes.json"}
    public static var useBalancing:Bool  = true
    
    public struct Shared {
        public static let path = "shared"
        
        public struct Wallet {
            public static var publicKey:String    { return baseUrlPath+"/" + Shared.path + "/wallet/key/public/" }
            public static var privateKey:String   { return baseUrlPath+"/" + Shared.path + "/wallet/key/private/" }
            public static var note:String         { return baseUrlPath+"/" + Shared.path + "/wallet/note/" }
            public static var name:String         { return baseUrlPath+"/" + Shared.path + "/wallet/note/name/" }
            public static var secretPhrase:String { return baseUrlPath+"/" + Shared.path + "/wallet/secret/phrase/" }
            public static var amount:String       { return baseUrlPath+"/" + Shared.path + "/wallet/amount/"}
        }
        
        public struct Payment {
            public static var publicKey:String   { return baseUrlPath+"/" + Shared.path + "/payment/key/public/" }
            public static var amount:String      { return baseUrlPath+"/" + Shared.path + "/payment/amount/" }
        }
    }
}
