//
//  Predicate.swift
//  VDService
//
//  Created by Hiệp Hoàng on 28/03/2024.
//

import Foundation
import CoreData

public func && (left: NSPredicate, right: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [left, right])
}

public func || (left: NSPredicate, right: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: [left, right])
}

prefix public func ! (left: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.not, subpredicates: [left])
}

// MARK: Predicate Type

public struct Predicate<ModelType : NSManagedObject> {
    let predicate:NSPredicate
    
    init(predicate:NSPredicate) {
        self.predicate = predicate
    }
}

public func == <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
    return Predicate(predicate: left == right)
}

public func != <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
    return Predicate(predicate: left != right)
}

public func > <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
    return Predicate(predicate: left > right)
}

public func >= <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
    return Predicate(predicate: left >= right)
}

public func < <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
    return Predicate(predicate: left < right)
}

public func <= <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
    return Predicate(predicate: left <= right)
}

public func ~= <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: AttributeType?) -> Predicate<T> {
    return Predicate(predicate: left ~= right)
}

public func << <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: [AttributeType]) -> Predicate<T> {
    return Predicate(predicate: left << right)
}

public func << <T: NSManagedObject, AttributeType>(left: Attribute<AttributeType>, right: Range<AttributeType>) -> Predicate<T> {
    return Predicate(predicate: left << right)
}

public func && <T>(left: Predicate<T>, right: Predicate<T>) -> Predicate<T> {
    return Predicate(predicate: left.predicate && right.predicate)
}

public func || <T>(left: Predicate<T>, right: Predicate<T>) -> Predicate<T> {
    return Predicate(predicate: left.predicate || right.predicate)
}

prefix public func ! <T>(predicate: Predicate<T>) -> Predicate<T> {
    return Predicate(predicate: !predicate.predicate)
}
