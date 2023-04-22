//
//  TransactionalKeyValueStore.swift
//  TransactionsStore
//
//  Created by Dino Gacevic on 22/04/2023.
//

import Foundation

class TransactionKeyValueStore: Transactionable {
    private var transactions: [any KeyValueStorageProtocol] = []
    
    init(storage: any KeyValueStorageProtocol) {
        self.transactions = [storage]
    }
    
    func get(key: String) -> Result<String, ActionError> {
        guard let transaction = transactions.first, let value = transaction.getValue(forKey: key) else {
            return .failure(.keyNotSet)
        }
        
        return .success(value)
    }
    
    func set(key: String, value: String) {
        guard !transactions.isEmpty else { return }
        transactions[0].set(value, forKey: key)
    }
    
    func delete(key: String) {
        guard !transactions.isEmpty else { return }
        transactions[0].removeValue(forKey: key)
    }
    
    func count(value: String) -> Int {
        guard let transaction = transactions.first else { return 0 }
        return transaction.values.filter { $0 == value}.count
    }
    
    func begin() {
        guard let transaction = transactions.first else { return }
        transactions.insert(transaction, at: 0)
    }
    
    @discardableResult func commit() -> Result<Void?, ActionError> {
        guard transactions.count > 1 else { return .failure(.noTransaction) }
        transactions[1].willRemoveTransaction()
        transactions.remove(at: 1)
        return .success(())
    }
    
    @discardableResult func rollback() -> Result<Void?, ActionError> {
        guard transactions.count > 1 else { return .failure(.noTransaction) }
        transactions[0].willRemoveTransaction()
        transactions.removeFirst()
        return .success(())
    }
}
