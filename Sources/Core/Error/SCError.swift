//
//  SCError.swift
//  SCService
//
//  Created by Hoàng Hiệp on 15/9/24.
//

import Foundation

public enum APIError: Error {
    case invalidResponse
    case invalidData
    case invalidParams
    case invalidURL
    case notConnected
    case cancelled
    case error(Error)
}

public struct SCExpectingAPIError: Error {
    public let data: Data?
    public let urlResponse: URLResponse?
    public init(data: Data?, urlResponse: URLResponse?) {
        self.data = data
        self.urlResponse = urlResponse
    }
}

public enum CoreDataError: Error {
    case queryError
}
