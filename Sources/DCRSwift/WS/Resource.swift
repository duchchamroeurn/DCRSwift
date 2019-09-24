//
//  File.swift
//  
//
//  Created by iOSDev on 9/24/19.
//

import Foundation

enum HttpMethod: String {
    case GET
    case POST
}

enum AuthorizationType {
    case none
    case bearer
}

protocol TargetResource {
    
    /// The target's base `URL`.
    var baseURL: URL { get }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    
    /// The HTTP method used in the request.
    var method: HttpMethod { get }
    
    var body: Data? { get }
    
    var authorizeType: AuthorizationType { get }
}

enum APIResource<T: Codable> {
    case authenthicate(credentials: Data)
    case userProfile
}


extension APIResource: TargetResource {
    var baseURL: URL {
        guard let url = URL(string: NameOfWS.baseURL) else { fatalError("Invalid Base URL.") }
        return url
    }
    
    var path: String {
        switch self {
        case .authenthicate:
            return "login"
        case .userProfile:
            return "profile"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .authenthicate:
            return .POST
        case .userProfile:
            return .GET
        }
    }
    
    var body: Data? {
        switch self {

        case .authenthicate(let credentials):
            return credentials
        default:
            return nil
        }
    }
    
    var authorizeType: AuthorizationType {
        switch self {
       
        case .authenthicate(_):
            return .none
        case .userProfile:
            return .bearer
        }
    }
    
    
}
