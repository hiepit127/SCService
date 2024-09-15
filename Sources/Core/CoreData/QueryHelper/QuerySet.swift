//
//  QuerySet.swift
//  VDService
//
//  Created by Hiệp Hoàng on 28/03/2024.
//

import Foundation
import CoreData

open class QuerySet<ModelType : NSManagedObject> : Equatable {
    public let context: NSManagedObjectContext
    
    public let entityName: String
    
    public let sortDescriptors: [NSSortDescriptor]
    
    public let predicate: NSPredicate?
    
    public let range: Range<Int>?
    
    // MARK: Initialization
    
    public init(_ context:NSManagedObjectContext, _ entityName:String) {
        self.context = context
        self.entityName = entityName
        self.sortDescriptors = []
        self.predicate = nil
        self.range = nil
    }
    
    public init(queryset:QuerySet<ModelType>, sortDescriptors:[NSSortDescriptor]?, predicate:NSPredicate?, range: Range<Int>?) {
        self.context = queryset.context
        self.entityName = queryset.entityName
        self.sortDescriptors = sortDescriptors ?? []
        self.predicate = predicate
        self.range = range
    }
}

extension QuerySet {
    // MARK: Sorting
    
    public func orderBy(_ sortDescriptor:NSSortDescriptor) -> QuerySet<ModelType> {
        return orderBy([sortDescriptor])
    }
    
    public func orderBy(_ sortDescriptors:[NSSortDescriptor]) -> QuerySet<ModelType> {
        return QuerySet(queryset:self, sortDescriptors:sortDescriptors, predicate:predicate, range:range)
    }
    
    public func reverse() -> QuerySet<ModelType> {
        func reverseSortDescriptor(_ sortDescriptor:NSSortDescriptor) -> NSSortDescriptor {
            return NSSortDescriptor(key: sortDescriptor.key!, ascending: !sortDescriptor.ascending)
        }
        
        return QuerySet(queryset:self, sortDescriptors:sortDescriptors.map(reverseSortDescriptor), predicate:predicate, range:range)
    }
    
    // MARK: Type-safe Sorting
    
    public func orderBy<T>(_ keyPath: KeyPath<ModelType, T>, ascending: Bool) -> QuerySet<ModelType> {
        return orderBy(NSSortDescriptor(key: (keyPath as AnyKeyPath)._kvcKeyPathString!, ascending: ascending))
    }
    
    public func orderBy(_ closure:((ModelType.Type) -> (SortDescriptor<ModelType>))) -> QuerySet<ModelType> {
        return orderBy(closure(ModelType.self).sortDescriptor)
    }
    
    public func orderBy(_ closure:((ModelType.Type) -> ([SortDescriptor<ModelType>]))) -> QuerySet<ModelType> {
        return orderBy(closure(ModelType.self).map { $0.sortDescriptor })
    }
    
    // MARK: Filtering
    
    public func filter(_ predicate: Predicate<ModelType>) -> QuerySet<ModelType> {
        return filter(predicate.predicate)
    }
    
    public func filter(_ predicate:NSPredicate) -> QuerySet<ModelType> {
        var futurePredicate = predicate
        
        if let existingPredicate = self.predicate {
            futurePredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [existingPredicate, predicate])
        }
        
