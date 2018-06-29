//
//  Wallet.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit
import ObjectMapper
import EFQRCode 
import MileCsaLight

public struct Wallet {    
    
    public var name:String? { return _name }
    public var secretPhrase:String? { return _secretPhrase}
    public var publicKey:String? { return _publicKey }    
    public var privateKey:String? { return _privateKey }    
    
    public var nameQRImage:UIImage? { return name?.qrCodeImage(with: Config.Shared.Wallet.name) }
    public var secretPhraseQRImage:UIImage? { return secretPhrase?.qrCodeImage(with: Config.Shared.Wallet.note)}
    public var publicKeyQRImage:UIImage? { return publicKey?.qrCodeImage(with: Config.Shared.Wallet.publicKey) }    
    public var privateKeyQRImage:UIImage? { return privateKey?.qrCodeImage(with: Config.Shared.Wallet.privateKey) }    
    
    public func paymentLink(assets:String, amount:String) -> String {
        var a = (publicKey ?? "") 
        a += ":" + assets + ":" + amount + ":" + (name ?? "")
        a = Config.Shared.Payment.amount + a
        return a
    }
    
    public func amountQRImage(assets:String, amount:String) -> UIImage? {
        return UIImage.qrCode(for: paymentLink(assets: assets, amount: amount))
    }
    
    public static func create(name:String, 
                              secretPhrase:String?=nil,
                              error: @escaping ((_ error: SessionTaskError?)-> Void),  
                              complete: @escaping ((_ wallet: Wallet)->Void)) {
        do {
            var keys:MileCsaKeys
            if let phrase = secretPhrase {
                keys = try MileCsa.generateKeys(withSecretPhrase: phrase)
            }
            else {
                keys = try MileCsa.generateKeys()
            }
            complete(Wallet(name: name, publicKey: keys.publicKey, privateKey: keys.privateKey, secretPhrase: secretPhrase))
        }
        catch let err {
            error(SessionTaskError.requestError(err))
        }
    }
    
    public init(name:String, privateKey:String) throws {
        self._name = name 
        let keys = try MileCsa.generateKeys(fromPrivateKey: privateKey)
        self._publicKey = keys.publicKey
        self._privateKey = keys.privateKey
        self._secretPhrase = nil
    }  
    
    public init(name:String, publicKey:String, privateKey:String, secretPhrase:String?){
        self._name = name 
        self._publicKey = publicKey
        self._privateKey = privateKey
        self._secretPhrase = secretPhrase
    }    
    
    fileprivate var _name:String?
    fileprivate var _secretPhrase:String?
    fileprivate var _publicKey:String?  
    fileprivate var _privateKey:String?    
}

extension Wallet: Mappable {
    
    public init?(map: Map) {}
    
    public mutating func mapping(map: Map) {
        _name          <- map["wallet_name"]
        _secretPhrase  <- map["secret_phrase"]    
        _publicKey     <- map["public_key"]    
        _privateKey    <- map["private_key"]    
    }
}
