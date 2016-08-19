//
//  JSONRESTDAO.swift
//  PromiseTest
//
//  Created by Jonathan McAllister on 02/05/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import Foundation


/**
 Conveniently create a JSON GET request.
 
 - parameter resource: A URL string.
 
 - returns: A Request containing a new NSURLRequest.
 */
public func createJSONGetRequest(resource: String) -> Void -> Result<NSURLRequest> {
    return createGetRequest(resource) >>> addJSONHeaderToRequest
}
public func createJSONGetRequest(resource: String) -> Result<NSURLRequest> {
    return (createGetRequest >>> addJSONHeaderToRequest)(resource)
}

/**
 Conveniently create a JSON POST request.
 
 - parameter resource: A URL string.
 
 - returns: A Request containing a new NSURLRequest.
 */
public func createJSONPostRequest(resource: String) -> Void -> Result<NSURLRequest> {
    return createPostRequest(resource) >>> addJSONHeaderToRequest
}
public func createJSONPostRequest(resource: String) -> Result<NSURLRequest> {
    return (createPostRequest >>> addJSONHeaderToRequest)(resource)
}

/**
 Conveniently create a JSON PUT request.
 
 - parameter resource: A URL string.
 
 - returns: A Request containing a new NSURLRequest.
 */
public func createJSONPutRequest(resource: String) -> Void -> Result<NSURLRequest> {
    return createPutRequest(resource) >>> addJSONHeaderToRequest
}
public func createJSONPutRequest(resource: String) -> Result<NSURLRequest> {
    return (createPutRequest >>> addJSONHeaderToRequest)(resource)
}

/**
 Adds JSON Content-Type and Accept headers to an NSURLRequest.
 
 - returns: A Result containing a new NSURLRequest.
 */
public func addJSONHeaderToRequest(request: NSURLRequest) -> Result<NSURLRequest> {
    return addHeaderToRequest(["Content-Type": "application/json", "Accept": "application/json"])(request)
}


/**
 Add JSON as the body of an NSURLRequest.
 
 - parameter body: A collection of data to convert to JSON.
 
 - returns: A Result containing a new NSURLRequest or Result.Failure(error) containing an error that occured during JSON deserialization.
 */
public func addJSONBodyToRequest(body: [[String: AnyObject]]) -> NSURLRequest -> Result<NSURLRequest> {
    return { request in
        let data = try! NSJSONSerialization.dataWithJSONObject(body, options: [])
        return addBodyToRequest(data)(request)
    }
}
public func addJSONBodyToRequest(body: [String: AnyObject]) -> NSURLRequest -> Result<NSURLRequest> {
    return { request in
        let data = try! NSJSONSerialization.dataWithJSONObject(body, options: [])
        return addBodyToRequest(data)(request)
    }
}

// MARK: - Transformations

//    var transformToJSONArray: (result: RESTResultDTO) -> Result<[[String: AnyObject]]> {
//        return transformRESTResultDAOToData >>> self.transformDataToJSONArray
//    }

/**
 Convert NSData (of a JSON Array of Dictionaries) to a native collection.
 
 - parameter data: NSData containing the raw JSON.
 
 - returns: A result containing a raw collection or one of two errors: RESTDAOError.TransformationUnableToCast, or RESTDAOError.Error(error) containing an error that occured during JSON deserialization.
 */
func transformDataToJSONArray(data: NSData) -> Result<[[String: AnyObject]]> {
    do {
        if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String: AnyObject]] {
            return Result.Success(jsonArray)
        }
    } catch let error {
        return Result.Failure(RESTDAOError.Error(error))
    }
    return Result.Failure(RESTDAOError.TransformationUnableToCast)
}

func transformDataToJSONDictionary(data: NSData) -> Result<[String: AnyObject]> {
    do {
        if let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
            return Result.Success(jsonDictionary)
        }
    } catch let error {
        return Result.Failure(RESTDAOError.Error(error))
    }
    return Result.Failure(RESTDAOError.TransformationUnableToCast)
}
