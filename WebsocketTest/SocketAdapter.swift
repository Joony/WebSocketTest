//
//  SocketAdapter.swift
//  WebsocketTest
//
//  Created by Jonathan McAllister on 09/08/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import Foundation
import Starscream

enum SocketStatus {
    case Connected
    case Disconnected(error: NSError?)
}

enum SocketError: ErrorType {
    case SocketNotCreated
    case CannotCreateMessage
}

class SocketAdapter {
    
    var websocket: WebSocket?
    
    let socketStatus: Signal<SocketStatus>
    let messages: Signal<[Message_]>
    let message: Signal<Message_>
    
    init() {
        self.socketStatus = Signal(value: SocketStatus.Disconnected(error: nil))
        self.messages = Signal()
        self.message = Signal()
    }
    
    func connect() {
        self.websocket = WebSocket(url: NSURL(string: "wss://vibes.bvad.dk:8089")!)
        self.websocket!.headers["Authorization"] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwidXNlcm5hbWUiOiJURVNUIFVTRVIiLCJpc3MiOiJTT0NLRVRTIiwiaWQiOjF9.vxHAm--PbiCBcK9yTwiaoEhlYhCK6W1-GQPdGh5G9AU"
        
        self.websocket!.onConnect = {
            print("websocket is connected")
            self.socketStatus.publish(event: Result.Success(SocketStatus.Connected))
            
            let userBuilder = User.getBuilder()
            userBuilder.userid = 111
            userBuilder.username = "ARGH!"
            let user = try! userBuilder.build()
            self.websocket?.writeData(user.data())
        }
        
        self.websocket!.onDisconnect = { (error: NSError?) in
            print("websocket is disconnected: \(error?.localizedDescription)")
            self.socketStatus.publish(event: Result.Success(SocketStatus.Disconnected(error: error)))
        }
        
        self.websocket!.onData = { (data: NSData) in
            print("websocket onData")
//            if let messages = try? Messages.parseFromData(data) {
//                self.messages.publish(event: messages.messages)
//            }
            
            if let message = try? Message_.parseFromData(data) {
                self.message.publish(event: message)
            }
            
//            if let user = try? User.parseFromData(data) {
//                print(user)
//            }
            
//            if let users = try? Users.parseFromData(data) {
//                print(users)
//            }
            
//            if let room = try? Room.parseFromData(data) {
//                print(room)
//            }
            
//            if let loginResponse = try? LoginResponse.parseFromData(data) {
//                print(loginResponse)
//            }
            
            print(String(data: data, encoding: NSUTF8StringEncoding))
        }
        
        self.websocket!.connect()
    }
    
    func disconnect() {
        self.websocket?.disconnect()
        self.websocket = nil
    }
    
    func send(message message: String, userId: Int32) -> Result<Void> {
        guard let websocket = self.websocket else {
            return Result.Failure(SocketError.SocketNotCreated)
        }
        let messageBuilder = Message_.Builder()
        messageBuilder.message_ = message
        messageBuilder.userid = 111
        do {
            let messageObject = try messageBuilder.build()
            let messageData = messageObject.data()
            websocket.writeData(messageData)
        } catch {
            return Result.Failure(SocketError.CannotCreateMessage)
        }
        return Result.Success()
    }
    
}
