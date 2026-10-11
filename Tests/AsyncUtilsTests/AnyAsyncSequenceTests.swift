//
//  AnyAsyncSequenceTests.swift
//  AsyncUtils
//
//  Created by Ryan Spring on 10/11/26.
//

import AsyncUtils
import Foundation
import Testing

enum AsyncSequenceTestError: Error {
    case requestedError
}

@Suite
struct AnyAsyncSequenceTests {
   @Test
    func TestValueEmitterCompletes() async throws {
        let sut = ValueEmitter(delay: 1, items: Array(1...10))
        
        try await test(sut: sut)
        
    }
    
    @Test
    func TestAnyAsyncSequenceCompletesSlow() async throws {
        let sut = ValueEmitter(delay: 1, items: Array(1...10))
            .eraseToAnySequence()
        
        try await test(sut: sut)
    }
    
    @Test
    func TestAnyAsyncSequenceCompletesFast() async throws {
        let sut = ValueEmitter(delay: 0.0001, items: Array(1...10))
            .eraseToAnySequence()
        
        try await test(sut: sut)
    }
    
    @Test
    func TestValueEmitterThrowsSlow() async throws {
        let sut = ValueEmitter(delay: 1, items: Array(1...10), throwAt: 5)
        
        await #expect(throws: AsyncSequenceTestError.requestedError) {
            try await test(sut: sut)
        }
    }
    
    @Test
    func TestValueEmitterThrowsFast() async throws {
        let sut = ValueEmitter(delay: 0.0001, items: Array(1...10), throwAt: 5)
        
        await #expect(throws: AsyncSequenceTestError.requestedError) {
            try await test(sut: sut)
        }
    }
    
    
    func test<SUT: AsyncSequence>(sut: SUT) async throws where SUT.Element == Int {
        var lastValue: Int?
        
        for try await value in sut {
            if let lastValue = lastValue {
                #expect(lastValue + 1 == value, "Last Value should increase by 1 monotonically.")
            }
            lastValue = value
        }
        
        #expect(true, "Sequence Completed")
    }
}
