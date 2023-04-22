//
//  ActionError.swift
//  TransactionsStore
//
//  Created by Dino Gacevic on 22/04/2023.
//

import Foundation

enum ActionError: String, Error {
    case keyNotSet = "key not set"
    case noTransaction = "no transactions"
    
    var description: String {
        self.rawValue
    }
}
