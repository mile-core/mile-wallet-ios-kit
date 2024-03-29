//
//  Chain.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit
import ObjectMapper

public enum Asset {
    
    case xdr
    case mile
    
    public init?(name:String) {
        switch name {
        case Asset.mile.name:
            self = Asset.mile
        case Asset.xdr.name:
            self = Asset.xdr
        default:
            return nil
        }
    }
    
    public var name:String {
        switch self {
        case .mile:
            return "MILE"
        case .xdr:
            return "XDR"
        }
    }
    
    public var code:UInt16 {
        switch self {
        case .mile:
            return 1
        case .xdr:
            return 0
        }
    }
    
    public var precision:Int {
        switch self {
        case .mile:
            return 5
        case .xdr:
            return 2
        }
    }
    
    public static var list:[Asset] = [.mile, .xdr]
    
    public func stringValue(_ balance:Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = precision
        formatter.minimumFractionDigits = precision
        return formatter.string(from: NSNumber(value: balance)) ?? "-"
    }
}

public struct Chain {
    
    public enum ChainError: Error{
        case versionWrong
        case assetNotFound
        case transactionTypeNotFount
    }
    
    public static var shared:Chain? { return _shared}

    public var version:String { return _version }
    public var transactions:[String] { return _transactions}
    public var assets:[String:String] { return _assets }
        
    public init(version:String, transactions:[String], assets:[String:String]){
        self._version = version
        self._transactions = transactions
        self._assets = assets
    }
    
    public func assetCode(of name: String) -> UInt16? {
        if let index = assets.index(where: { return $1 == name }) {
            return UInt16(assets[index].key)
        }        
        return nil
    }
    
    public func asset(name:String) -> Asset? {
        switch name {
        case "MILE":
            return Asset.mile
        case "XDR":
            return Asset.xdr
        default:
            return nil
        }
    }
    
    public static func update(error: @escaping ((_ error: Error?)-> Void),  
                       complete: @escaping ((_ chain: Chain)->Void)) {
        
        if let chain = Chain._shared {
            complete(chain)                
            return
        }
        
        let batchFactory = BatchFactory(version: "2.0", idGenerator: NumberIdGenerator())
        
        let request = MileInfo()
        
        let batch = batchFactory.create(request)
        let httpRequest = Rpc(batch: batch)
        
        Session.send(httpRequest) { (result) in
            switch result {
                
            case .success(let response):
                                                                
                guard let assets = response["supported-assets"] as? NSArray else {
                    Chain._shared = nil
                    error(ResponseError.unexpectedObject(response))
                    return
                }
                
                var newAssets:[String:String] = [:]
                for a in assets {
                    if let o = a as? NSDictionary, 
                        let code = o["code"], 
                        let name = o["name"]{
                        newAssets["\(code)"] = "\(name)"                        
                                                
                    }
                } 
                
                guard let v = response["version"] as? String else  {
                    Chain._shared = nil
                    error(ResponseError.unexpectedObject(response))
                    return                     
                } 
                
                guard let trx = response["supported-transaction-types"] as? NSArray as? Array<String> else {
                    Chain._shared = nil
                    error(ResponseError.unexpectedObject(response))
                    return                     
                }                                                             
                
                Chain._shared = Chain(version: v, 
                                transactions: trx, 
                                assets: newAssets)
                
                complete(Chain._shared!)                
                
            case .failure(let er):  
                Chain._shared = nil
                error(er)
            }
        }     
    }    
    
    fileprivate var _version:String = "1"
    fileprivate var _transactions:[String] = []
    fileprivate var _assets:[String:String] = [:]
    
    private static var _shared:Chain?
}

extension Chain:Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        _version <- map["version"]
        _transactions <- map["transactions"]
        _assets <- map["assets"]
    }        
}

