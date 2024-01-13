//
//  BigTwoViewModel.swift
//  BigTwo
//
//  Created by student on 15/12/2023.
//

import Foundation

class BigTwoViewModel : ObservableObject{
    @Published private var model = BigTwo()
    
    @Published private(set) var activePlayer = Player()
    @Published private(set) var gameOver = false
    
    static let shared = BigTwoGame()

    @Published var gameID = UUID()
    
    var players: [Player] {
        return model.players
    }
    
    var discardedHands: [DiscardHand] {
        return model.discardedHands
    }
    
    func select(_ cards: Stack, in player: Player) {
        model.select(cards, in: player)
    }
    
    func evaluateHand(_ cards: Stack) -> HandType {
        return HandType(cards)
    }
    
    func getNextPlayer() -> Player {
        model.getNextPlayerFromCurrent()
    }
    
    func activatePlayer(_ player: Player) {
        model.activatePlayer(player)
        if let activePlayerIndex = players.firstIndex(where: { $0.activePlayer == true }) {
            print("change")
            activePlayer = players[activePlayerIndex]
        }
    }
    
    func findStartingPlayer() -> Player {
        return model.findStartingPlayer()
    }
    
    func getCPUHand(of player: Player) -> Stack {
        return model.getCPUHand(of: player)
    }
    
    func playSelectedCard(of player: Player) {
        model.playSelectedCard(of: player)
        if let activePlayerIndex = players.firstIndex(where: { $0.activePlayer == true }) {
            gameOver = players[activePlayerIndex].cards.count == 0
        }
    }
    
    func playable(_ hand: Stack, of player: Player) -> Bool {
        return model.playable(hand, of: player)
    }
}
