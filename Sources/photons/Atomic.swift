import Foundation

public final class Atomic<Value> {

    /// Thread safe wrapped value
    private var _value: Value

    /// An internal `Concurrent` dispatch queue that to access the value.
    private let mutex = DispatchQueue(label: "Atomic Concurrent Queue - Daylight/joel-meng/com.github",
                                      attributes: .concurrent)

    // MARK: - Lifecycle

    public init(_ value: Value) {
        self._value = value
    }

    // MARK: - Accessors

    /// A getter for accessing the value.
    public var value: Value {
        mutex.sync {
            _value
        }
    }

    /// A mutating setter function for value which keeps value updating `Thread-Safe`
    /// - Parameter transform: An closure which used to update the actual value in a atomic transaction.
    public func value<T>(_ transform: (inout Value) throws -> T) rethrows -> T {
        try mutex.sync(flags: .barrier) {
            try transform(&_value)
        }
    }
}
