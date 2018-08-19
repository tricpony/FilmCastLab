//
//  SearchViewController.swift
//  FilmCastLab
//
//  Created by aarthur on 8/15/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    lazy var unfilteredFetchedResultsController: NSFetchedResultsController<Actor> = {
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
    
    func filteredFetchedResultsController() -> NSFetchedResultsController<Actor> {
        let fetchRequest = CoreDataUtility.fetchRequestForActorsContaining(searchTerm: searchController.searchBar.text!, ctx: self.managedObjectContext)
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
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<Actor> {
        let unfilteredFetchedResultsController = self.unfilteredFetchedResultsController
        let filteredFetchedResultsController = self.filteredFetchedResultsController
        
        if isFiltering() {
            return filteredFetchedResultsController()
        }
        
        return unfilteredFetchedResultsController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this will prevent bogus separator lines from displaying in an empty table
        self.tableView.tableFooterView = UIView()
        self.navigationItem.title = "Search"

        self.performCastService()
    }

    func setupSearchController() {
        
        //on initial launch of app we make the service call to fetch the data which returns in a closure
        //in that case we must force the execution of this logic on the main thread to prevent a crash
        //on every launch thereafter setupSearchController gets called on the main thread and this GCD
        //call really does not matter
        DispatchQueue.main.async {
            self.searchController.searchResultsUpdater = self
            self.searchController.obscuresBackgroundDuringPresentation = false
            self.searchController.searchBar.placeholder = "Search"
            self.searchController.searchBar.barTintColor = UIColor.black
            self.tableView.tableHeaderView = self.searchController.searchBar
            self.definesPresentationContext = true
        }
    }
    
    /**
     This makes the service call and fetches the cast data
     It will only perform the service call if there are no actor records in core data
     After the service is done and data is loaded we install the search bar or if we
     need not perform the service the bar is installed
    **/
    func performCastService() {
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
                self.setupSearchController()
            }
        }else{
            self.setupSearchController()
        }
    }
    
    // MARK: - Icon Presentation
    
    @IBAction func flip(_ sender: Any) {
        
        if self.splitViewController?.traitCollection.horizontalSizeClass == .regular {
            self.performSegue(withIdentifier: "castPosterSeque", sender: self)
        }else{
            let sb = UIStoryboard.init(name: "CastPosterViewController", bundle: nil)
            let destinationViewController = sb.instantiateInitialViewController()
            
            destinationViewController?.modalPresentationStyle = .custom
            destinationViewController?.transitioningDelegate = self
            self.present(destinationViewController!, animated: true, completion: nil)
        }
    }

    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.reloadData()
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
        return "ActorTitleCell"
    }
    
    func nextCellForTableView(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(at: indexPath))
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: self.cellIdentifier(at: indexPath))
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController().sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController().sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.nextCellForTableView(tableView, at: indexPath)
        let actor: Actor = fetchedResultsController().object(at: indexPath)
        
        if (isFiltering()) {
            let highlightedSearchTerm = NSMutableAttributedString(string: actor.name!)
            let range = actor.name?.range(of: searchController.searchBar.text!)
            
            highlightedSearchTerm.addAttribute(.backgroundColor,
                                               value: UIColor.yellow,
                                               range: NSRange.init(location: (range?.lowerBound.encodedOffset)!,
                                                                   length: (range?.upperBound.encodedOffset)! - (range?.lowerBound.encodedOffset)!))
            cell.textLabel?.attributedText = highlightedSearchTerm
            
        }else{
            cell.textLabel!.text = actor.name
        }
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }

    // MARK: - Storyboard

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "actorDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let actor: Actor = fetchedResultsController().object(at: indexPath)
                let vc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                vc.actor = actor
                vc.navigationItem.title = "Simpsons Cast Member"
                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                vc.navigationItem.leftItemsSupplementBackButton = true
                
                //this clears the title of the back button to leave only the chevron
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }
    }

}

extension SearchViewController: UIViewControllerTransitioningDelegate {
    /**
     This supports a custom controller transition executed by tapping the nav-bar button
    **/
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            
            let x: CGFloat = 55.0
            let y: CGFloat = 50.0
            let w: CGFloat = self.tableView.bounds.size.width - x
            let h: CGFloat = self.tableView.bounds.size.height - y

            let frame = CGRect(
                origin: CGPoint(x: x, y: y),
                size: CGSize(width: w, height: h)
            )

            return FlipPresentAnimationController(originFrame: frame)
    }
}

