//
//  NetworkManager.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation
import Alamofire

final class NetworkManager: NetworkManaging {

    init() {}

    // MARK: - Fetch Users

    func fetchUsers(results: Int = 20, page: Int, seed: String) async throws -> UserResponse {
        let endpoint = APIEndpoint.getUsers(results: results, page: page, seed: seed)

        let response = await AF.request(endpoint.url, method: .get)
            .validate()
            .serializingDecodable(UserResponse.self)
            .response

        switch response.result {
        case .success(let userResponse):
            return userResponse
        case .failure(let error):
            throw mapError(error)
        }
    }

    // MARK: - Fetch Location

    func fetchLocation(latitude: Double, longitude: Double) async throws -> LocationResponse {
        let endpoint = APIEndpoint.getLocation(lat: latitude, lon: longitude)

        guard let headers = endpoint.headers else {
            throw NetworkError.invalidURL
        }

        let parameters: [String: Any] = [
            "lat": latitude,
            "lon": longitude
        ]

        let response = await AF.request(
            endpoint.url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: HTTPHeaders(headers.map { HTTPHeader(name: $0.key, value: $0.value) })
        )
        .validate()
        .serializingDecodable(LocationResponse.self)
        .response

        switch response.result {
        case .success(let locationResponse):
            return locationResponse
        case .failure(let error):
            throw mapError(error)
        }
    }

    // MARK: - Error Mapping

    private func mapError(_ error: AFError) -> NetworkError {
        switch error {
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                return .serverError(statusCode: code)
            }
        case .responseSerializationFailed(let reason):
            if case .decodingFailed(let decodingError) = reason {
                return .decodingError(decodingError)
            }
        default:
            break
        }
        return .unknown(error)
    }
}
