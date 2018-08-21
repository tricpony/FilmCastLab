//
//  CastPosterTableCell.swift
//  FilmCastLab
//
//  Created by aarthur on 8/17/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class CastPosterTableCell: UITableViewCell {
    static let cell_id = "CastPosterTableCell"

    @IBOutlet weak var actorImageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pinwheel: UIActivityIndicatorView!
    
    func configGeometry() {
        if (self.actorImageView.image != nil) {
            self.heightConstraint.constant = (self.actorImageView.image?.size.height)!
        }
    }
    
}
