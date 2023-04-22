//
//  DictionaryStore.swift
//  TransactionsStore
//
//  Created by Dino Gacevic on 22/04/2023.
//

import Foundation

struct DictionaryStore: KeyValueStorageProtocol {
    private var store: [String: String] = [:]
    
    var values: [String] {
        Array(store.values)
    }
    
    func getValue(forKey key: String) -> String? {
        store[key]
    }
    
    mutating func removeValue(forKey key: String) {
        store[key] = nil
    }
    
    mutating func set(_ value: String, forKey key: String) {
        store[key] = value
    }
}
