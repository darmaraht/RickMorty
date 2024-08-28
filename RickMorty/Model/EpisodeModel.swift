//
//  EpisodeModel.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import Foundation

struct EpisodeModel: Codable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case airDate = "air_date"
        case episode
        case characters
        case url
        case created
    }
}
