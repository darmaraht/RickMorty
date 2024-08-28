//
//  ApiCommonResponse.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import Foundation

struct ApiCommonResponse<T: Codable>: Codable {
    let info: ApiCommonResponseInfo
    let results: [T]
}

struct ApiCommonResponseInfo: Codable {
    let count: Int
    let pages: Int
    let next: URL?
    let prev: URL?
}
