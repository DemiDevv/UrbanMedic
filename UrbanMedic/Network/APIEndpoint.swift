//
//  APIEndpoint.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation

enum APIEndpoint {
    case getUsers(results: Int, page: Int, seed: String)
    case getLocation(lat: Double, lon: Double)

    var url: String {
        switch self {
        case .getUsers(let results, let page, let seed):
            return "https://randomuser.me/api/?results=\(results)&page=\(page)&seed=\(seed)"
        case .getLocation:
            return "https://suggestions.dadata.ru/suggestions/api/4_1/rs/geolocate/address"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getUsers:
            return .get
        case .getLocation:
            return .post
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getUsers:
            return nil
        case .getLocation:
            return [
                "Authorization": "Token 0fc7d60da65943f6aa3ba2f4a289b50bc024d18f",
                "Content-Type": "application/json"
            ]
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
