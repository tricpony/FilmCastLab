//
//  Actor+CoreDataClass.swift
//  
//
//  Created by aarthur on 8/15/18.
//
//

import Foundation
import CoreData

@objc(Actor)
public class Actor: NSManagedObject {

    /**
     actorInfo looks like this:
     
     {
     FirstURL = "https://duckduckgo.com/Troy_McClure";
     Icon =     {
     Height = "";
     URL = "https://duckduckgo.com/i/20433a15.png";
     Width = "";
     };
     Result = "<a href=\"https://duckduckgo.com/Troy_McClure\">Troy McClure</a><br>Troy McClure is a fictional character in the American animated sitcom The Simpsons. He was voiced by Phil Hartman and first appeared in the second season episode \"Homer vs. Lisa and the 8th Commandment\".";
     Text = "Troy McClure - Troy McClure is a fictional character in the American animated sitcom The Simpsons. He was voiced by Phil Hartman and first appeared in the second season episode \"Homer vs. Lisa and the 8th Commandment\".";
     },

     **/
    @discardableResult class func createActor(actorInfo: Dictionary<String,Any>, inContext: NSManagedObjectContext) -> Actor? {
        let ctx = inContext
        var actor: Actor? = nil
        let actorProfileInfo: String = actorInfo["Text"] as! String
        
        if let range = actorProfileInfo.range(of: "-") {
            let name = actorProfileInfo[..<range.lowerBound].trimmingCharacters(in: CharacterSet.whitespaces)

                actor = CoreDataUtility.fetchActor(named: name, in: ctx)
                if (actor == nil) {
                    actor = Actor.mr_createEntity(in: inContext)
                    
                    let profile = actorProfileInfo[range.upperBound...].trimmingCharacters(in: CharacterSet.whitespaces)
                    actor?.profile = profile
                    actor?.name = name
                    if let iconInfo = actorInfo["Icon"] as? Dictionary<String,String>{
                        actor?.iconURL = iconInfo["URL"]
                    }
                }
        }else{
            print("Name not present")
        }

        return actor!
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setValue(NSDate(), forKey:"createDate")
    }

    func isFavorite() -> Bool {
        return self.favorite != nil
    }
    
}
