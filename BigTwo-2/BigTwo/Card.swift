//
//  CardGame.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import Foundation

struct Card: Identifiable {
    var rank: Rank
    var suit: Suit
    var selected = false    
    var back: Bool = true   
    var filename: String {
        if !back {

            return "\(suit) \(rank)"
        } else {
            return "Back"
        }
        
    }

    var id = UUID()
}
