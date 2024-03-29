//
//  MileTransferAsset.swift
//  MileWallet
//
//  Created by denis svinarchuk on 08.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import JSONRPCKit
import ObjectMapper

public struct MileTransferAsset: JSONRPCKit.Request{
    
    public typealias Response = Bool
    
    public var data: Any
    
    public var method: String {
        return "send-transaction"
    }
    
    public var parameters: Any? {
        return data
    }
    
    public func response(from resultObject: Any) throws -> Response {
        if let response = Response("\(resultObject)") {
            return response
        } else {
            throw MileCastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

