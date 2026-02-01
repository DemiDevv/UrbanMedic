//
//  NetworkManager.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation
import Alamofire
import Combine

final class NetworkManager {

    static let shared = NetworkManager()

    private init() {}

    // MARK: - Fetch Users

    func fetchUsers(results: Int = 20, page: Int, seed: String) -> AnyPublisher<UserResponse, NetworkError> {
        let endpoint = APIEndpoint.getUsers(results: results, page: page, seed: seed)

        return AF.request(endpoint.url, method: .get)
            .validate()
            .publishDecodable(type: UserResponse.self)
            .value()
            .mapError { error -> NetworkError in
                if let afError = error.asAFError {
                    switch afError {
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
                }

                return .unknown(error)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Fetch Location

    func fetchLocation(latitude: Double, longitude: Double) -> AnyPublisher<LocationResponse, NetworkError> {
        let endpoint = APIEndpoint.getLocation(lat: latitude, lon: longitude)

        guard let headers = endpoint.headers else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        let parameters: [String: Any] = [
            "lat": latitude,
            "lon": longitude
        ]

        return AF.request(
            endpoint.url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: HTTPHeaders(headers.map { HTTPHeader(name: $0.key, value: $0.value) })
        )
        .validate()
        .publishDecodable(type: LocationResponse.self)
        .value()
        .mapError { error -> NetworkError in
            if let afError = error.asAFError {
                switch afError {
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
            }

            return .unknown(error)
        }
        .eraseToAnyPublisher()
    }
}