        return QuerySet(queryset:self, sortDescriptors:sortDescriptors, predicate:futurePredicate, range:range)
    }
    
    public func filter(_ predicates:[NSPredicate]) -> QuerySet<ModelType> {
        let newPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
        return filter(newPredicate)
    }
    
    public func exclude(_ predicate: Predicate<ModelType>) -> QuerySet<ModelType> {
        return exclude(predicate.predicate)
    }
    
    public func exclude(_ predicate:NSPredicate) -> QuerySet<ModelType> {
        let excludePredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.not, subpredicates: [predicate])
        return filter(excludePredicate)
    }
    
    public func exclude(_ predicates:[NSPredicate]) -> QuerySet<ModelType> {
        let excludePredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
        return exclude(excludePredicate)
    }
    
    // MARK: Type-safe filtering
    
    @available(*, deprecated, renamed: "filter(_:)", message: "Replaced by KeyPath filtering https://git.io/Jv2v3")
    public func filter(_ closure:((ModelType.Type) -> (Predicate<ModelType>))) -> QuerySet<ModelType> {
        return filter(closure(ModelType.self).predicate)
    }
    
    @available(*, deprecated, renamed: "exclude(_:)", message: "Replaced by KeyPath filtering https://git.io/Jv2v3")
    public func exclude(_ closure:((ModelType.Type) -> (Predicate<ModelType>))) -> QuerySet<ModelType> {
        return exclude(closure(ModelType.self).predicate)
    }
    
    @available(*, deprecated, renamed: "filter(_:)", message: "Replaced by KeyPath filtering https://git.io/Jv2v3")
    public func filter(_ closures:[((ModelType.Type) -> (Predicate<ModelType>))]) -> QuerySet<ModelType> {
        return filter(closures.map { $0(ModelType.self).predicate })
    }
    
    @available(*, deprecated, renamed: "exclude(_:)", message: "Replaced by KeyPath filtering https://git.io/Jv2v3")
    public func exclude(_ closures:[((ModelType.Type) -> (Predicate<ModelType>))]) -> QuerySet<ModelType> {
        return exclude(closures.map { $0(ModelType.self).predicate })
    }
}

extension QuerySet {
    // MARK: Subscripting
    
    public func object(_ index: Int) throws -> ModelType? {
        let request = fetchRequest
        request.fetchOffset = index
        request.fetchLimit = 1
        do {
            let items = try context.fetch(request)
            return items.first
        } catch {
            throw CoreDataError.queryError
        }
    }
    
    public subscript(range: ClosedRange<Int>) -> QuerySet<ModelType> {
        get {
            return self[Range(range)]
        }
    }
    
    public subscript(range: Range<Int>) -> QuerySet<ModelType> {
        get {
            var fullRange = range
            
            if let currentRange = self.range {
                fullRange = ((currentRange.lowerBound + range.lowerBound) ..< range.upperBound)
            }
            
            return QuerySet(queryset:self, sortDescriptors:sortDescriptors, predicate:predicate, range:fullRange)
        }
    }
    
    // Mark: Getters
    
    public func first() throws -> ModelType? {
        return try self.object(0)
    }
    
    public func last() throws -> ModelType? {
        do {
            return try reverse().first()
        } catch {
            throw CoreDataError.queryError
        }
    }
    
    // MARK: Conversion
    
    public var fetchRequest: NSFetchRequest<ModelType> {
        let request = NSFetchRequest<ModelType>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        if let range = range {
            request.fetchOffset = range.lowerBound
            request.fetchLimit = range.upperBound - range.lowerBound
        }
        
        return request
    }
    
    public func array() throws -> [ModelType] {
        do {
            return try context.fetch(fetchRequest)
        } catch {
            throw CoreDataError.queryError
        }
    }
    
    // MARK: Count
    
    public func count() throws -> Int {
        do {
            return try context.count(for: fetchRequest)
        } catch {
            throw CoreDataError.queryError
        }
    }
    
    // MARK: Exists
    
    public func exists() throws -> Bool {
        let fetchRequest = self.fetchRequest
        fetchRequest.fetchLimit = 1
        do {
            let result = try context.count(for: fetchRequest)
            return result != 0
        } catch {
            throw CoreDataError.queryError
        }
    }
    
    // MARK: Deletion
    
    public func delete() throws -> Int {
        do {
            let objects = try array()
            let deletedCount = objects.count
            
            for object in objects {
                context.delete(object)
            }
            return deletedCount
        } catch {
            throw CoreDataError.queryError
        }
    }
}

public func == <ModelType : NSManagedObject>(lhs: QuerySet<ModelType>, rhs: QuerySet<ModelType>) -> Bool {
    let context = lhs.context == rhs.context
    let entityName = lhs.entityName == rhs.entityName
    let sortDescriptors = lhs.sortDescriptors == rhs.sortDescriptors
    let predicate = lhs.predicate == rhs.predicate
    let startIndex = lhs.range?.lowerBound == rhs.range?.lowerBound
    let endIndex = lhs.range?.upperBound == rhs.range?.upperBound
    return context && entityName && sortDescriptors && predicate && startIndex && endIndex
}
