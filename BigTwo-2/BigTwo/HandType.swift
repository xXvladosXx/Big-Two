//
//  CardGame.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import Foundation

enum Rank: Int, CaseIterable, Comparable {
    case Three=1, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Ace, Two
    
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
