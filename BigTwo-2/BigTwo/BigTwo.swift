//
//  CardGame.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import Foundation


struct BigTwo {
    private(set) var discardedHands = [DiscardHand]()
    private(set) var players: [Player]

    init() {
        let opponents = [
            Player(playerName: "Player 1"),
            Player(playerName: "Player 2"),
            Player(playerName: "Player 3")
        ]
        
        players = opponents
        players.append(Player(playerName: "You", playerIsMe: true))
        
        var deck = Deck()
        deck.createFullDeck()
        deck.shuffle()
        
        let randomStartingPlayerIndex = Int(arc4random()) % players.count

        while deck.cardsRemaining() > 0 {
            for p in randomStartingPlayerIndex...randomStartingPlayerIndex + (players.count - 1) {
                let i = p % players.count 
                var card = deck.drawCard()
                if players[i].playerIsMe {
                    card.back = false
                }
                players[i].cards.append(card)
            }
        }
    }    

    mutating func select(_ cards: Stack, in player: Player) {
        for i in 0 ... cards.count - 1 {
            let card = cards[i]
            if let cardIndex = player.cards.firstIndex(where: { $0.id == card.id }) {
                if let playerIndex = players.firstIndex(where: { $0.id == player.id }) {

                    players[playerIndex].cards[cardIndex].selected.toggle()
                }
            }
        }
    }


    mutating func playSelectedCard(of player: Player) {
        if let playerIndex = players.firstIndex(where: { $0.id == player.id }) { 
            var playerHand = players[playerIndex].cards.filter{ $0.selected == true } 
            let remainingCards = players[playerIndex].cards.filter { $0.selected == false } 
            print("Actual player:", player.playerName)
            print("Liczba zagranych kart:", playerHand.count)
            
            for i in 0 ... playerHand.count-1 {
                playerHand[i].back = false
            }
            discardedHands.append(DiscardHand(hand: playerHand, handOwner: player))
            players[playerIndex].cards = remainingCards
        }
    }
    

    mutating func getNextPlayerFromCurrent() -> Player {
        var nextActivePlayer = Player()

        if let activePlayerIndex = players.firstIndex(where: { $0.activePlayer == true }) {
            let nextPlayerIndex = ((activePlayerIndex + 1) % players.count)
            nextActivePlayer = players[nextPlayerIndex]

            players[activePlayerIndex].activePlayer = false
        }

        return nextActivePlayer
    }

    
    mutating func activatePlayer(_ player: Player) {
        if let playerIndex = players.firstIndex(where: { $0.id == player.id }) {
            players[playerIndex].activePlayer = true

        }
    }
    

    func findStartingPlayer() -> Player {
        var startingPlayer: Player!
        for aPlayer in players {
            if aPlayer.cards.contains(where: { $0.rank == .Three && $0.suit == .Club}) {
                startingPlayer = aPlayer
            }
        }
        return startingPlayer
    }
    

