//
//  FunctionsOperatorsMonads.swift
//  PromiseTest
//
//  Created by Jonathan McAllister on 04/05/16.
//  Copyright © 2016 InSilico. All rights reserved.
//

import Foundation
import CoreData

public struct Queue {
    
    public static func runOnMainQueue<T>(a: T) -> Future<T> {
        return Future() { completion in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                completion(Result.Success(a))
            }
        }
    }
    
    public static func runOnQueue<T>(queue: NSOperationQueue) -> T -> Future<T> {
        return { a in
            return Future() { completion in
                queue.addOperationWithBlock {
                    completion(Result.Success(a))
                }
            }
        }
    }
    
    public static func runOnBackground<T>(a: T) -> Future<T> {
        return Future() { completion in
            let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(q) {
                completion(Result.Success(a))
            }
        }
    }
    
    public static func runOnQueueForContext<T>(context: NSManagedObjectContext) -> T -> Future<T> {
        return { a in
            return Future() { completion in
                context.performBlock {
                    completion(Result.Success(a))
                }
            }
        }
    }
    
    public static func runFutureFailureOnMainQueue<T>(future: Future<T>) -> Future<T> {
        return Future() { completion in
            future.run { innerCompletion in
                switch innerCompletion {
                case let .Success(value):
                    completion(Result.Success(value))
                case let .Failure(error):
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        completion(Result.Failure(error))
                    }
                }
            }
        }
    }
    
    public static func runFutureResultOnMainQueue<T>(future: Future<T>) -> Future<T> {
        return Future() { completion in
            future.run { innerCompletion in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    completion(innerCompletion)
                }
            }
        }
    }
    
}
