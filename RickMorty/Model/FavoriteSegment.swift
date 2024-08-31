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
        case .characters: return "Нет избранных Персонажей нажмите перейти чтоб добавить"
        case .locations: return "Нет избранных Локаций нажмите перейти чтоб добавить"
        case .episodes: return "Нет избранных Эпизодов нажмите перейти чтоб добавить"
        }
    }
    
}
