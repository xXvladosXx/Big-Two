//
//  BigTwoViewModel.swift
//  BigTwo
//
//  Created by student on 15/12/2023.
//

import Foundation

class BigTwoViewModel : ObservableObject{
    @Published private var model: BigTwo = BigTwo()
    
    var players: [Player]
    {
        return model.players
    }
    
    func select(_ card: Card, in player: Player)
    {
        model.select(card, in: player)
    }
    
    func evaluateHand(_ cards: Stack) -> HandType {
        return HandType(cards)
    }
    
    func findStartingPlayer() -> Player{
        return model.findStartingPlayer()
    }
    
    func activatePlayer(_ player: Player)
    {
        model.activatePlayer(player)
    }
}
