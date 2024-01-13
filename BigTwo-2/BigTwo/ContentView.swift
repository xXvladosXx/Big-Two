//
//  ContentView.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: BigTwoViewModel
	
	var body: some View {
		VStack {
            ForEach(viewModel.players) { player in
				if(!player.playerIsMe) {
					LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: -67)])
					{
						ForEach(player.cards)
						{
							card in CardView(cardName: card.filename).onTapGesture
							{
								//flip(card, in: player)
							}
						}
					}
					.frame(width: 500, height: 110)
					.scaleEffect(0.75)
				}
			}
			
            ZStack{
                Rectangle()
                    .foregroundColor(.yellow)
                
                let hand = viewModel.players[3].cards.filter { $0.selected == true }
                let handStr = "\(viewModel.evaluateHand(hand))"
                Text(handStr).font(.title)
            }
			
			
			LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: -76)])
			{
                ForEach(viewModel.players[3].cards)
				{
					card in CardView(cardName: card.filename).onTapGesture
					{
                        viewModel.select(card, in: viewModel.players[3])
					}
                    .offset(y: card.selected ? -30 : 0)
				}
			}
		}
        .onAppear()
        {
            print("On Appear")
            let playerWithLowCard = viewModel.findStartingPlayer()
            viewModel.activatePlayer(playerWithLowCard)
            print(playerWithLowCard.playername)
        }
    }
}

struct CardView : View {
		var cardName: String
		var body: some View {
			Image(cardName)
				.resizable()
				.scaledToFit()
		}
}
