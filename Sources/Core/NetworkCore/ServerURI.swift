//
//  ServerURI.swift
//  SCService
//
//  Created by Hoàng Hiệp on 14/9/24.
//

import Foundation

enum ServerURIType: Codable {
    case demo
    
    var value: String {
        switch self {
        case .demo:
            return "/api"
        }
    }
}
