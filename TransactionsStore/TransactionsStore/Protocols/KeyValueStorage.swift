//
//  KeyValueStorage.swift
//  TransactionsStore
//
//  Created by Dino Gacevic on 22/04/2023.
//

import Foundation

protocol KeyValueStorageProtocol {
    func getValue(forKey: String) -> String?
    mutating func removeValue(forKey: String)
    mutating func set(_ value: String, forKey: String)
    func willRemoveTransaction()
    var values: [String] { get }
}

extension KeyValueStorageProtocol {
    func willRemoveTransaction() { }
}
