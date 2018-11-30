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
    
    public var transactionData:[String:Any]? { return _transactionData }
    public var result:Bool { return _result }        
    
    public static func send(asset: String, 
                            amount: Float,
                            from: Wallet,
                            to: Wallet,
                            error: @escaping ((_ error: Error?)-> Void),  
                            complete: @escaping ((_: Transfer)->Void)) {
        
        guard let from_key = from.publicKey else { return }
        guard let to_key = to.publicKey else { return }
        guard let from_private_key = from.privateKey else { return }
        
        
        Chain.update(error: { (err) in
            error(err)
        }) { (chain) in
            if let assetValue = Asset(name: asset) {
                sendAmount(asset: assetValue.code)
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
                    
                    guard let trx_id_obj = response["preferred-transaction-id"] else {
                        error(ResponseError.unexpectedObject(response))
                        return
                    }
                    
                    guard var trx_id = Int("\(trx_id_obj)") else {
                        error(ResponseError.unexpectedObject(trx_id_obj))
                        return                    
                    }
                    
                    if let lastId = Transfer.getLastId(from_key) {
                        
                        if lastId >= trx_id && trx_id > 0 {
                            //
                            // last transaction is in progress
                            //
                            trx_id = lastId + 1
                        }
                    }
                    let request = MileCurrentBlockId()
                    
                    let batch = batchFactory.create(request)
                    let httpRequest = Rpc(batch: batch)
                    
                    Session.send(httpRequest) { (result) in
                        switch result {
                        case .success(let response):
                                                        
                            guard let block_id = response["current-block-id"] else {
                                error(ResponseError.unexpectedObject(response))
                                return
                            }
                            
                            do {
                                
                                try send_transfer(
                                    asset_code: assetValue,
                                    amount: amount,
                                    from: from_private_key,
                                    to: to_key,
                                    block_id: "\(block_id)",
                                    trx_id: trx_id, error: error, complete: complete)
                            }
                            catch let err {
                                error(err)
                            }
                            
                        case .failure(let er):
                            error(er)
                        }
                    }
                    
                case .failure(let er):                
                    error(er)
                }
            }    
        }
    }
    
    fileprivate static func send_transfer(asset_code: UInt16,
                                          amount: Float,
                                          from: String,
                                          to: String,
                                          block_id: String,
                                          trx_id: Int,
                                          error: @escaping ((_ error: Error?)-> Void),
                                          complete: @escaping ((_: Transfer)->Void)) throws {
        
        let pair = try MileCsaKeys.fromPrivateKey(from);
        
        let _data = try MileCsaTransaction.transfer(pair,
                                                   destPublicKey: to,
                                                   blockId: block_id,
                                                   transactionId: UInt64(trx_id),
                                                   assetCode: asset_code,
                                                   amount: amount,
                                                   fee: 0,
                                                   description: nil);
        
        guard let data = _data as? [String:Any] else {
            error(JSONRPCError(errorObject: _data))
            return
        }
        
        let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
        
        let request = MileTransferAsset(data: data)
        
        let batch = batchFactory.create(request)
        let httpRequest = Rpc(batch: batch)
        
        Session.send(httpRequest) { (result) in
            switch result {
                
            case .success(let response):
                
                Transfer.setLastId(pair.publicKey, id: trx_id)
                complete(Transfer(_transactionData: data, _result: response))
                
            case .failure(let er):
                error(er)
            }
        }
    }
    
    
    fileprivate static func getLastId(_ key:String) -> Int? {
        return UserDefaults.standard.integer(forKey:key+":preferred-transaction-id"+Config.baseUrlPath)
    }
    
    fileprivate static func setLastId(_ key:String, id:Int) {
        UserDefaults.standard.set(id, forKey: key+":preferred-transaction-id:"+Config.baseUrlPath)
        UserDefaults.standard.synchronize()
    }
    
    fileprivate var _transactionData:[String:Any]?
    fileprivate var _result:Bool = false      
}

extension Transfer :Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        _transactionData <- map["transaction_data"]
        _result <- map["result"]
    }        
}

