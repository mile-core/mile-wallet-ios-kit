//
//  MileServiceRequest.swift
//  MileWallet
//
//  Created by denis svinarchuk on 07.06.2018.
//  Copyright © 2018 Karma.red. All rights reserved.
//

import Foundation
import APIKit
import JSONRPCKit

public struct MileServiceRequest<Batch: JSONRPCKit.Batch>: APIKit.Request {
    public let batch: Batch
    
    public typealias Response = Batch.Responses
    
    public var baseURL: URL {
        return URL(string: Config.mileHosts[0])!
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var path: String {
        return "/v1/api"
    }
    
    public var parameters: Any? {
        return batch.requestObject
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try batch.responses(from: object)
    }
}
