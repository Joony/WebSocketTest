//
//  HTTPPromiseDAO.swift
//  PromiseTest
//
//  Created by Jonathan McAllister on 02/05/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import UIKit

enum RESTResource: String {
    case Root = ""
}

enum RESTDAOError: ErrorType {
    case Error(ErrorType)
    case InvalidResource
    case NoResponse
    case Transformation(ErrorType)
    case TransformationUnableToCast
    case ClientError(statusCode: Int, data: NSData?)
    case ServerError(Int)
    case NoData
    case NoInternet
    case HostnameNotFound
    case RequestTimedOut
}

public enum RESTMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

public struct RESTResultDTO {
    let data: NSData?
    let response: NSHTTPURLResponse?
    let error: NSError?
    init(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) {
        self.data = data
        self.response = response
        self.error = error
    }
}

// MARK: - Requests

// MARK: GET

/**
 Create a GET request.
 
 - parameter resource: A URL string.
 
 - returns: A Result containing a new NSURLRequest.
 */
public func createGetRequest(resource: String) -> Void -> Result<NSURLRequest> {
    return  createRequest(resource) >>> addMethodToRequest(.GET)
}
public func createGetRequest(resource: String) -> Result<NSURLRequest> {
    return  (createRequest >>> addMethodToRequest(.GET))(resource)
}
public func createGetRequest(url: NSURL) -> Void -> Result<NSURLRequest> {
    return  createRequest(url) >>> addMethodToRequest(.GET)
}

// MARK: POST

/**
 Create a POST request.
 
 - parameter resource: A URL string.
 
 - returns: A Result containing a new NSURLRequest.
 */
public func createPostRequest(resource: String) -> Void -> Result<NSURLRequest> {
    return createRequest(resource) >>> addMethodToRequest(.POST)
}
public func createPostRequest(resource: String) -> Result<NSURLRequest> {
    return (createRequest >>> addMethodToRequest(.POST))(resource)
}
public func createPostRequest(url: NSURL) -> Void -> Result<NSURLRequest> {
    return createRequest(url) >>> addMethodToRequest(.POST)
}

// MARK: PUT

/**
 Create a PUT request.
 
 - parameter resource: A URL string.
 
 - returns: A Result containing a new NSURLRequest.
 */
public func createPutRequest(resource: String) -> Void -> Result<NSURLRequest> {
    return createRequest(resource) >>> addMethodToRequest(.PUT)
}
public func createPutRequest(resource: String) -> Result<NSURLRequest> {
    return (createRequest >>> addMethodToRequest(.PUT))(resource)
}
public func createPutRequest(url: NSURL) -> Void -> Result<NSURLRequest> {
    return createRequest(url) >>> addMethodToRequest(.PUT)
}

// MARK: PATCH

/**
 Create a PATCH request.
 
 - parameter resource: A URL string.
 
 - returns: A Result containing a new NSURLRequest.
 */
public func createPatchRequest(resource: String) -> Void -> Result<NSURLRequest> {
    return createRequest(resource) >>> addMethodToRequest(.PATCH)
}
public func createPatchRequest(resource: String) -> Result<NSURLRequest> {
    return (createRequest >>> addMethodToRequest(.PATCH))(resource)
}
public func createPatchRequest(url: NSURL) -> Void -> Result<NSURLRequest> {
    return createRequest(url) >>> addMethodToRequest(.PATCH)
}

// MARK: DELETE

/**
 Create a DELETE request.
 
 - parameter resource: A URL string.
 
 - returns: A Result containing a new NSURLRequest.
 */
public func createDeleteRequest(resource: String) -> Void -> Result<NSURLRequest> {
    return createRequest(resource) >>> addMethodToRequest(.DELETE)
}
public func createDeleteRequest(resource: String) -> Result<NSURLRequest> {
    return (createRequest >>> addMethodToRequest(.DELETE))(resource)
}
public func createDeleteRequest(url: NSURL) -> Void -> Result<NSURLRequest> {
    return createRequest(url) >>> addMethodToRequest(.DELETE)
}

// MARK: - Raw request

/**
 Create a new default NSURLRequest.
 
 - parameter resource: A URL string.
 
 - returns: A Result with a new NSURLRequest, or RESTDAOError.InvalidResource
 */
public func createRequest(resource: String) -> Void -> Result<NSURLRequest> {
    return {
        guard let url = NSURL(string: resource) else {
            return Result.Failure(RESTDAOError.InvalidResource)
        }
        let urlRequest = NSMutableURLRequest(URL: url)
        return Result.Success(urlRequest)
    }
}
public func createRequest(resource: String) -> Result<NSURLRequest> {
    guard let url = NSURL(string: resource) else {
        return Result.Failure(RESTDAOError.InvalidResource)
    }
    let urlRequest = NSMutableURLRequest(URL: url)
    return Result.Success(urlRequest)
}
public func createRequest(url: NSURL) -> Void -> Result<NSURLRequest> {
    return {
        let urlRequest = NSMutableURLRequest(URL: url)
        return Result.Success(urlRequest)
    }
}

// MARK: Method

