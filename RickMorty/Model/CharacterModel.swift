//
//  CharacterModel.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import Foundation

struct CharacterModel: Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: AdditionalObject
    let location: AdditionalObject
    let image: String
    let episode: [String]
    let url: String
    let created: String

}

struct AdditionalObject: Codable {
    let name: String
    let url: String
}
