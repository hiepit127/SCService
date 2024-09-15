//
//  Encoder+Extension.swift
//  SCService
//
//  Created by Hoàng Hiệp on 14/9/24.
//

import Foundation

public extension Encodable {
    func asDictionary() throws -> [String: AnyHashable] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyHashable] else {
            throw NSError()
        }
        return dictionary
    }
}
