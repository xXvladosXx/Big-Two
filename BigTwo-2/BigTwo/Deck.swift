//
//  CardGame.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import Foundation

struct Deck {
    private var cards = Stack()
    
    mutating func createFullDeck() {
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func drawCard() -> Card {

        return cards.removeLast()
    }
    
    func cardsRemaining() -> Int {
        return cards.count
    }
}