import Foundation

public enum Result<T> {
    
    case Success(T)
    case Failure(ErrorType)
    
    public var successValue: T? {
        switch self {
        case let .Success(value):
            return value
        case .Failure:
            return nil
        }
    }
    
    public var failureValue: ErrorType? {
        switch self {
        case .Success:
            return nil
        case let .Failure(error):
            return error
        }
    }
    
    public func map<U>(f: T -> U) -> Result<U> {
        switch self {
        case let Success(value):
            return .Success(f(value))
        case let Failure(error):
            return .Failure(error)
        }
    }
    
    public func flatten<T>(result: Result<Result<T>>) -> Result<T> {
        switch result {
        case let .Success(box):
            switch box {
            case let .Success(nestedBox):
                return .Success(nestedBox)
            case let .Failure(error):
                return .Failure(error)
            }
        case let .Failure(error):
            return .Failure(error)
        }
    }
    
    public func flatMap<U>(f: T -> Result<U>) -> Result<U> {
        return self.flatten(self.map(f))
    }
    
    
    public func apply<U>(f: Result<(T -> U)>) -> Result<U> {
        return f.flatMap { self.map($0) }
    }
    
}

public func pure<T>(a: T) -> Result<T> {
    return Result.Success(a)
}

public func lift<T>(a: T) -> Result<T> {
    return Result.Success(a)
}

public func <^> <T, U>(f: T -> U, a: Result<T>) -> Result<U> {
    return a.map(f)
}

public func >>> <T1, T2, T3>(left: T1 -> Result<T2>, right: T2 -> Result<T3>) -> (T1 -> Result<T3>) {
    return { (arg) -> Result<T3> in
        return left(arg).flatMap(right)
    }
}

//public func >>> <T1, T2, T3>(left: T1 -> T2, right: T2 -> T3) -> (T1 -> Result<T3>) {
//    return { (arg) -> Result<T3> in
//        return lift(left(arg)).apply(lift(right))
//    }
//}

public func <*><T, U>(f: Result<(T -> U)>, a: Result<T>) -> Result<U> {
    return a.apply(f)
}

public func >>- <T, U>(a: Result<T>, f: T -> Result<U>) -> Result<U> {
    return a.flatMap(f)
}
