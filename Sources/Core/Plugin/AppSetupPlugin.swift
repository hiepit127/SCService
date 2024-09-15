//
//  AppSetupPlugin.swift
//  SCService
//
//  Created by Hoàng Hiệp on 14/9/24.
//

import Foundation
import UIKit

public protocol AppSetupPlugin: UIApplicationDelegate {}

public protocol AppSetupNotificationHandler {
    func shouldHandler(notification: UNNotification) -> Bool
    func userNotificationCenter(willPresent notification: UNNotification) -> UNNotificationPresentationOptions?
    func userNotificationCenter(didReceive notification: UNNotification)
    func handleLogicWhenLoginSuccess(didReceive notification: UNNotification, navigationController: UINavigationController?)
}

extension AppSetupNotificationHandler {
    public func shouldHandler(notification: UNNotification) -> Bool {
        false
    }
}

public protocol ResolverRegistrationPlugin {
    func registerAllServices()
}
