//
//  MileCurrentBlockId.swift
//  Pods
//
//  Created by denn on 19/11/2018.
//

import Foundation
import JSONRPCKit
import ObjectMapper

public struct MileCurrentBlockId: JSONRPCKit.Request{
    
    public typealias Response = [String:Any]
    
    public var method: String {
        return "get-current-block-id"
    }
    
    public var parameters: Any? {
        return []
    }
    
    public func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        } else {
            throw MileCastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}
