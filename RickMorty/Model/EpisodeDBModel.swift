//
//  EpisodeDBModel.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import RealmSwift

class EpisodeDBModel: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var airDate: String
    @Persisted var episode: String
    @Persisted var characters: List<String>
    @Persisted var url: String
    @Persisted var created: String
    @Persisted var isFavorite: Bool = false
}
