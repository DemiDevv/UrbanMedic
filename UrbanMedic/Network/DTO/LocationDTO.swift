//
//  LocationDTO.swift
//  UrbanMedic
//
//  Created by Demain Petropavlov on 02.02.2026.
//

import Foundation

// MARK: - Root Response

struct LocationResponse: Codable {
    let suggestions: [LocationSuggestion]
}

// MARK: - Location Suggestion

struct LocationSuggestion: Codable {
    let value: String
    let unrestrictedValue: String
    let data: LocationData

    enum CodingKeys: String, CodingKey {
        case value
        case unrestrictedValue = "unrestricted_value"
        case data
    }
}

// MARK: - Location Data

struct LocationData: Codable {
    let city: String?
    let settlement: String?
    let area: String?
    let region: String?

    var cityName: String {
        return city ?? settlement ?? area ?? region ?? LocalizedStrings.unknown
    }
}
