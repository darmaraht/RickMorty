//
//  FavoriteSegment.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import Foundation

enum FavoriteSegment: Int, CaseIterable {
    case characters = 0
    case locations
    case episodes
    
    var title: String {
        switch self {
        case .characters: return String(localized: "characterTitle")
        case .locations: return String(localized: "locationTitle")
        case .episodes: return String(localized: "episodesTitle")
        }
        
    }
    
    var emptyMessage: String {
        switch self {
        case .characters: return "Нет избранных Персонажей"
        case .locations: return "Нет избранных Локаций"
        case .episodes: return "Нет избранных Эпизодов"
        }
    }
    
}
