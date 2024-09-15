//
//  AppSetupPluginPoint.swift
//  SCService
//
//  Created by Hoàng Hiệp on 14/9/24.
//

import Foundation
import UIKit
import Resolver

public class AppSetupPluginPoint: NSObject {
    public private(set) var resolverRegistrationPlugins: [ResolverRegistrationPlugin]
    public init(resolverRegistrationPlugins: [ResolverRegistrationPlugin] = [],
                shouldSetDefault: Bool = true) {
        self.resolverRegistrationPlugins = resolverRegistrationPlugins
        super.init()
        if shouldSetDefault {
            AppSetupPluginPoint.setDefaultPluginPoint(self)
        }
    }

    public func appendResolverRegistrationPlugin(_ plugin: ResolverRegistrationPlugin) {
        resolverRegistrationPlugins.append(plugin)
        plugin.registerAllServices()
    }
}

extension AppSetupPluginPoint {
    public static func setDefaultPluginPoint(_ point: AppSetupPluginPoint) {
        AppSetupPluginPoint.default = point
    }
    public static private(set) var `default`: AppSetupPluginPoint?
}
