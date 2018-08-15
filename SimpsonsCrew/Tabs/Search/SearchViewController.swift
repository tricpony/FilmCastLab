//
//  SearchViewController.swift
//  FilmCastLab
//
//  Created by aarthur on 8/15/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    lazy var managedObjectContext: NSManagedObjectContext = {
        MagicalRecord.setupCoreDataStack(withStoreNamed:"FilmCast")
        return NSManagedObjectContext.mr_default()
    }()
    var serviceCallInFlight: Bool = false
    lazy var fetchedResultsController: NSFetchedResultsController<Actor> = {
        let fetchRequest = CoreDataUtility.fetchRequestForAllMovies(ctx: self.managedObjectContext)
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: self.managedObjectContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
        aFetchedResultsController.delegate = self
        
        do {
            try aFetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return aFetchedResultsController as! NSFetchedResultsController<Actor>
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if CoreDataUtility.fetchActorCount(ctx: self.managedObjectContext) == 0 {
            let serviceRequest = ServiceManager()
            
            serviceRequest.startService { (error: Error?, payload: Dictionary<String,Any>?) in
                if error != nil {
                    let nserror = error! as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }

                guard let content = payload?["RelatedTopics"] as? [Dictionary<String,Any>] else{print("error"); return}
                
                for item in content {
                    Actor.createActor(actorInfo: item, inContext: self.managedObjectContext)
                    self.managedObjectContext.mr_saveToPersistentStoreAndWait()
                }
            }
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Table View

    func cellIdentifier(at indexPath: IndexPath) -> String {
        return "ActorCell"
    }
    
    func nextCellForTableView(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(at: indexPath))
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: self.cellIdentifier(at: indexPath))
        }
        
        return cell!
    }
    
    func resultsSectionCount() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func resultsRowCount(in section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.resultsSectionCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultsRowCount(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.nextCellForTableView(tableView, at: indexPath)
        let actor: Actor = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel!.text = actor.name
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }

}
