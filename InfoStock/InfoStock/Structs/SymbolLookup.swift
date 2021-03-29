//
//  SymbolLookup.swift
//  InfoStock
//
//  Created by Кирилл Любарских  on 28.03.2021.
//

import Foundation

struct SymbolLookup: Decodable {
    let count: Int
    let result: [result]
}

struct result: Decodable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
