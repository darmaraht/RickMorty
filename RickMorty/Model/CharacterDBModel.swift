//
//  CharacterDBModel.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import RealmSwift

class CharacterDBModel: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var status: String
    @Persisted var species: String
    @Persisted var type: String
    @Persisted var gender: String
    @Persisted var image: String
    @Persisted var episode: List<String>
    @Persisted var url: String
    @Persisted var created: String
    @Persisted var originName: String = ""
    @Persisted var originURL: String = ""
    @Persisted var locationName: String = ""
    @Persisted var locationURL: String = ""
    @Persisted var isFavorite: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension CharacterModel {
    func toRealmModel() -> CharacterDBModel {
        let realmModel = CharacterDBModel()
        realmModel.id = id
        realmModel.name = name
        realmModel.status = status
        realmModel.species = species
        realmModel.type = type
        realmModel.gender = gender
        realmModel.image = image
        realmModel.episode.append(objectsIn: episode)
        realmModel.url = url
        realmModel.created = created
        realmModel.originName = origin.name
        realmModel.originURL = origin.url
        realmModel.locationName = location.name
        realmModel.locationURL = location.url
        return realmModel
    }
}

extension CharacterDBModel {
    func toModel() -> CharacterModel {
        let origin = AdditionalObject(name: originName, url: originURL)
        let location = AdditionalObject(name: locationName, url: locationURL)
        return CharacterModel(
        id: id,
        name: name,
        status: status,
        species: species,
        type: type,
        gender: gender,
        origin: origin,
        location: location,
        image: image,
        episode: Array(episode),
        url: url,
        created: created
        )
    }
}
