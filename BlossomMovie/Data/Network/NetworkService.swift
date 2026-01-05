//
//  NetworkService.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import Foundation

/// Network service protocol
protocol NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: Endpoint) async throws -> T
}

/// Main network service implementation
final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    private let session: URLSession
    private let configurationManager: ConfigurationManager
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    init(
        session: URLSession = .shared,
        configurationManager: ConfigurationManager,
        logger: LoggerProtocol
    ) {
        self.session = session
        self.configurationManager = configurationManager
        self.logger = logger
    }
    
    // MARK: - NetworkServiceProtocol Implementation
    func request<T: Codable>(_ endpoint: Endpoint) async throws -> T {
        guard let configuration = configurationManager.configuration else {
            throw NetworkError.configurationNotAvailable
        }
        
        let url = try endpoint.url(with: configuration)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if configuration.enableLogging {
            logger.log("🌐 Network Request: \(endpoint.method.rawValue) \(url)", level: .info)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if configuration.enableLogging {
                logger.log("🌐 Network Response: \(response)", level: .info)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                return decodedResponse
            } catch {
                if configuration.enableLogging {
                    logger.log("🚨 Decoding Error: \(error)", level: .error)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        logger.log("🚨 Response Data: \(jsonString)", level: .error)
                    }
                }
                throw NetworkError.decodingError(error)
            }
            
        } catch {
            if configuration.enableLogging {
                logger.log("🚨 Network Error: \(error)", level: .error)
            }
            
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.requestFailed(error)
            }
        }
    }
}

/// HTTP methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

/// Base endpoint protocol
protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    
    func url(with configuration: APIConfiguration) throws -> URL
}

/// Network errors
enum NetworkError: LocalizedError {
    case configurationNotAvailable
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingError(Error)
    case requestFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .configurationNotAvailable:
            return "API configuration is not available"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode, _):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        }
    }
}

/// TMDB API endpoints
enum TMDBEndpoint: Endpoint {
    case trending(mediaType: MediaType)
    case topRated(mediaType: MediaType)
    case upcoming
    case search(query: String, mediaType: MediaType)
    
    var path: String {
        switch self {
        case .trending(let mediaType):
            return "/3/trending/\(mediaType.rawValue)/week"
        case .topRated(let mediaType):
            return "/3/\(mediaType.rawValue)/top_rated"
        case .upcoming:
            return "/3/movie/upcoming"
        case .search(_, let mediaType):
            return "/3/search/\(mediaType.rawValue)"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .search(let query, _):
            return [URLQueryItem(name: "query", value: query)]
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    func url(with configuration: APIConfiguration) throws -> URL {
        guard var components = URLComponents(string: configuration.tmdbBaseURL) else {
            throw NetworkError.invalidURL
        }
        
        components.path = path
        
        var queryItems = self.queryItems ?? []
        queryItems.append(URLQueryItem(name: "api_key", value: configuration.tmdbAPIKey))
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
}

/// YouTube API endpoints
enum YouTubeEndpoint: Endpoint {
    case search(query: String)
    
    var path: String {
        return "/youtube/v3/search"
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .search(let query):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "part", value: "snippet"),
                URLQueryItem(name: "type", value: "video"),
                URLQueryItem(name: "maxResults", value: "1")
            ]
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    func url(with configuration: APIConfiguration) throws -> URL {
        guard var components = URLComponents(string: "https://www.googleapis.com") else {
            throw NetworkError.invalidURL
        }
        
        components.path = path
        
        var queryItems = self.queryItems ?? []
        queryItems.append(URLQueryItem(name: "key", value: configuration.youtubeAPIKey))
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
}