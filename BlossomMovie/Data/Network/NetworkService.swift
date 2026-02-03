//
//  NetworkService.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
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
        let configuration = await MainActor.run { configurationManager.configuration }
        guard let configuration = configuration else {
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
            return "Unable to load API settings. Please check your configuration file."
        case .invalidURL:
            return "The requested URL is invalid. Please try again later."
        case .invalidResponse:
            return "Received an unexpected response from the server."
        case .httpError(let statusCode, _):
            return httpErrorMessage(for: statusCode)
        case .decodingError:
            return "Unable to process server data. The content may be unavailable."
        case .requestFailed(let error):
            // Check for common network errors
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                return urlErrorMessage(for: nsError.code)
            }
            return "Network request failed. Please check your connection."
        }
    }

    /// Helper method for HTTP status codes
    private func httpErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return "Bad request. Please try again with different search terms."
        case 401:
            return "Authentication failed. Please check your API key."
        case 403:
            return "Access forbidden. Your API key may have insufficient permissions."
        case 404:
            return "The requested content was not found."
        case 429:
            return "Too many requests. Please try again in a few moments."
        case 500...599:
            return "Server error. Please try again later."
        default:
            return "Request failed with status code \(statusCode)."
        }
    }

    /// Helper method for URL errors
    private func urlErrorMessage(for code: Int) -> String {
        switch code {
        case NSURLErrorNotConnectedToInternet:
            return "No internet connection. Please check your network settings."
        case NSURLErrorTimedOut:
            return "Request timed out. Please try again."
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
            return "Cannot connect to server. Please try again later."
        case NSURLErrorNetworkConnectionLost:
            return "Network connection lost. Please try again."
        default:
            return "Network error occurred. Please check your connection."
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
