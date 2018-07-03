//
//  Extensions.swift
//  APIKit
//
//  Created by denis svinarchuk on 03.07.2018.
//

import Foundation

/// NSURLSession synchronous behavior
/// Particularly for playground sessions that need to run sequentially
public extension URLSession {
    
    /// Return data from synchronous URL request
    public static func requestSynchronousData(request: URLRequest) -> Data? {
        var data: Data? = nil
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            taskData, _, error -> () in
            data = taskData
            if data == nil, let error = error {print(error)}
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
        return data
    }
    
    /// Return data synchronous from specified endpoint
    public static func requestSynchronousDataWithURLString(requestString: String) -> Data? {
        guard let url = URL(string:requestString) else {return nil}
        let request = URLRequest(url: url)
        return URLSession.requestSynchronousData(request: request)
    }
    
    /// Return JSON synchronous from URL request
    public static func requestSynchronousJSON(request: URLRequest) -> AnyObject? {
        guard let data = URLSession.requestSynchronousData(request: request) else {return nil}
        return try? JSONSerialization.jsonObject(with: data, options: []) as AnyObject
    }
    
    /// Return JSON synchronous from specified endpoint
    public static func requestSynchronousJSONWithURLString(requestString: String) -> AnyObject? {
        guard let url = URL(string: requestString) else {return nil}
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return URLSession.requestSynchronousJSON(request: request)
    }
}
