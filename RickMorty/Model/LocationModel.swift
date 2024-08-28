//
//  LocationModel.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import Foundation

struct LocationModel: Codable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [String]
    let url: String
    let created: String
}
