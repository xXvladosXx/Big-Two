//
//  CardGame.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import Foundation

enum HandType: Int {
    case Invalid=0, Single, Pair, ThreeOfAKind, Straight, Flush, FullHouse, FourOfAKind, StraightFlush, RoyalFlush
    
    init(_ cards: Stack) {
        var returnType: Self = .Invalid
        
        if cards.count == 1 {
            returnType = .Single
        }
        
        if cards.count == 2 {
            if cards[0].rank == cards[1].rank {
                returnType = .Pair
            }
        }
        
        if cards.count == 3 {
            if cards[0].rank == cards[1].rank && 
            cards[0].rank == cards[2].rank {
                returnType = .ThreeOfAKind
            }
        }
        

        if cards.count == 5 {

            let sortedHand = cards.sortByRank()


            if (sortedHand[1].rank == sortedHand[2].rank && sortedHand[2].rank == sortedHand[3].rank && (sortedHand[0].rank == sortedHand[3].rank || sortedHand[3].rank == sortedHand[4].rank)) {
                returnType = .FourOfAKind
            }
            

            if sortedHand[0].rank == sortedHand[1].rank && sortedHand[3].rank == sortedHand[4].rank && (sortedHand[1].rank == sortedHand[2].rank || sortedHand[2].rank == sortedHand[3].rank) {
                returnType = .FullHouse
            }
            
            var isStraight = true
            var isFlush = true
            

            
            for (i, _) in sortedHand.enumerated() {
                if i + 1 < 5 {

                    if i == 0 && sortedHand[0].rank == .Ace {
                        if ((sortedHand[i].rank.rawValue % 13) - (sortedHand[i + 1].rank.rawValue % 13)) != 1 &&
                            ((sortedHand[i + 1].rank.rawValue % 12) - (sortedHand[i].rank.rawValue % 12)) != 3 {
                            isStraight = false
                        }
                    } else {
                        if ((sortedHand[i].rank.rawValue % 13) - (sortedHand[i + 1].rank.rawValue % 13)) != 1 {
                            isStraight = false
                        }
                    }
                    if sortedHand[i].suit != sortedHand[i + 1].suit {
                        isFlush = false
                    }
                }
            }
            if isStraight {
                returnType = .Straight
            }
            
            if isFlush {
                returnType = .Flush
            }
            
            if isStraight && isFlush {
                returnType = .StraightFlush
            }
            
            if isStraight && sortedHand[4].rank == .Ten {
                returnType = .RoyalFlush
            }
        }
        
        self = returnType
    }
}
