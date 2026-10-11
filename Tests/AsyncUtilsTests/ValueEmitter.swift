//
//  ValueEmitter.swift
//  AsyncUtils
//
//  Created by Ryan Spring on 10/11/26.
//

import Foundation

struct ValueEmitter<Value: Sendable & Equatable> {
    let stream: AsyncThrowingStream<Value, Error >
    
    init(delay: Double, items: [Value], throwAt: Value? = nil) {
        self.stream = AsyncThrowingStream<Value, Error> { continuation in
            let task = Task {
                for item in items {
                    if let throwAt = throwAt,item == throwAt {
                        continuation.finish(throwing: AsyncSequenceTestError.requestedError)
                    }
                    
                    continuation.yield(item)
                    try await Task.sleep(for: .seconds(delay))
                }
                continuation.finish()
            }
            
            
            continuation.onTermination = { termination in
                switch termination {
                case .cancelled: task.cancel()
                case .finished(_): break
                @unknown default: break
                }
            }
        }
    }
}

extension ValueEmitter: AsyncSequence {
    func makeAsyncIterator() -> AsyncThrowingStream<Value, Error>.AsyncIterator {
        stream.makeAsyncIterator()
    }
}