/**
 Add an HTTP Method to an NSURLRequest.  Only REST methods are supported.
 
 - parameter method: A RESTMethod.
 
 - returns: A Result with a new NSURLRequest.
 */
public func addMethodToRequest(method: RESTMethod) -> NSURLRequest -> Result<NSURLRequest> {
    return { request in
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        mutableRequest.HTTPMethod = method.rawValue
        return Result.Success(mutableRequest)
    }
}

// MARK: Query

/**
 Add query parameters to the url of an NSURLRequest.
 
 - parameter query: The query parameters to add.
 
 - returns: A Result with a new NSURLRequest.
 */
public func addQueryToRequest(query: [String: String]) -> NSURLRequest -> Result<NSURLRequest> {
    return { request in
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        
        let queryItems = query.map { (key, value) -> NSURLQueryItem in
            let queryItem = NSURLQueryItem(name: key, value: value)
            return queryItem
        }
        let urlComponents = NSURLComponents(URL: mutableRequest.URL!, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = urlComponents.queryItems != nil ? urlComponents.queryItems! + queryItems : queryItems
        mutableRequest.URL = urlComponents.URL
        
        return Result.Success(mutableRequest)
    }
}

// MARK: Body

/**
 Add a body to an NSURLRequest.
 
 - parameter body: The raw NSData to add as the body.
 
 - returns: A Result with a new NSURLRequest.
 */
public func addBodyToRequest(body: NSData) -> NSURLRequest -> Result<NSURLRequest> {
    return { request in
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        mutableRequest.HTTPBody = body
        return Result.Success(mutableRequest)
    }
}

// MARK: Header

/**
 Add HTTP headers to an NSURLRequest.
 
 - parameter headerFields: A dictionary containing the headers to add.
 
 - returns: A Result with a new NSURLRequest.
 */
public func addHeaderToRequest(headerFields: [String: String]) -> NSURLRequest -> Result<NSURLRequest> {
    return { request in
        let mutableRequest = request.mutableCopy() as! NSMutableURLRequest
        headerFields.forEach( { mutableRequest.setValue($0.1, forHTTPHeaderField: $0.0) } )
        return Result.Success(mutableRequest)
    }
}

// MARK: - Task

/**
 Perform a network request.
 
 - parameter session: An NSURLSession. Defaults to sharedSession.
 
 - returns: A Future that can be used to "run" the request.
 */
public func performRequest(session: NSURLSession = NSURLSession.sharedSession()) -> NSURLRequest -> Future<RESTResultDTO> {
    return { request in
        return Future() { completion in
            let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
                let resultDTO = RESTResultDTO(data: data, response: response as? NSHTTPURLResponse, error: error)
                completion(Result.Success(resultDTO))
            }
            task.resume()
        }
    }
}

public func loadImage(url: NSURL) -> Future<UIImage> {
    let request = createGetRequest(url) >>>
        performRequest >>>
        validateError >>>
        validateResponseObject >>>
        validateClientError >>>
        validateServerError >>>
        transformRESTResultDAOToData >>>
        transformDataToImage
    return Queue.runFutureResultOnMainQueue(request())
}

/**
 Perform a network request using the default shared session.
 
 - parameter request: An NSURLRequest.
 
 - returns: A Future that can be used to "run" the request.
 */
public func performRequest(request: NSURLRequest) -> Future<RESTResultDTO> {
    return performRequest()(request)
}


// MARK: - Transformers

func transformRESTResultDAOToData(result: RESTResultDTO) -> Result<NSData> {
    guard let data = result.data else {
        return Result.Failure(RESTDAOError.NoData)
    }
    return Result.Success(data)
}

public func transformDataToImage(data: NSData) -> Result<UIImage> {
    guard let image = UIImage(data: data) else {
        return Result.Failure(RESTDAOError.TransformationUnableToCast)
    }
    return Result.Success(image)
}

// MARK: - Validators

func validateError(result: RESTResultDTO) -> Result<RESTResultDTO> {
    guard result.error == nil else {
        if result.error?.code == -1009 {
            return Result.Failure(RESTDAOError.NoInternet)
        }
        if result.error?.code == -1003 {
            return Result.Failure(RESTDAOError.HostnameNotFound)
        }
        if result.error?.code == -1001 {
            return Result.Failure(RESTDAOError.RequestTimedOut)
        }
        return Result.Failure(RESTDAOError.Error(result.error!))
    }
    return Result.Success(result)
}

func validateResponseObject(result: RESTResultDTO) -> Result<RESTResultDTO> {
    guard result.response != nil else {
        return Result.Failure(RESTDAOError.NoResponse)
    }
    return Result.Success(result)
}

func validateClientError(result: RESTResultDTO) -> Result<RESTResultDTO> {
    guard !(400...499 ~= result.response!.statusCode) else {
        return Result.Failure(RESTDAOError.ClientError(statusCode: result.response!.statusCode, data: result.data))
    }
    return Result.Success(result)
}

func validateServerError(result: RESTResultDTO) -> Result<RESTResultDTO> {
    guard !(500...599 ~= result.response!.statusCode) else {
        return Result.Failure(RESTDAOError.ServerError(result.response!.statusCode))
    }
    return Result.Success(result)
}
