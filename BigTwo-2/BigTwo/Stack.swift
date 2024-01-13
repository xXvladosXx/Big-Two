//
//  CardGame.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import Foundation

typealias Stack = [Card]

extension Stack where Element == Card {
    func sortByRank() -> Self {
        var sortedHand = Stack()
        var remainingCards = self
        
        for _ in 1 ... remainingCards.count {
            var highestCardIndex = 0 
            for (i, _) in remainingCards.enumerated() { 
                if i + 1 < remainingCards.count { 
                    if remainingCards[i + 1].rank >
                        remainingCards[highestCardIndex].rank ||
                        (remainingCards[i + 1].rank == remainingCards[highestCardIndex].rank &&
                         remainingCards[i + 1].suit > remainingCards[highestCardIndex].suit) {
                            highestCardIndex = i + 1
                        }
                }
            }

            let highestCard = remainingCards.remove(at: highestCardIndex)
            sortedHand.append(highestCard)
        }

        return sortedHand
    }
}
