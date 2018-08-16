//
//  CoreDataUtility.swift
//  MovieLab
//
//  Created by aarthur on 5/10/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

import Foundation

class CoreDataUtility {
        
    class func fetchActorCount(ctx: NSManagedObjectContext) -> UInt {
        return Actor.mr_countOfEntities()
    }
    
    class func fetchRequestForAllActors(ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = Actor.mr_createFetchRequest();
        let sortOrder = NSSortDescriptor.init(key: "name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortOrder]
        return fetchRequest
    }

    class func fetchActor(named name: String, in ctx: NSManagedObjectContext) -> Actor? {
        var actor: Actor? = nil
        let predicate = NSPredicate(format: "(%K = %@)", "name", name);
        
        actor = Actor.mr_findFirst(with: predicate, in: ctx)
        
        return actor
    }
    
    class func fetchedRequestForAllFavorites(ctx: NSManagedObjectContext) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = Favorite.mr_createFetchRequest();
        let sortOrder = NSSortDescriptor.init(key: "actor.name", ascending: true)
        
        fetchRequest.sortDescriptors = [sortOrder]
        return fetchRequest
    }
    
    class func fetchGenreCount(ctx: NSManagedObjectContext)->Int {
        let entity = NSEntityDescription.entity(forEntityName: "Genre", in: ctx)
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: (entity?.name)!)
        var count: Int!
        
        do {
            try count = ctx.count(for: request)

        } catch {
            count = 0
        }

        return count
    }
    
    // MARK: - Pre-fabbed predicates
    
    class func equalPredicate(key: String, value: Any) -> NSPredicate {
        let lhs: NSExpression = NSExpression.init(forKeyPath: key)
        let rhs: NSExpression = NSExpression.init(forConstantValue: value)
        let q: NSPredicate = NSComparisonPredicate.init(leftExpression: lhs,
                                                        rightExpression: rhs,
                                                        modifier: NSComparisonPredicate.Modifier.direct,
                                                        type: NSComparisonPredicate.Operator.equalTo,
                                                        options: NSComparisonPredicate.Options.diacriticInsensitive)
        
        return q
    }


}
