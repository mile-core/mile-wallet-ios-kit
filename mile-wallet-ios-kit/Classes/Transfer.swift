//
//  Transfer.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit
import ObjectMapper
import MileCsaLight

public struct Transfer {
    
    public var transactionData:String? { return _transactionData }    
    public var result:Bool { return _result }        
    
    public static func send(asset: String, 
                            amount: String, 
                            from: Wallet, to: Wallet, 
                            error: @escaping ((_ error: Error?)-> Void),  
                            complete: @escaping ((_: Transfer)->Void)) {
        
        guard let from_key = from.publicKey else { return }
        guard let to_key = to.publicKey else { return }
        guard let from_private_key = from.privateKey else { return }
                        
        
        Chain.update(error: { (err) in
            error(err)
        }) { (chain) in
            if let assetValue = chain.assetCode(of: asset) {
                sendAmount(asset: assetValue)
            }
            else {
                error(Chain.ChainError.assetNotFound)
            }
        }     
        
        func sendAmount(asset assetValue: UInt16) {
            
            let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
            
            let request = MileWalletState(publicKey: from_key)
            
            let batch = batchFactory.create(request)
            let httpRequest = Rpc(batch: batch)
            
            Session.send(httpRequest) { (result) in
                switch result {                
                case .success(let response):
                    
                    
                    guard let trxIdObj = response["last_transaction_id"] else {
                        error(ResponseError.unexpectedObject(response))
                        return
                    }
                    
                    guard var trxId = Int("\(trxIdObj)") else {
                        error(ResponseError.unexpectedObject(trxIdObj))
                        return                    
                    }
                    
                    if let lastId = self.idCache[from_key] {
                        if lastId == trxId {
                            //
                            // last transaction is in progress
                            //
                            trxId += 1                            
                        }
                    }
                    
                    do {
                                                
                        let data = try MileCsa.createTransfer(MileCsaKeys(from_key, 
                                                                          privateKey: from_private_key), 
                                                              destPublicKey: to_key, 
                                                              transactionId: "\(trxId)", 
                            assets: assetValue, 
                            amount: "\(amount.floatValue)")
                                                                        
                        let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
                        
                        let request = MileTransferAsset(transaction_data: data)
                                                
                        let batch = batchFactory.create(request)
                        let httpRequest = Rpc(batch: batch)
                        
                        Session.send(httpRequest) { (result) in
                            switch result {    
                                
                            case .success(let response):
                                
                                self.idCache[from_key] = trxId
                                
                                complete(Transfer(_transactionData: data, _result: response))                     
                                
                            case .failure(let er):                
                                error(er)
                            }
                        }  
                    }
                    catch let err {
                        Swift.print(" MileTransferAsset: error.... \(err.localizedDescription)")
                        error(err)
                    }
                case .failure(let er):                
                    error(er)
                }
            }    
        }
    }
    
    private static var idCache:[String:Int] = [:]
    
    fileprivate var _transactionData:String?      
    fileprivate var _result:Bool = false      
}

extension Transfer :Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        _transactionData <- map["transaction_data"]
        _result <- map["result"]
    }        
}