    func getCPUHand(of player: Player) -> Stack {

        var pairExist = false, threeExist = false, fourExist = false, fullHouseExist = false, straightExist = false, flushExist = false
        
        
        var rankCount = [Rank : Int]()
        var suitCount = [Suit : Int]()
        
        let playerCardsByRank = player.cards.sortByRank()
        
       
        for card in playerCardsByRank {
            if rankCount[card.rank] != nil {
                rankCount[card.rank]! += 1
            } else {
                rankCount[card.rank] = 1
            }
            
            if suitCount[card.suit] != nil {
                suitCount[card.suit]! += 1
            } else {
                suitCount[card.suit] = 1
            }
        }
        
        
        var cardsRankCount1 = 1
        var cardsRankCount2 = 1
        
        for rank in Rank.allCases {
            var thisRankCount = 0
            
            
            if rankCount[rank] != nil {
                thisRankCount = rankCount[rank]!
            } else {
                continue
            }
            
           
            if thisRankCount > cardsRankCount1 {
                if cardsRankCount1 != 1 {
                   
                    cardsRankCount2 = cardsRankCount1
                }
                cardsRankCount1 = thisRankCount
            } else if thisRankCount > cardsRankCount2 {
                cardsRankCount2 = thisRankCount
            }
            
            
            pairExist = cardsRankCount1 > 1 
            threeExist = cardsRankCount1 > 2 
            fourExist = cardsRankCount1 > 3 
            fullHouseExist = cardsRankCount1 > 2 && cardsRankCount2 > 1 
            
            if straightExist {
                continue 
            } else {
                straightExist = true
            }
            
            for i in 0 ... 4 {
                var rankRawValue = 1
                
                if rank <= Rank.Ten { 
                    rankRawValue = rank.rawValue + i
                } else if rank >= Rank.Ace {
                    
                    rankRawValue = (rank.rawValue + i) % 13
                   
                    if rankRawValue == 0 {
                        rankRawValue = 13
                    }
                }
                
                if rankCount[Rank(rawValue: rankRawValue)!] != nil {
                    
                    straightExist = straightExist && rankCount[Rank(rawValue: rankRawValue)!]! > 0
                } else {
                    straightExist = false
                }
            }
            
            
            for suit in Suit.allCases {
                var thisSuitCount = 0
                
                if suitCount[suit] != nil {
                    thisSuitCount = suitCount[suit]!
                }
                flushExist = thisSuitCount > 5
            }
        }
        
        // Singles
        var validHands = combinations(player.cards, k: 1)
        
        // Pairs
        if pairExist {
            var possibleCombination = Stack()
            for card in playerCardsByRank {
                if rankCount[card.rank]! > 1 {
                    possibleCombination.append(card)
                }
            }
            let possibleHands = combinations(possibleCombination, k: 2)
            for i in 0 ..< possibleHands.count {
                if HandType(possibleHands[i]) != .Invalid {
                    validHands.append(possibleHands[i])
                }
            }
        }
        
        // Three of A Kind
        if threeExist {
            var possibleCombination = Stack()
            for card in playerCardsByRank {
                if rankCount[card.rank]! > 2 {
                    possibleCombination.append(card)
                }
            }
            let possibleHands = combinations(possibleCombination, k: 3)

            for i in 0 ..< possibleHands.count { //fix 11/8
                if HandType(possibleHands[i]) != .Invalid {
                    validHands.append(possibleHands[i])
                }
            }
        }
        

        if fourExist || flushExist || straightExist || fullHouseExist {
            var possibleCombination = Stack()
            for card in playerCardsByRank {
                if (fullHouseExist && rankCount[card.rank]! > 1) ||
                    (fourExist && rankCount[card.rank]! > 3) ||
                    (flushExist && suitCount[card.suit]! > 4) ||
                    straightExist {
                    possibleCombination.append(card)
                }
            }
            let possibleHands = combinations(possibleCombination, k: 5)
            for i in 0 ..< possibleHands.count {
                if HandType(possibleHands[i]) != .Invalid {
                    validHands.append(possibleHands[i])
                }
            }
        }
        
        var sortedHandsByScore = sortHandsByScore(validHands) 
        var returnHand = Stack()
 
        for hand in sortedHandsByScore {
            if playable(hand, of: player) {
                returnHand = hand
            }
        }

        return returnHand
    }
    
    func playable(_ hand: Stack, of player: Player) -> Bool {
        var playable = false

        if let lastDiscardHand = discardedHands.last {
            if (handScore(hand) > handScore(lastDiscardHand.hand) &&
                hand.count == lastDiscardHand.hand.count) ||
                (player.id == lastDiscardHand.handOwner.id) {
                playable = true
            }
        } else {
            if hand.contains(where: { $0.rank == Rank.Three && $0.suit == Suit.Club }) {
                playable = true
            }
        }
        return playable
    }
    
   
    func sortHandsByScore(_ unsortedHands: [Stack]) -> [Stack] {
        var sortedHands = [Stack]()
        var remainingHands = unsortedHands
        
        for _ in 1 ... unsortedHands.count {
            var highestHandIndex = 0
            for i in 0 ... unsortedHands.count {
                if (i + 1) < remainingHands.count {
                    if handScore(remainingHands[i + 1]) > handScore(remainingHands[highestHandIndex]) {
                        highestHandIndex = i + 1
                    }
                }
            }
            sortedHands.append(remainingHands[highestHandIndex])
            remainingHands.remove(at: highestHandIndex)
        }
        return sortedHands
    }
    

    func handScore(_ hand: Stack) -> Int {
        var score = 0

        for i in 0...hand.count - 1 {
            let suitScore = hand[i].suit.rawValue

            if HandType(hand) == .Straight {
                if i < 2 && hand[i].rank == .Ace {
                    score += 1111 + suitScore
                }
            } else {
                if hand[i].rank == .Two { 
                    score += 5555 + suitScore
                } else {
                    score += ((hand[i].rank.rawValue + 3) * 100) + suitScore
                }
            }

            score += (11111 * HandType(hand).rawValue)
        }
        return score
    }
    

    func combinations(_ cardArray: Stack, k: Int) -> [Stack] {
        var sub = [Stack]()
        var ret = [Stack]()
        var next = Stack()
        
        for i in 0 ..< cardArray.count {
            if k == 1 { 
                var tempHand = Stack() 
                tempHand.append(cardArray[i]) 
                ret.append(tempHand) 
            } else { 
              
                sub = combinations(sliceArray(cardArray, x1: i+1, x2: cardArray.count - 1), k: k-1)
                
                for subI in 0 ..< sub.count {
                    next = sub[subI]
                    next.append(cardArray[i])
                    ret.append(next)
                }
            }
        }

        return ret
    }
    

    func sliceArray(_ cardArray: Stack, x1: Int, x2: Int) -> Stack {
        var sliced = Stack()
        
        if x1 <= x2 { 
            for i in x1 ... x2 {
                sliced.append(cardArray[i])
            }
        }
        return sliced
    }
    
}

