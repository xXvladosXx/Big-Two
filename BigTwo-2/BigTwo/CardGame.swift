//
//  CardGame.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import Foundation

enum Suit: Int, CaseIterable{
	case Club = 1, Spade, Heart, Diamond
}

enum Rank: Int, CaseIterable, Comparable{
	case Three = 1, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Ace, Two
    
    static func <(lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

enum HandType{
    case Invalid, Single, Pair, ThreadOfAKind, Straight, Flush, FullHouse, FourOfAKind, StraightFlush, RoyalFlush
    
    init(_ cards: Stack)
    {
        var returnType: Self = .Invalid
       
        
        if cards.count == 1 {
            returnType = .Single
        }
        
        if cards.count == 2 {
            if cards[0].rank == cards[1].rank{
                returnType = .Pair
            }
        }
        
        if cards.count == 3 {
            if cards[0].rank == cards[1].rank
            && cards[0].rank == cards[2].rank{
                returnType = .ThreadOfAKind
            }
        }
        
        if cards.count == 6 {
            let sortedHand = cards.sortByRank()
            
            if (sortedHand[1].rank == sortedHand[2].rank && sortedHand[2].rank == sortedHand[3].rank &&
                (sortedHand[0].rank == sortedHand[3].rank || sortedHand[3].rank == sortedHand[4].rank))
            {
                returnType = .FourOfAKind
            }
            
            if (sortedHand[0].rank == sortedHand[1].rank && sortedHand[3].rank == sortedHand[4].rank &&
                (sortedHand[1].rank == sortedHand[2].rank || sortedHand[2].rank == sortedHand[3].rank))
            {
                returnType = .FullHouse
            }
            
            var isStraight = true
            var isFlush = true
            
            for (i, _) in sortedHand.enumerated(){
                if i + 1 < 5 {
                    if i == 0 && sortedHand[0].rank == .Ace {
                        if ((sortedHand[i].rank.rawValue % 13) - (sortedHand[i + 1].rank.rawValue % 13)) != 1 &&
                            ((sortedHand[i + 1].rank.rawValue % 12) - (sortedHand[i].rank.rawValue % 12)) != 3{
                            isStraight = false
                        }
                    }else{
                        if((sortedHand[i].rank.rawValue % 13) - (sortedHand[i+1].rank.rawValue % 13)) != 1 {
                            isStraight = false
                        }
                    }
                    
                    if sortedHand[i].suit != sortedHand[i+1].suit
                    {
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
            
            if isFlush && isStraight {
                returnType = .StraightFlush
            }
            
            if isStraight && sortedHand[4].rank == .Ten
            {
                returnType = .RoyalFlush
            }
        }
        
        self = returnType
    }
}

typealias Stack = [Card]

extension Stack where Element == Card {
    func sortByRank() -> Self{
        var sortedHand = Stack()
        var remainedCards = self
        
        for _ in 1...remainedCards.count {
            var highestCardIndex = 0
            for (i, _) in remainedCards.enumerated() {
                if i + 1 < remainedCards.count{
                    if remainedCards[i + 1].rank > remainedCards[highestCardIndex].rank ||
                        (remainedCards[i + 1].rank == remainedCards[highestCardIndex].rank &&
                         remainedCards[i + 1].suit.rawValue > remainedCards[highestCardIndex].suit.rawValue)
                    {
                        highestCardIndex = i
                    }
                }
                
                if highestCardIndex >= remainedCards.count{
                    return sortedHand
                }
                
                let highestCard = remainedCards.remove(at: highestCardIndex)
                sortedHand.append(highestCard)
            }
        }
        
        return sortedHand
    }
}

struct BigTwo{
	var deck = Deck()
	private(set) var players:[Player]
    private var activePlayer: Player {
        var player = Player()
        
        if let activePlayerIndex = players.firstIndex(where: {$0.activePlayer == true}){
            player = players[activePlayerIndex]
        }else{
            if let humanIndex = players.firstIndex(where: { $0.playerIsMe == true})
            {
                player = players[humanIndex]
            }
        }
            
        return player
    }
	
	init() {
		let opponents = [
			Player(playername: "AI 1"),
			Player(playername: "AI 2"),
			Player(playername: "AI 3")
		]
		 
		players = opponents
		players.append(Player(playername: "Me", playerIsMe: true))
		
		deck.createFullDeck()
		deck.shuggle()
        
        let randomStartingPlayerIndex = Int(arc4random()) % players.count
        
        while deck.cardsRemaining() > 0 {
            for p in randomStartingPlayerIndex...randomStartingPlayerIndex + (players.count - 1)
            {
                let i = p % players.count
                let card = deck.drawCard()
                players[i].cards.append(card)
            }
        }
	}
    
    mutating func select(_ card: Card, in player: Player)
    {
        if let cardIndex = player.cards.firstIndex(where: {$0 == card})
        {
            if let playerIndex = players.firstIndex(where: {$0 == player})
            {
                players[playerIndex].cards[cardIndex].selected.toggle()
            }
        }
    }
    
    mutating func activatePlayer(_ player: Player)
    {
        if let playerIndex = players.firstIndex(where: { $0.id == player.id}) {
            players[playerIndex].activePlayer = true
            
            if !activePlayer.playerIsMe {
                let cpuHand = getCPUHand(of: activePlayer)
            }
        }
    }
    
    func findStartingPlayer() -> Player{
        var startingPlayer: Player!
        
        for aPlayer in players {
            if aPlayer.cards.contains(where: { $0.rank == .Three && $0.suit == .Club})
            {
                startingPlayer = aPlayer
            }
        }
        
        return startingPlayer
    }
    
    func getCPUHand(of player: Player) -> Stack {
        var rankCount = [Rank : Int] ()
        var suitCount = [Suit : Int] ()
        
        let playerCardsByRank = player.cards.sortByRank()
        
        for card in playerCardsByRank {
            if rankCount[card.rank] != nil {
                rankCount[card.rank]! += 1
            }else {
                rankCount[card.rank] = 1
            }
            
            if suitCount[card.suit] != nil {
                suitCount[card.suit]! += 1
            }else {
                suitCount[card.suit] = 1
            }
        }
        
        var returnHand = Stack()
        return returnHand
    }
}

struct Card : Identifiable, Equatable{
	var rank: Rank
	var suit: Suit
	var selected: Bool = false
	var filename: String {
		get {
            return "\(suit) \(rank)"
			if selected {
				
			} else {
				return "Back"
			}
		}
	}
	
	var id = UUID()
}
	
struct Player : Identifiable, Equatable {
	var cards = Stack()
    var playername = ""
    var activePlayer = false
	var id = UUID()
	var playerIsMe: Bool = false
}

struct Deck {
	var cards:[Card] = []
	
	mutating func createFullDeck(){
		for suit in Suit.allCases {
			for rank in Rank.allCases {
				cards.append(Card(rank: rank, suit: suit))
			}
		}
	}
	
	mutating func shuggle()
	{
		cards.shuffle()
	}
    
    func cardsRemaining() -> Int {
        return cards.count
    }
    
    mutating func drawCard() -> Card{
        return cards.removeLast()
    }
}


var testData = [
	Card(rank: .Ace, suit: .Heart),
	Card(rank: .King, suit: .Heart),
	Card(rank: .Queen, suit: .Heart),
	Card(rank: .Jack, suit: .Heart),
	Card(rank: .Ten, suit: .Heart),
	Card(rank: .Nine, suit: .Heart),
	Card(rank: .Eight, suit: .Heart),
	Card(rank: .Seven, suit: .Heart),
	Card(rank: .Six, suit: .Heart),
	Card(rank: .Five, suit: .Heart),
	Card(rank: .Four, suit: .Heart),
	Card(rank: .Three, suit: .Heart),
	Card(rank: .Two, suit: .Heart)
]

var testPlayers = [
	Player(),
	Player(),
	Player(),
	Player(playerIsMe: true),
]
