//
//  Dictionary+Extensions.swift
//  BinanceTest
//
//  Created by Dino Gacevic on 25/03/2023.
//

import Foundation

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}
