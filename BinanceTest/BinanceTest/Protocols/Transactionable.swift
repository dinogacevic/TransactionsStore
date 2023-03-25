//
//  Transactionable.swift
//  BinanceTest
//
//  Created by Dino Gacevic on 25/03/2023.
//

import UIKit

struct ActionError: Error {
    let description: String
}

struct GetResult {
    let value: String
}

protocol Transactionable: AnyObject {
    var transaction: [String: String] { get set }
    var tempTransactions: [[String: String]] { get set }
    var openCommit: Bool { get }
    func get(key: String) -> Result<String, ActionError>
    func set(key: String, value: String)
    func delete(key: String)
    func count(value: String) -> Int
    func begin()
    func commit()
    func rollback()
}

extension Transactionable where Self: UIViewController {
    var openCommit: Bool {
        return !tempTransactions.isEmpty
    }
    
    func get(key: String) -> Result<String, ActionError> {
        var value: String?
        
        if openCommit {
            value = tempTransactions[tempTransactions.endIndex - 1][key]
        } else {
            value = transaction[key]
        }
        
        guard let value else { return .failure(.init(description: "key not set"))}
        return .success(value)
    }
    
    func set(key: String, value: String) {
        if openCommit {
            tempTransactions[tempTransactions.endIndex - 1][key] = value
        } else {
            transaction[key] = value
        }
    }
    
    func delete(key: String) {
        if openCommit {
            tempTransactions[tempTransactions.endIndex - 1].removeValue(forKey: key)
        } else {
            transaction.removeValue(forKey: key)
        }
    }
    
    func count(value: String) -> Int {
        if openCommit, let lastTransaction = tempTransactions.last {
            return lastTransaction.allKeys(forValue: value).count
        } else {
            return transaction.allKeys(forValue: value).count
        }
    }
    
    func begin() {
        if openCommit, let newTransaction = tempTransactions.last {
            tempTransactions.append(newTransaction)
        } else {
            tempTransactions.append(transaction)
        }
    }
    
    func commit() {
        let transactionIndex = tempTransactions.endIndex - 1
        if transactionIndex > 0 {
            tempTransactions[transactionIndex - 1] = tempTransactions[transactionIndex]
        } else {
            transaction = tempTransactions[0]
        }
        
        tempTransactions.removeLast()
    }
    
    func rollback() {
        tempTransactions.removeLast()
    }
}
