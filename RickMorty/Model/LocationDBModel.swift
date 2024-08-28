//
//  LocationDBModel.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import RealmSwift

class LocationDBModel: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var type: String
    @Persisted var dimension: String
    @Persisted var residents: List<String>
    @Persisted var url: String
    @Persisted var created: String
    @Persisted var isFavorite: Bool = false
}
