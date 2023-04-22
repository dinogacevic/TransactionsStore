//
//  Transactionable.swift
//  TransactionsStore
//
//  Created by Dino Gacevic on 25/03/2023.
//

import UIKit

protocol Transactionable: AnyObject {
    func get(key: String) -> Result<String, ActionError>
    func set(key: String, value: String)
    func delete(key: String)
    func count(value: String) -> Int
    func begin()
    func commit() -> Result<Void?, ActionError>
    func rollback() -> Result<Void?, ActionError>
}
