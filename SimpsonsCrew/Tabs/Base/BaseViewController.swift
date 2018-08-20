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

    typealias MethodType = (_ image: UIImage)  -> Void

    func loadIconImage(at address: String?,
                         imageView: UIImageView? = nil,
                         pinwheel: UIActivityIndicatorView? = nil,
                         placeholderImageName: String = "",
                         indexPath: IndexPath? = nil,
                         completion: MethodType? = nil) {
        let iconAddress = address
        var image: UIImage?
        
        if (iconAddress == nil || (iconAddress?.isEmpty)!) {
            image = UIImage(named: placeholderImageName, in: Bundle.main, compatibleWith: nil)
            if imageView != nil {
                imageView!.image = image
            }
            
            if (completion != nil) {
                completion!(image!)
            }
        }else{
            let iconUrl = URL.init(string: iconAddress!)
            
            if pinwheel != nil {
                pinwheel!.isHidden = false
                pinwheel!.startAnimating()
            }
            ServiceManager.startImageService(at: iconUrl!) { (error: Error?, data: Data?) in
                
                if error != nil {
                    let nserror = error! as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                if data != nil {
                    image = UIImage.init(data: data!)
                    
                    DispatchQueue.main.async {
                        if imageView != nil {
                            pinwheel!.isHidden = true
                            pinwheel!.stopAnimating()
                            imageView!.image = image
                        }
                        
                        if (completion != nil) {
                            if indexPath == nil {
                                completion!(image!)
                            }else{
                                completion!(image!)
                            }
                        }
                    }

                }else{
                    image = UIImage(named: placeholderImageName, in: Bundle.main, compatibleWith: nil)
                    DispatchQueue.main.async {
                        if imageView != nil {
                            imageView!.image = image
                        }
                        
                        if (completion != nil) {
                            completion!(image!)
                        }

                    }
                }
            }
        }
    }

    @objc func dismissCompactModal() {
        self.dismiss(animated: true, completion: nil)
    }

}
