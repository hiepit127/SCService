//
//  SortDescriptor.swift
//  VDService
//
//  Created by Hiệp Hoàng on 28/03/2024.
//

import Foundation
import CoreData

public struct SortDescriptor<ModelType : NSManagedObject> {
    let sortDescriptor:NSSortDescriptor
    
    init(sortDescriptor:NSSortDescriptor) {
        self.sortDescriptor = sortDescriptor
    }
}

extension Attribute {
    public func ascending<T : NSManagedObject>() -> SortDescriptor<T> {
        return SortDescriptor(sortDescriptor: ascending())
    }
    
    public func descending<T : NSManagedObject>() -> SortDescriptor<T> {
        return SortDescriptor(sortDescriptor: descending())
    }
}
