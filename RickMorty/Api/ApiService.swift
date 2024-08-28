//
//  ApiService.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import Foundation
import Alamofire

final class ApiService {
    enum Path: String {
        case character
        case location
        case episode
    }
    
    static let shared = ApiService()
    
    private let baseUrlString = "https://rickandmortyapi.com/api/"
    
    private init() {}
}

extension ApiService {
    
    func makeRequest<T: Codable>(
        type: T.Type,
        path: Path,
        page: Int,
        callBack: @escaping (Result<ApiCommonResponse<T>, Error>) -> Void
    ) {
        guard
            let url = URL(string: baseUrlString)?.appending(path: path.rawValue)
        else {
            callBack(.failure(MyError.invalidURL))
            return
        }
        
        AF.session.configuration.requestCachePolicy = .reloadIgnoringCacheData
        AF.request(
            url,
            method: .get,
            parameters: ["page": page]
        ).responseDecodable(of: ApiCommonResponse<T>.self) { response in
            switch response.result {
            case .success(let responseModel):
                callBack(.success(responseModel))
            case .failure(let error):
                callBack(.failure(error))
            }
        }
    }
    
    
    func makeSingleObjectRequest<T: Codable>(
        type: T.Type,
        fullUrlString: String,
        callBack: @escaping (Result<T, Error>) -> Void
    ) {
        guard
            let url = URL(string: fullUrlString)
        else {
            callBack(.failure(MyError.invalidURL))
            return
        }
        
        AF.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        AF.request(
            url,
            method: .get
        ).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let responceModel):
                callBack(.success(responceModel))
            case .failure(let error):
                callBack(.failure(error))
            }
        }
    }
}

enum MyError: Error {
    case invalidURL
    
    var descriptionOfError: String {
        switch self {
        case .invalidURL:
            return "Не удалось создать ссылку"
        }
    }
}
