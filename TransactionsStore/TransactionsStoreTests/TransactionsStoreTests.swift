//
//  TransactionsStoreTests.swift
//  TransactionsStoreTests
//
//  Created by Dino Gacevic on 21/03/2023.
//

import XCTest
@testable import TransactionsStore

final class TransactionsStoreTests: XCTestCase {
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    private func randomValue() -> String {
        let randomNumber = Int.random(in: 100...999)
        return String(randomNumber)
    }

    private func randomKey() -> String {
        let randomKey = randomString(length: 5)
        let randomKeyPrefix = String(Int.random(in: 10...99))
        return randomKey+randomKeyPrefix
    }
    
    var store: TransactionKeyValueStore = TransactionKeyValueStore(storage: DictionaryStore())

    override func setUpWithError() throws {
        store = TransactionKeyValueStore(storage: DictionaryStore())
    }

    override func tearDownWithError() throws { }

    func testSetGetValueMustBeEqual() throws {
        let value = randomValue()
        let key = randomKey()
        store.set(key: key, value: value)
        let readValue = store.get(key: key)
        XCTAssertTrue(readValue == .success(value), "set and read value must be equal")
    }

    func testSetGetDeleteValueMustFail() throws {
        let value = randomValue()
        let key = randomKey()
        store.set(key: key, value: value)
        let readValue = store.get(key: key)
        XCTAssertTrue(readValue == .success(value), "set and read value must be equal")
        store.delete(key: key)
        let readDeletedValue = store.get(key: key)
        XCTAssertTrue(readDeletedValue == .failure(.keyNotSet), "get on deleted key must fail")
    }
    
    func testCountSingleValueMustBe1() throws {
        let value = randomValue()
        let key1 = randomKey()
        store.set(key: key1, value: value)
        let count1 = store.count(value: value)
        XCTAssertTrue(count1 == 1, "unique value must return count 1")
    }
    
    func testCountTwoSameValuesMustBe2() throws {
        let value = randomValue()
        let key1 = randomKey()
        let key2 = randomKey()
        store.set(key: key1, value: value)
        let count1 = store.count(value: value)
        XCTAssertTrue(count1 == 1, "unique value must return count 1")
        store.set(key: key2, value: value)
        let count2 = store.count(value: value)
        XCTAssertTrue(count2 == 2, "two same values must return count 2")
    }
    
    func testCountManySameValuesMustBeCorrect() throws {
        let numOfKeys = Int.random(in: 5...25)
        let value = randomValue()
        for _ in 1...numOfKeys {
            store.set(key: randomKey(), value: value)
        }
        let count = store.count(value: value)
        XCTAssertTrue(count == numOfKeys, "\(numOfKeys) same values must return count of \(numOfKeys)")
    }
    
    func testCountManySameValuesMixedWithUniqueValuesMustBeCorrect() throws {
        let numOfUniqueValues = Int.random(in: 5...25)
        for _ in 1...numOfUniqueValues {
            store.set(key: randomKey(), value: randomValue())
        }
        let numOfKeys = Int.random(in: 5...25)
        let value = randomValue()
        for _ in 1...numOfKeys {
            store.set(key: randomKey(), value: value)
        }
        let count = store.count(value: value)
        XCTAssertTrue(count == numOfKeys, "\(numOfKeys) same values must return count of \(numOfKeys) even when mixed with \(numOfUniqueValues) unique values")
    }
    
    func testRollbackTransactionWithoutBeginMustFail() throws {
        let result = store.rollback()
        switch result {
        case .success: XCTFail("rollback without begin must fail")
        case .failure(let error): XCTAssertTrue(error == ActionError.noTransaction, "rollback without begin should fail")
        }
    }
    
    func testCommitTransactionWithoutBeginMustFail() throws {
        let result = store.commit()
        switch result {
        case .success: XCTFail("commit without begin must fail")
        case .failure(let error): XCTAssertTrue(error == ActionError.noTransaction, "commit without begin should fail")
        }
    }
    
    func testRollbackAfterDeletingValueMustRestoreValue() throws {
         let key = randomKey()
         let value = randomValue()
         store.set(key: key, value: value)
         let readValue1 = try store.get(key: key).get()
         XCTAssertTrue(readValue1 == value, "read value must be same as set value")
         store.begin()
         store.delete(key: key)
         let readResult2 = store.get(key: key)
         XCTAssertTrue(readResult2 == .failure(.keyNotSet), "get on deleted key must fail")
         store.rollback()
         let readValue3 = try store.get(key: key).get()
         XCTAssertTrue(readValue3 == value, "read value must be same as value before transaction")
    }
    
    func testCommitAfterAddingNewValueInTransactionMustRetainValue() throws {
        let key = randomKey()
        let value = randomValue()
        let readResult1 = store.get(key: key)
        XCTAssertTrue(readResult1 == .failure(.keyNotSet), "get on non-existing key must fail")
        store.begin()
        store.set(key: key, value: value)
        let readValue2 = try store.get(key: key).get()
        XCTAssertTrue(readValue2 == value, "read value must be same as set value")
        store.commit()
        let readValue3 = try store.get(key: key).get()
        XCTAssertTrue(readValue3 == value, "read value must retained after commit")
    }
    
    func testRollbacksInNestedTransactionsShouldRestoreValue() throws {
        let key = randomKey()
        let outerLevelValue = randomValue()
        let middleLevelValue = randomValue()
        let innerLevelValue = randomValue()
        store.set(key: key, value: outerLevelValue)
        store.begin()
        store.set(key: key, value: middleLevelValue)
        store.begin()
        store.set(key: key, value: innerLevelValue)
        let readInnerValue = try store.get(key: key).get()
        XCTAssertTrue(readInnerValue == innerLevelValue, "read value must be same as set by inner level value")
        store.rollback()
        let readMiddleValue = try store.get(key: key).get()
        XCTAssertTrue(readMiddleValue == middleLevelValue, "read value must be restored to previous middle set value")
        store.rollback()
        let readOuterValue = try store.get(key: key).get()
        XCTAssertTrue(readOuterValue == outerLevelValue, "read value must be restored to previous outer set value")
    }
    
    func testCommitsInNestedTransactionsShouldRetainValue() throws {
        let key = randomKey()
        let outerLevelValue = randomValue()
        let middleLevelValue = randomValue()
        let innerLevelValue = randomValue()
        store.set(key: key, value: outerLevelValue)
        store.begin()
        store.set(key: key, value: middleLevelValue)
        store.begin()
        store.set(key: key, value: innerLevelValue)
        let readInnerValue = try store.get(key: key).get()
        XCTAssertTrue(readInnerValue == innerLevelValue, "read value must be same as set by inner level value")
        store.commit()
        let readMiddleValue = try store.get(key: key).get()
        XCTAssertTrue(readMiddleValue == innerLevelValue, "read value must be retained to inner level value")
        store.commit()
        let readOuterValue = try store.get(key: key).get()
        XCTAssertTrue(readOuterValue == innerLevelValue, "read value must be retained to inner level value")
    }
}
