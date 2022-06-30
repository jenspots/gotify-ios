//
//  KeyValues+CoreDataProperties.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//
//

import Foundation
import CoreData

extension KeyValues {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KeyValues> {
        return NSFetchRequest<KeyValues>(entityName: "KeyValues")
    }

    @NSManaged public var key: String?
    @NSManaged public var value: String?

}

extension KeyValues: Identifiable {

}
