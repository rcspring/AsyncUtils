//
//  AnyAsyncSequence.swift
//  AsyncUtils
//
//  Created by Ryan Spring on 10/9/26.
//

import Foundation

public struct AnyAsyncSequence<Element, Failure: Error>: AsyncSequence {
    public struct AnyAsyncIterator: AsyncIteratorProtocol<Element, Failure> {
        var internalIterator: any AsyncIteratorProtocol<Element, Failure>
        
        public mutating func next(isolation actor: isolated (any Actor)?) async throws(Failure) -> Element? {
            try await internalIterator.next(isolation: actor)
        }
    }
    
    let sequence: any AsyncSequence<Element, Failure>
    
    init(sequence: any AsyncSequence<Element, Failure>) {
        self.sequence = sequence
    }
    
    public func makeAsyncIterator() -> AnyAsyncIterator {
        AsyncIterator(internalIterator: sequence.makeAsyncIterator())
    }
}

extension AsyncSequence {
    public func eraseToAnySequence() -> AnyAsyncSequence<Element, Failure> {
        AnyAsyncSequence(sequence: self)
    }
}
