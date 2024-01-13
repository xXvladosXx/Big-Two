//
//  CardGame.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import Foundation

struct Player: Identifiable, Equatable {
    var cards = Stack()
    var playerName = ""
    var playerIsMe = false
    var activePlayer = false
    var id = UUID()
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}