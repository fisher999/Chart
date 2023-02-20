//
//  NetworkService.swift
//  Chart
//
//  Created by vi.s.semenov on 18.02.2023.
//

import Foundation

struct ResponseErrorCode: CustomStringConvertible {
    let code: Int
    
    var description: String {
        switch code {
        case 400:
            return "Bad request"
        case 500:
            return "Server error"
        default:
            return "Unknown error, code: \(code)"
        }
    }
}

enum NetworkServiceError: Error {
    case invalidURL(url: String)
    case invalidRequest(underlyingError: Error?)
    case responseError(code: ResponseErrorCode)
    case invalidResponse(error: Error?)
}

class NetworkService {
    // MARK: - Properties
    var baseURL: String {
        return config.baseURL
    }
    
    private let session = URLSession(configuration: .default)
    private let decoder = JSONDecoder()
    private let completionQueue: DispatchQueue
    private let config = Config()
    
    // MARK: - Init
    init(completionQueue: DispatchQueue = .main) {
        self.completionQueue = completionQueue
    }
    
    // MARK: - Public
    func getRequest<Response: Decodable>(
        _ : Response.Type,
        url: String,
        parameters: [String: String],
        completion: @escaping ((Result<Response, Error>) -> Void)
    ) {
        let completion = wrapWithCompletionQueue(handler: completion)
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = makeQueryItems(with: parameters)
        guard let url = urlComponents?.url else { completion(.failure(NetworkServiceError.invalidURL(url: url)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        logRequest(request: request)
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(NetworkServiceError.invalidRequest(underlyingError: error)))
                self.logError(error: error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkServiceError.invalidRequest(underlyingError: nil)))
                return
            }
            
            self.logResponse(response: response, data: data)
            guard (200 ..< 300).contains(response.statusCode) else {
                let error = NetworkServiceError.responseError(code: ResponseErrorCode(code: response.statusCode))
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkServiceError.invalidResponse(error: nil)))
                return
            }
            
            do {
                let response = try self.decoder.decode(Response.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(NetworkServiceError.invalidResponse(error: error)))
            }
        }.resume()
    }
    
    // MARK: - Private
    private func logError(error: Error) {
        print("-------Request ERROR--------")
        let nsError = error as NSError
        print("Domain: \(nsError.domain)")
        print("Code: \(nsError.code)")
        print("Error description: \(nsError.localizedDescription)")
    }
    
    private func logRequest(request: URLRequest) {
        print("--------Request----------")
        if let url = request.url {
            print("URL: \(url)")
        }
        if let method = request.httpMethod {
            print("METHOD: \(method)")
        }
        if let body = request.httpBody, let stringBody = String(
            data: body,
            encoding: .utf8
        ) {
            print("BODY: \(stringBody)")
        }
    }
    
    private func logResponse(response: HTTPURLResponse, data: Data?) {
        print("---------Response----------")
        
        print("CODE: \(response.statusCode)")
        
        if let data = data {
            let response: String?
            if let jsonObject = try? JSONSerialization.jsonObject(with: data),
               let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
                response = String(data: prettyPrintedData, encoding: .utf8)
            } else {
                response = String(data: data, encoding: .utf8)
            }
                
            if let response = response {
                print("Response: \(response)")
            }
        }
    }
    
    private func wrapWithCompletionQueue<Response: Decodable>(handler: @escaping ((Result<Response, Error>) -> Void)) -> ((Result<Response, Error>) -> Void) {
        let handler: (Result<Response, Error>) -> Void = { [weak self] result in
            guard let self = self else { return }
            self.completionQueue.async {
                handler(result)
            }
        }
        return handler
    }
    
    private func makeQueryItems(with parameters: [String: String]) -> [URLQueryItem] {
        return parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
    }
}
