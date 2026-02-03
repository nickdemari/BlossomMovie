//
//  MediaItem.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftData
import Foundation

/// Media type enumeration
enum MediaType: String, Codable, CaseIterable {
    case movie
    case tv
    
    var displayName: String {
        switch self {
        case .movie: return "Movie"
        case .tv: return "TV Show"
        }
    }
}

/// API response wrapper for TMDB
struct TMDBResponse<T: Codable>: Codable {
    let page: Int?
    let results: [T]
    let totalPages: Int?
    let totalResults: Int?
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

/// Main media item model
@Model
final class MediaItem: Codable, Identifiable, Hashable {
    
    // MARK: - Properties
    @Attribute(.unique) var id: Int
    var title: String?
    var name: String?
    var overview: String?
    var posterPath: String?
    var backdropPath: String?
    var releaseDate: String?
    var firstAirDate: String?
    var voteAverage: Double
    var voteCount: Int
    var popularity: Double
    var adult: Bool
    var genreIds: [Int]
    var originalLanguage: String?
    var originalTitle: String?
    var originalName: String?
    var mediaType: String?
    
    // MARK: - Computed Properties
    var displayTitle: String {
        return title ?? name ?? "Unknown Title"
    }
    
    var displayDate: String {
        return releaseDate ?? firstAirDate ?? ""
    }
    
    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
    
    var fullBackdropURL: String? {
        guard let backdropPath = backdropPath else { return nil }
        return "https://image.tmdb.org/t/p/w1280\(backdropPath)"
    }
    
    var formattedRating: String {
        return String(format: "%.1f", voteAverage)
    }
    
    var type: MediaType? {
        guard let mediaType = mediaType else { return nil }
        return MediaType(rawValue: mediaType)
    }
    
    // MARK: - Initialization
    init(
        id: Int = 0,
        title: String? = nil,
        name: String? = nil,
        overview: String? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        firstAirDate: String? = nil,
        voteAverage: Double = 0.0,
        voteCount: Int = 0,
        popularity: Double = 0.0,
        adult: Bool = false,
        genreIds: [Int] = [],
        originalLanguage: String? = nil,
        originalTitle: String? = nil,
        originalName: String? = nil,
        mediaType: String? = nil
    ) {
        self.id = id
        self.title = title
        self.name = name
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.firstAirDate = firstAirDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.adult = adult
        self.genreIds = genreIds
        self.originalLanguage = originalLanguage
        self.originalTitle = originalTitle
        self.originalName = originalName
        self.mediaType = mediaType
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, title, name, overview, adult, popularity
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case originalName = "original_name"
        case mediaType = "media_type"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.overview = try container.decodeIfPresent(String.self, forKey: .overview)
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        self.backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        self.firstAirDate = try container.decodeIfPresent(String.self, forKey: .firstAirDate)
        self.voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage) ?? 0.0
        self.voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? 0
        self.popularity = try container.decodeIfPresent(Double.self, forKey: .popularity) ?? 0.0
        self.adult = try container.decodeIfPresent(Bool.self, forKey: .adult) ?? false
        self.genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds) ?? []
        self.originalLanguage = try container.decodeIfPresent(String.self, forKey: .originalLanguage)
        self.originalTitle = try container.decodeIfPresent(String.self, forKey: .originalTitle)
        self.originalName = try container.decodeIfPresent(String.self, forKey: .originalName)
        self.mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(overview, forKey: .overview)
        try container.encodeIfPresent(posterPath, forKey: .posterPath)
        try container.encodeIfPresent(backdropPath, forKey: .backdropPath)
        try container.encodeIfPresent(releaseDate, forKey: .releaseDate)
        try container.encodeIfPresent(firstAirDate, forKey: .firstAirDate)
        try container.encode(voteAverage, forKey: .voteAverage)
        try container.encode(voteCount, forKey: .voteCount)
        try container.encode(popularity, forKey: .popularity)
        try container.encode(adult, forKey: .adult)
        try container.encode(genreIds, forKey: .genreIds)
        try container.encodeIfPresent(originalLanguage, forKey: .originalLanguage)
        try container.encodeIfPresent(originalTitle, forKey: .originalTitle)
        try container.encodeIfPresent(originalName, forKey: .originalName)
        try container.encodeIfPresent(mediaType, forKey: .mediaType)
    }
}

// MARK: - Preview Data
extension MediaItem {
    static let previewItems: [MediaItem] = [
        MediaItem(
            id: 1,
            title: "The Dark Knight",
            overview: "Batman raises the stakes in his war on crime with the help of Lt. Jim Gordon and District Attorney Harvey Dent.",
            posterPath: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
            backdropPath: "/hqkIcbrOHL86UncnHIsHVcVmzue.jpg",
            releaseDate: "2008-07-18",
            voteAverage: 8.5,
            voteCount: 32000,
            popularity: 78.5,
            genreIds: [28, 80, 18],
            mediaType: "movie"
        ),
        MediaItem(
            id: 2,
            name: "Breaking Bad",
            overview: "A high school chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine in order to secure his family's future.",
            posterPath: "/ggFHVNu6YYI5L9pCfOacjizRGt.jpg",
            firstAirDate: "2008-01-20",
            voteAverage: 9.5,
            voteCount: 15000,
            popularity: 95.2,
            genreIds: [18, 80],
            mediaType: "tv"
        ),
        MediaItem(
            id: 3,
            title: "Inception",
            overview: "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",
            posterPath: "/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg",
            releaseDate: "2010-07-16",
            voteAverage: 8.3,
            voteCount: 28000,
            popularity: 82.1,
            genreIds: [28, 878, 53],
            mediaType: "movie"
        )
    ]
}
