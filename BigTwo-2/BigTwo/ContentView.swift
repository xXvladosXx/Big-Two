//
//  ContentView.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bigTwo = BigTwoViewModel()
    
    @State private var counter = 0
    
    @State private var buttonText = "Pass"
    @State private var disablePlayButton = false
    @State private var disableResetButton = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var dealt = Set<UUID>()
    @State private var discard = Set<UUID>() 
    
    private func deal(_ card: Card) {
        dealt.insert(card.id) 
    }
    
    private func discard(_ card: Card) {
        dealt.remove(card.id) 
        discard.insert(card.id)
    }
    
    private func dealt(_ card: Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private func discarded(_ card: Card) -> Bool {
        discard.contains(card.id)
    }
    

    private func dealAnimation(for card: Card, in player: Player) -> Animation {
        var delay = 0.0
        if let index = player.cards.firstIndex(where: { $0.id == card.id }) {

            delay = Double(index) * (3 / Double(player.cards.count))
        }
        return Animation.easeInOut(duration: 0.5).delay(delay)
    }
    
    @Namespace private var dealingNamespace
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Background").resizable().edgesIgnoringSafeArea(.all)

                VStack {
                    ForEach(bigTwo.players) { player in
                        if !player.playerIsMe {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 75), spacing: -50)]) {
                                ForEach(player.cards) { card in

                                    if dealt(card) || discarded(card) {
                                        CardView(card: card)
                                            .matchedGeometryEffect(id: card.id, in: dealingNamespace)

                                    }
                                }
                            }

                            .frame(height: geo.size.height / 7)

                            .opacity(player.activePlayer ? 1 : 0.4)
                            .onAppear {
                                for card in player.cards {
                                    withAnimation(dealAnimation(for: card, in: player)) { 
                                        deal(card)
                                    }
                                }
                            }
                        }
                    }
                    
                
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                        deckBody
                        VStack {
                            ZStack { 
                                ForEach(bigTwo.discardedHands) { discardHand in
                                    
                                    let i = bigTwo.discardedHands.firstIndex(where: { $0.id == discardHand.id })
                                    let lastDiscardHand: Bool = (i == bigTwo.discardedHands.count - 1)
                                    let prevDiscardHand: Bool = (i == bigTwo.discardedHands.count - 2)
                                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(100), spacing: -30), count: discardHand.hand.count)) {
                                        ForEach(discardHand.hand) { card in
                                            if discarded(card) {
                                                CardView(card: card)
                                                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                                            }
                                        }
                                    }
                                   
                                    .scaleEffect(lastDiscardHand ? 0.80 : 0.65)
                                    
                                    .opacity(lastDiscardHand ? 1 : prevDiscardHand ? 0.4 : 0)
                                    .offset(y: lastDiscardHand ? 0 : -40)
                                }
                                
                            }
                           
                            let lastIndex = bigTwo.discardedHands.count - 1
                            if lastIndex >= 0 {
                               
                                let playerName = bigTwo.discardedHands[lastIndex].handOwner.playerName
                               
                                let playerHand = bigTwo.discardedHands[lastIndex].hand
                               
                                let handType = "\(bigTwo.evaluateHand(playerHand))"
                                
                               
                                if bigTwo.gameOver {
                                    Text("Game Over! \(playerName) wins!")
                                        .font(.largeTitle)
                                        .foregroundColor(.yellow)
                                } else {

                                    Text("\(playerName): \(handType)")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                  
                        .onChange(of: bigTwo.gameOver) { _ in
                            timer.upstream.connect().cancel()
                        }
                    }
                    
                
                    let myPlayer = bigTwo.players[3]
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: -76)]) {
                        ForEach(myPlayer.cards) { card in
                            if dealt(card) || discarded(card) {
                                CardView(card: card)
                            
                                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                         
                                    .offset(y: card.selected ? -30 : 0)
                                    .onTapGesture {
                                 
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            bigTwo.select([card], in: myPlayer)
    
                                        }
                                    
                                        let selectedCards = bigTwo.players[3].cards.filter { $0.selected == true }
                                        if selectedCards.count > 0 { 
                                            buttonText = "Play" 
                                            if bigTwo.playable(selectedCards, of: myPlayer) {
                                                disablePlayButton = false /
                                            } else {
                                                disablePlayButton = true
                                            }
                                        } else { 
                                            buttonText = "Pass"
                                            disablePlayButton = false
                                        }
                                    }
                            }
                        }
                    }
                    .onAppear { 
                        for card in myPlayer.cards {
                            withAnimation(dealAnimation(for: card, in: myPlayer)) {
                                deal(card)
                            }
                        }
                    }

                    HStack {
                        Spacer()
             
                        Button(buttonText) { 
                
                            counter = 0
                           
                            let selectedCards = myPlayer.cards.filter { $0.selected == true }
                            if selectedCards.count > 0 { 
                                for card in selectedCards {
                                    withAnimation(.easeInOut) { 
                                        discard(card) 
                                    }
                                }
                                bigTwo.playSelectedCard(of: myPlayer)
                            }
                        }
                        .disabled(myPlayer.activePlayer ? disablePlayButton : true)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        
                        Spacer()
                        
                        Button("New Game") {
                            BigTwoGame.shared.gameID = UUID()
                        }
                        .disabled(bigTwo.gameOver ? disableResetButton : true)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        
                        Spacer()
                    }
                }
                
                
            }
       
            .onChange(of: bigTwo.activePlayer) { player in
             
                if !player.playerIsMe {
                
                    let cpuHand = bigTwo.getCPUHand(of: player)
                    if cpuHand.count > 0 { 
                        bigTwo.select(cpuHand, in: player)
                        for card in cpuHand {
                            withAnimation(.easeInOut) { 
                                discard(card) 
                            }
                        }
                        bigTwo.playSelectedCard(of: player) 
                    }
                }
            }
     
            .onReceive(timer) { time in
                var nextPlayer = Player()
                print(counter)
                counter += 1
                if counter >= 2 {
            
                    if bigTwo.discardedHands.count == 0 {
                        nextPlayer = bigTwo.findStartingPlayer()
                    } else { 
                        nextPlayer = bigTwo.getNextPlayer()
                    }
                    bigTwo.activatePlayer(nextPlayer)
                  
                    if nextPlayer.playerIsMe {
                        counter = -100
                        buttonText = "Pass"
                    } else {
                        counter = 0
                    }
                }
            }
            .onAppear { 
                counter = -3
            }
        }
    }
    

    var deckBody: some View {
        ZStack {
            ForEach(bigTwo.players) { player in
                ForEach(player.cards.filter{ !dealt($0) }) { card in
                    CardView(card: card)
                        .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                        .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .opacity))
                 
                }
            }
        }
        .frame(width: 60, height: 90)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct CardView: View {
    let card: Card
    var body: some View {
        Image(card.filename)
            .resizable()
            .aspectRatio(2/3, contentMode: .fit)
    }
}