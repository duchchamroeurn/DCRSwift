//
//  File.swift
//  
//
//  Created by iOSDev on 9/24/19.
//

import Foundation

enum ENV {
    case dev
    case pro
}

enum NetworkError: Error {
    case decodingError
    case domainError
    case urlError
    case custom(msg: String)
}

fileprivate struct Response<T: Codable>: Codable {
    let message: String
    let data: T
    let success: Bool
}

class WSManager: NSObject {
    
    /// Instant object WSManager
    public static var share: WSManager {
        get { return WSManager() }
    }
    
    /// Enviroment of Web Service access
    //TODO: - Must be update base on the environment
    public let env: ENV = .dev
    
    /// MARK:- Initialize
    private override init() {
        super.init()
    }
    
    
    public var isConnected: Bool {
        get {
            return Reachability.forInternetConnection().isReachable()
        }
    }
    
    
    /// To request the resource from the network
    ///
    /// - Parameters:
    ///   - resource: data resource
    ///   - completion: completion tasks handle
    public func request<T>(resource: APIResource<T>, completion: @escaping (Result<T, NetworkError>)->()) {
        
        if !isConnected {
            completion(.failure(.custom(msg: "MSG.NoInternet".localized())))
        }
        
        let request = self.urlRequest(resource)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(.domainError))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 401 {
                    do {
                        let responseData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                        if let message = responseData?["message"] as? String {
                            completion(.failure(.custom(msg: message)))
                            return
                        }
                        
                    } catch { }
                    
                    completion(.failure(.decodingError))
                    return
                }
            }
            
            do {
                let result = try JSONDecoder().decode(Response<T>.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result.data))
                }
            } catch {
                completion(.failure(.decodingError))
            }
            }.resume()
    }
    
    
    
    private func urlRequest<T>(_ resource: APIResource<T>) -> URLRequest {
        
        let url = resource.baseURL.appendingPathComponent(resource.path)
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        request.httpBody = resource.body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if resource.authorizeType == .bearer {
            if let token = UserHelper.USER_TOKEN {
                 request.addValue("\(token.token_type) \(token.access_token)", forHTTPHeaderField: "Authorization")
            }
           
        }
        
        return request
    }
    
}
