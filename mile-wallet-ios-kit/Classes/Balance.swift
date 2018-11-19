//
//  Balance.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit
import ObjectMapper

public struct Balance {
    
    //private var balance:[UInt16:String] { return _balance }
    
    public var available_assets:[UInt16] {
        return _balance.keys.compactMap{return $0}
    }
    
    public func amount(_ asset_code:UInt16) -> Float? {
        if let idx = _balance.index(where: { (k,v) -> Bool in
            return k == asset_code
        }) {
            return _balance[idx].value.floatValue
        }
        return nil
    }
    
    public init(balance:[UInt16:String]){
        self._balance = balance
    }
    
    public static func update(wallet: Wallet, error: @escaping ((_ error: Error?)-> Void),  
                              complete: @escaping ((_: Balance)->Void)) {
        
        let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
        
        guard let pk = wallet.publicKey else {
            error(NSError(domain: "global.mile.wallet",
                          code: 0,
                          userInfo: [NSLocalizedDescriptionKey:
                            NSLocalizedString("Public key is not valid", comment: "")]))
            return
        }
        
        let request = MileWalletState(publicKey: pk)
            
        let batch = batchFactory.create(request)
        let httpRequest = Rpc(batch: batch)
        
        Session.send(httpRequest) { (result) in
            
            switch result {
                
            case .success(let response):
                                
                guard let bal = response["balance"] as? NSArray as? Array<AnyObject?> else {
                    //error(NSError(domain: "global.mile.wallet",
                    //              code: 0,
                    //              userInfo: [NSLocalizedDescriptionKey:
                    //                NSLocalizedString("Balance getting error. Check network connection", comment: "")]))
                    complete(Balance(balance: [:]))
                    return
                }
            
                var balance:[UInt16:String] = [:]
                
                for b in bal {
                    if let o = b as? NSDictionary, 
                        let amount = o["amount"],
                        let code_as_string = o["code"],
                        let code = UInt16("\(code_as_string)") {
                        balance[code] = "\(amount)"
                    }
                }
                
                complete(Balance(balance: balance))                     
                
            case .failure(let er):
                
                Swift.print("balance error: >>> \(error)")
                error(er)
            }
        }     
    }    
    
    fileprivate var _balance:[UInt16:String] = [:]    
}

extension Balance:Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        _balance <- map["balance"]
    }        
}

