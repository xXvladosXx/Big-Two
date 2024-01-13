//
//  CardGame.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import Foundation

struct DiscardHand: Identifiable {
    var hand: Stack
    var handOwner: Player
    var id = UUID()
}

