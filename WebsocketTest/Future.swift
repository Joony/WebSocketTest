import Foundation

public struct Future<T> {
    
    public typealias ResultType = Result<T>
    public typealias Completion = ResultType -> ()
    public typealias AsyncOperation = Completion -> ()
    
    private let operation: AsyncOperation
    
    public init(result: ResultType) {
        self.init(operation: { completion in
            completion(result)
        })
    }
    
    public init(value: T) {
        self.init(result: .Success(value))
    }
    
    public init(error: ErrorType) {
        self.init(result: .Failure(error))
    }
    
    public init(operation: AsyncOperation) {
        self.operation = operation
    }
    
    public func run(completion: Completion) {
        self.operation() { result in
            completion(result)
        }
    }
    
    public func map<U>(f: T -> U) -> Future<U> {
        return Future<U>(operation: { completion in
            self.run { result in
                switch result {
                case let .Success(value):
                    completion(Result.Success(f(value)))
                case let .Failure(error):
                    completion(Result.Failure(error))
                }
            }
        })
    }
    
    public func flatten<U>(future: Future<Future<U>>) -> Future<U> {
        return Future<U>(operation: { completion in
            future.run { innerResult in
                switch innerResult {
                case .Success(let value):
                    value.run(completion)
                case .Failure(let error):
                    completion(Result.Failure(error))
                }
            }
        })
    }
    
    public func flatMap<U>(f: T -> Future<U>) -> Future<U> {
        return self.flatten(self.map(f))
    }
    
    public func apply<U>(f: Future<(T -> U)>) -> Future<U> {
        return f.flatMap { self.map($0) }
    }
    
}

public func pure<T>(a: T) -> Future<T> {
    return Future(value: a)
}

public func lift<T>(a: Result<T>) -> Future<T> {
    return Future(result: a)
}

public func <^> <T, U>(f: T -> U, a: Future<T>) -> Future<U> {
    return a.map(f)
}

public func >>> <T1, T2, T3>(left: T1 -> Future<T2>, right: T2 -> Future<T3>) -> (T1 -> Future<T3>) {
    return { (arg) -> Future<T3> in
        return left(arg).flatMap(right)
    }
}

// ??? Should we be doing this?
public func >>> <T1, T2, T3>(left: T1 -> Result<T2>, right: T2 -> Future<T3>) -> (T1 -> Future<T3>) {
    return { (arg) -> Future<T3> in
        return lift(left(arg)).flatMap(right)
    }
}

// ??? Should we be doing this?
public func >>> <T1, T2, T3>(left: T1 -> Future<T2>, right: T2 -> Result<T3>) -> (T1 -> Future<T3>) {
    return { (arg) -> Future<T3> in
        let wrapped = { (arg2) in
            return Future(result: right(arg2))
        }
        return left(arg).flatMap(wrapped)
    }
}

public func <*><T, U>(f: Future<(T -> U)>, a: Future<T>) -> Future<U> {
    return a.apply(f)
}

public func >>- <T, U>(a: Future<T>, f: T -> Future<U>) -> Future<U> {
    return a.flatMap(f)
}
