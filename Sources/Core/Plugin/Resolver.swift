//
//  Resolver.swift
//  SCService
//
//  Created by Hoàng Hiệp on 14/9/24.
//

import Foundation
import Resolver

@propertyWrapper
public struct Injected<Service> {
    private var service: Service
    public init() {
        self.service = serviceLocator.resolve(name: nil)
    }
    public init(name: String?) {
        self.service = serviceLocator.resolve(name: name)
    }
    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }
    public var projectedValue: Injected<Service> {
        get { return self }
        mutating set { self = newValue }
    }

    public let serviceLocator: ServiceLocating = ServiceLocator.default
}

public protocol ServiceLocating {
    func resolve<Service>(name: String?) -> Service
}

public final class ServiceLocator: ServiceLocating, Resolving {
    public func resolve<Service>(name: String? = nil) -> Service {
        func resolveWithoutName() -> Service {
            resolver.resolve()
        }
        func resolveWithName(_ name: String) -> Service {
            let rName = Resolver.Name(name)
            return resolver.resolve(Service.self, name: rName)
        }
        guard let extName = name else {
            return resolveWithoutName()
        }

        return resolveWithName(extName)
    }

    public static let `default` = ServiceLocator()
}
