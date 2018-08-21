//
//  CastPosterViewController.swift
//  FilmCastLab
//
//  Created by aarthur on 8/17/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class CastPosterViewController: BaseViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    lazy var fetchedResultsController: NSFetchedResultsController<Actor> = {
        let fetchRequest = CoreDataUtility.fetchRequestForAllActors(ctx: self.managedObjectContext)
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
    
    func registerTableAssets() {
        var nib: UINib!
        
        nib = UINib.init(nibName: "CastPosterTableCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: CastPosterTableCell.cell_id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerTableAssets()
        //enable auto cell height that uses constraints
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 110;

        if self.splitViewController?.traitCollection.horizontalSizeClass != .regular {
            var done: UIBarButtonItem

            done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(dismissCompactModal))
            self.navigationItem.leftBarButtonItem = done
        }
        self.preLoadCastImages()
    }
    
    /**
     Pre-load cast images starting with the last one in the fetch results controller in a background thread to keep table scrolling smooth
     This allows the table view to carry some of the load as it loads the first cells
     Once preLoadCastImages finds an actor that already has loaded its image then we assume there are no others that need to be loaded
     so abort
    **/
    func preLoadCastImages() {
        var i = 0;
        guard let actorCount = self.fetchedResultsController.fetchedObjects?.count else{
            return
        }
        
        DispatchQueue.global(qos: .background).async {

            while i < actorCount {
                let indexPath = IndexPath.init(row: actorCount - (i+1), section: 0)
                let nextActor = self.fetchedResultsController.object(at: indexPath)
                
                if nextActor.transientImage == nil {
                    
                    self.loadIconImage(at: nextActor.iconURL,
                                       placeholderImageName: "Members_tab_small",
                                       completion: { (image) in
                                        DispatchQueue.main.async {
                                            nextActor.transientImage = image
                                        }

                    })
                    
                }else{
                    break
                }
                i += 1
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
        return CastPosterTableCell.cell_id
    }
    
    func nextCellForTableView(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(at: indexPath))
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: self.cellIdentifier(at: indexPath))
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CastPosterTableCell = self.nextCellForTableView(tableView, at: indexPath) as! CastPosterTableCell
        let actor: Actor = fetchedResultsController.object(at: indexPath)
        
        if actor.transientImage != nil {
            cell.actorImageView.image = actor.transientImage
            cell.configGeometry()
        }else{
            self.loadIconImage(at: actor.iconURL,
                                 imageView: cell.actorImageView!,
                                 pinwheel: cell.pinwheel!,
                                 placeholderImageName: "Members_tab_small",
                                 indexPath: indexPath,
                                 completion: { (image) in
                                    actor.transientImage = image
                                    tableView.beginUpdates()
                                    cell.configGeometry()
                                    tableView.endUpdates()
                                })
        }
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "actorDetailSegue", sender: indexPath)
    }
    
    // MARK: - Storyboard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "actorDetailSegue" {
            if let indexPath = sender as? IndexPath {
                let actor: Actor = fetchedResultsController.object(at: indexPath)
                let vc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                vc.actor = actor
                vc.forceDoneButton = self.splitViewController?.traitCollection.horizontalSizeClass != .regular
                vc.navigationItem.title = "Simpsons Cast Member"
                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                vc.navigationItem.leftItemsSupplementBackButton = true
                
                //this clears the title of the back button to leave only the chevron
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }
    }
    
}
