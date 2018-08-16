//
//  Favorite+CoreDataClass.swift
//  
//
//  Created by aarthur on 8/15/18.
//
//

import Foundation
import CoreData

@objc(Favorite)
public class Favorite: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

}
