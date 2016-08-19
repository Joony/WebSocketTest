//
//  ChatAdapter.swift
//  WebsocketTest
//
//  Created by Jonathan McAllister on 09/08/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import Foundation

enum HTTPAdapterError: ErrorType {
    case UnableToConvertToMessages
}

class HTTPAdapter {
    
    func chat() -> Future<Messages> {
        let request = createGetRequest("https://docker.bvad.dk:8089/chat/all") >>>
            addHeaderToRequest(["Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidXNlcm5hbWUiOiJURVNUIFVTRVIiLCJpc3MiOiJTT0NLRVRTIiwiaWQiOjF9.vxHAm--PbiCBcK9yTwiaoEhlYhCK6W1-GQPdGh5G9AU"]) >>>
            performRequest >>>
            validateError >>>
            validateResponseObject >>>
            validateClientError >>>
            validateServerError >>>
            transformRESTResultDAOToData >>>
            transformDataToMessages
        
        return Queue.runFutureResultOnMainQueue(request())
    }
    
    func transformDataToMessages(data: NSData) -> Result<Messages> {
        guard let messages = try? Messages.parseFromData(data) else {
            return Result.Failure(HTTPAdapterError.UnableToConvertToMessages)
        }
        return Result.Success(messages)
    }
    
}

