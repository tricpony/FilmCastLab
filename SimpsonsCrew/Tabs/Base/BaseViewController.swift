//
//  BaseViewController.swift
//  SimpsonsCrew
//
//  Created by aarthur on 8/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    lazy var managedObjectContext: NSManagedObjectContext = {
        MagicalRecord.setupCoreDataStack(withStoreNamed:"FilmCast")
        return NSManagedObjectContext.mr_default()
    }()

    class func sizeClass() -> (vertical: UIUserInterfaceSizeClass, horizontal: UIUserInterfaceSizeClass) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window: UIWindow = appDelegate.window!
        let vSizeClass: UIUserInterfaceSizeClass!
        let hSizeClass: UIUserInterfaceSizeClass!
        
        hSizeClass = window.traitCollection.horizontalSizeClass
        vSizeClass = window.traitCollection.verticalSizeClass
        
        return (vertical: vSizeClass, horizontal: hSizeClass)
    }
    
    func sizeClass() -> (vertical: UIUserInterfaceSizeClass, horizontal: UIUserInterfaceSizeClass) {
        return BaseViewController.sizeClass()
    }

    func handleIconImage(at address: String?, imageView: UIImageView) {
        let iconAddress = address
        var image: UIImage?
        
        if (iconAddress == nil || (iconAddress?.isEmpty)!) {
            image = UIImage(named: "Members_tab", in: Bundle.main, compatibleWith: nil)
            imageView.image = image
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
//                        self.pinWheel.isHidden = true
//                        self.pinWheel.stopAnimating()
                        imageView.image = image
                    }

                }else{
                    image = UIImage(named: "Members_tab", in: Bundle.main, compatibleWith: nil)
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }
        }
    }

}
