//
//  SCBaseClient.swift
//  SCService
//
//  Created by Hoàng Hiệp on 14/9/24.
//

import Foundation

class SCBaseClient {
    let host: String
    let serverURI: ServerURIType
    
    init(host: String, serverURI: ServerURIType) {
        self.host = host
        self.serverURI = serverURI
    }
    
    func constructRequest<Parameters: Codable>(
        with path: String,
        method: HTTPMethodType = .get,
        parameters: Parameters = SCEmptyRequest(),
        headers: [String: String]? = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ],
        queryParam: [String: String]? = nil
    ) -> URLRequest? {
        
        var url = getBaseURL()
        
        if !path.isEmpty {
            url = getBaseURL().appendingPathComponent(path)
        }
        
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if let queryParam = queryParam {
            components?.queryItems = getURLQueryItems(for: queryParam)
        }
        
        var jsonData: Data?
        let jsonEncoder = JSONEncoder()
        jsonData = try? jsonEncoder.encode(parameters)
        if [.get].contains(method), let data = jsonData {
            let params = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any?]
            components?.queryItems = getURLQueryItems(for: params)
        }
        
        guard let componentUrl = components?.url else { return nil }
        var httpRequest = URLRequest(url: componentUrl)
        for (key, value) in headers ?? [:] {
            httpRequest.addValue(value, forHTTPHeaderField: key)
        }
        httpRequest.httpMethod = method.rawValue
        
        if [.post, .put, .patch, .delete].contains(method), let jsonData = jsonData {
            httpRequest.httpBody = jsonData
        }
        
        return httpRequest

    }
    
    func getBaseURL() -> URL {
        guard let serverURL: URL = URL(string: host) else {
            fatalError("Invalid or no serverURL found in the SDK configuration.")
        }
        
        return serverURL.appendingPathComponent(serverURI.value)
    }
    
    private func getURLQueryItems(for params: [String: String]) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        params.forEach { (key, value) in
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        return queryItems
    }
    
    private func getURLQueryItems(for params: [String: Any?]?) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        for (key, value) in (params ?? [:]) {
            if let value = value {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
        }
        return queryItems
    }
    
    private func convertErrorDataToJson<T: Codable>(response: URLResponse?,
                                                    data: Data?,
                                                    completion: SCResponseCompletion<T>) {
        if let data = data {
            completion(.error(APIError.error(SCExpectingAPIError(data: data, urlResponse: response))))
        } else {
            let error = NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? 200, userInfo: nil)
            completion(.error(APIError.error(error)))
        }
    }
    
    func objectResponse<T: Codable>(from request: URLRequest?, _ completion: @escaping SCResponseCompletion<T>) {
        guard let request = request
        else {
            completion(.error(APIError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                let code = URLError.Code(rawValue: (error as NSError).code)
                switch code {
                case .notConnectedToInternet:
                    completion(.error(APIError.notConnected))
                case .cancelled:
                    completion(.error(APIError.cancelled))
                default:
                    self?.convertErrorDataToJson(response: response, data: data, completion: completion)
                }
                return
            }
            
            guard let responseData = data else {
                completion(.error(APIError.invalidData))
                return
            }
            
            do {
                if let successOnly = SuccessOnlyResponse() as? T {
                    completion(.success(successOnly))
                } else {
                    let item = try JSONDecoder().decode(T.self, from: responseData)
                    completion(.success(item))
                }
            } catch {
                print("Unexpected error: \(error).")
                completion(.error(APIError.invalidData))
                return
            }
        }.resume()
    }
}
