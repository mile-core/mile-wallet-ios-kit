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

public struct Rpc<Batch: JSONRPCKit.Batch>: APIKit.Request {
    public let batch: Batch
    
    public typealias Response = Batch.Responses
    
    public var baseURL: URL {  
        return  SharedRpc.default.url
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


public class SharedRpc {    
    
    static let `default` = SharedRpc()
    
    public var nodes:[URL] {
        return _urls
    }
        
    public var url:URL {
        guard Config.useBalancing else {
            return _baseUrl
        }
        let url   = nodes[SharedRpc._current_url_index%nodes.count]
        SharedRpc._current_url_index += 1
        return url
    }
    
    private init(){
        if let data = (URLSession.requestSynchronousJSONWithURLString(requestString: Config.nodesUrl) as? NSArray) as? [String] {
            for u in data {
                guard let url = URL(string: u) else {continue}
                _urls.append(url)
            }
        }
        if _urls.count == 0 {
            _urls.append(URL(string: Config.api)!)
        }
    }
    
    private let _baseUrl = URL(fileURLWithPath: Config.baseUrlPath + "/api")
    private var _urls:[URL] = []  
    private static var _current_url_index = 0    
}
