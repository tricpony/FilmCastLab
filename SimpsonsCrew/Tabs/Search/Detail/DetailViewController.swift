//
//  DetailViewController.swift
//  FilmCastLab
//
//  Created by aarthur on 8/15/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class DetailViewController: BaseViewController {
    @IBOutlet weak var pinWheel: UIActivityIndicatorView!
    @IBOutlet weak var emptySelectionLabel: UILabel!
    @IBOutlet weak var actorImageView: UIImageView!
    @IBOutlet weak var actorTitle: UILabel!
    @IBOutlet weak var actorProfile: UILabel!
    @IBOutlet weak var actorImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var actorImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoritesNavBarItem: UIBarButtonItem!
    
    var actor: Actor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }

    func configUI() {
        self.pinWheel.isHidden = true
        if self.actor == nil {
            self.emptySelectionLabel.isHidden = false
        }else{
            let iconAddress = self.actor?.iconURL
            var image: UIImage?
            var sceneTitle: String = (self.actor?.name)!
            
            if (iconAddress == nil || (iconAddress?.isEmpty)!) {
                image = UIImage(named: "Members_tab", in: Bundle.main, compatibleWith: nil)
                self.actorImageView.image = image
                self.actorImageView.alpha = 0.7
                sceneTitle += "\n( Image Unavailable )"
            }else{
                let iconUrl = URL.init(string: iconAddress!)

                self.pinWheel.isHidden = false
                self.pinWheel.stopAnimating()
                
                ServiceManager.startImageService(at: iconUrl!) { (error: Error?, data: Data?) in
                    
                    if error != nil {
                        let nserror = error! as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    if data != nil {
                        image = UIImage.init(data: data!)
                        
                        DispatchQueue.main.async {
                            self.pinWheel.isHidden = true
                            self.pinWheel.stopAnimating()
                            self.actorImageView.image = image
                            self.actorImageWidthConstraint.constant = (image?.size.width)!
                            self.actorImageHeightConstraint.constant = (image?.size.height)!
                        }

                    }else{
                        image = UIImage(named: "Members_tab", in: Bundle.main, compatibleWith: nil)
                        DispatchQueue.main.async {
                            self.actorImageView.image = image
                        }
                    }
                    
                }
            }
            self.actorTitle.text = sceneTitle
            self.actorProfile.text = self.actor?.profile
            if Display.isIphone() {
                var done: UIBarButtonItem
                
                //on the non-plus phone size class the split view detail expands as a modal, presenting buttom to top
                //unclear if this is caused by a flaw in my code or Apple or if it is expected behavior
                //but I could never force a normal push navigation without breaking another size class
                //consequently, unless we add this button there is no way back to the master view controller
                done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(dismissCompactModal))
                self.navigationItem.leftBarButtonItem = done
            }
        }
        if self.actor?.isFavorite() == true {
            self.favoritesNavBarItem.image = UIImage.init(named: "star-filled")
        }
    }
    
    @objc func dismissCompactModal() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func toggleStatusFavorite(_ sender: Any) {
        
        if (self.actor == nil) {
            return
        }
        
        if self.actor?.isFavorite() == true {
            self.managedObjectContext.delete((self.actor?.favorite)!)
            self.favoritesNavBarItem.image = UIImage.init(named: "star-empty")
        }else{
            let fav = Favorite.mr_createEntity(in: self.managedObjectContext)!
            self.actor?.favorite = fav
            self.favoritesNavBarItem.image = UIImage.init(named: "star-filled")
        }
        self.managedObjectContext.mr_saveToPersistentStoreAndWait()
    }

}
