//
//  Actor+CoreDataProperties.swift
//  
//
//  Created by aarthur on 8/15/18.
//
//

import Foundation
import CoreData

extension Actor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Actor> {
        return NSFetchRequest<Actor>(entityName: "Actor")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var iconURL: String?
    @NSManaged public var name: String?
    @NSManaged public var profile: String?
    @NSManaged public var favorite: Favorite?

}
