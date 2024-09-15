//
//  RegisterPlugin.swift
//  SCService
//
//  Created by Hoàng Hiệp on 14/9/24.
//

import Foundation
import Resolver

public struct SCServiceRegistrationPlugin: ResolverRegistrationPlugin {
    public func registerAllServices() {
        registerService()
        registerSDKManager()
    }

    public init() {}
    
    func registerService() {
        
    }
    
    func registerSDKManager() {
        
    }
}
