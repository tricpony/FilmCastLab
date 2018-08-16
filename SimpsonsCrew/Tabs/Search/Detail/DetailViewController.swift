//
//  DetailViewController.swift
//  FilmCastLab
//
//  Created by aarthur on 8/15/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class DetailViewController: BaseViewController {
    @IBOutlet weak var emptySelectionLabel: UILabel!
    @IBOutlet weak var actorImageView: UIImageView!
    @IBOutlet weak var actorTitle: UILabel!
    @IBOutlet weak var actorProfile: UILabel!
    
    var actor: Actor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }

    func configUI() {
        let iconAddress = self.actor?.iconURL
        var image: UIImage?
        
        if (iconAddress == nil || (iconAddress?.isEmpty)!) {
            image = UIImage(named: "Members_tab", in: Bundle.main, compatibleWith: nil)
            self.actorImageView.image = image
        }else{
            let iconUrl = URL.init(string: iconAddress!)

            ServiceManager.startImageService(at: iconUrl!) { (error: Error?, data: Data?) in
                
                if error != nil {
                    let nserror = error! as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                if data != nil {
                    image = UIImage.init(data: data!)
                    
                    DispatchQueue.main.async {
                        self.actorImageView.image = image
                    }

                }else{
                    image = UIImage(named: "Members_tab", in: Bundle.main, compatibleWith: nil)
                    DispatchQueue.main.async {
                        self.actorImageView.image = image
                    }
                }
                
            }
        }
        self.actorTitle.text = self.actor?.name
        self.actorProfile.text = self.actor?.profile
        if UIDevice().userInterfaceIdiom == .phone {
            var done: UIBarButtonItem
            
            //on the non-plus phone size class the split view detail expands as a modal, presenting buttom to top
            //unclear if this is caused by a flaw in my code or Apple or if it is expected behavior
            //but I could never force a normal push navigation without breaking another size class
            //consequently, unless we add this button there is no way back to the master view controller
            done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(dismissCompactModal))
//            done = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(DetailViewController.dismissCompactModal))
            self.navigationItem.leftBarButtonItem = done
        }

    }
    
    @objc func dismissCompactModal() {
        self.dismiss(animated: true, completion: nil)
    }

}
