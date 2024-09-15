//
//  SCServiceAppSetup.swift
//  SCService
//
//  Created by Hoàng Hiệp on 14/9/24.
//

import Foundation
import UIKit

public class SCServiceAppSetup: NSObject, AppSetupPlugin {
    public private(set) var resolverRegistrationPlugins: [ResolverRegistrationPlugin] = [SCServiceRegistrationPlugin()]

    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let appSetup = AppSetupPluginPoint(resolverRegistrationPlugins: resolverRegistrationPlugins)
        appSetup.appendResolverRegistrationPlugin(SCServiceRegistrationPlugin())
        return true
    }
}
