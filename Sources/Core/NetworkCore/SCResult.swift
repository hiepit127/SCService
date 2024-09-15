//
//  SCResult.swift
//  SCService
//
//  Created by Hoàng Hiệp on 14/9/24.
//

import Foundation
import CoreData

public typealias SCResponseCompletion<T: Codable> = ((_ response: SCResult<T>)-> Void)

enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

public enum SCResult<T: Codable> {
    case success(T?)
    case error(Error)
}

public struct SuccessOnlyResponse: Codable {
    public init() {}
}

struct SCEmptyRequest: Codable { }

protocol SCBaseRequest: Codable {
    var page: Int? { get set }
    var pageSize: Int? { get set }
}
