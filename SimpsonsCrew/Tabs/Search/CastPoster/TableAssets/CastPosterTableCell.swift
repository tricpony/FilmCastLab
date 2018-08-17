//
//  CastPosterTableCell.swift
//  FilmCastLab
//
//  Created by aarthur on 8/17/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class CastPosterTableCell: UITableViewCell {
    @IBOutlet weak var actorImageView: UIImageView!
    @IBOutlet weak var widthContraint: NSLayoutConstraint!
    static let cell_id = "CastPosterTableCell"
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.widthContraint.constant = (self.actorImageView.image?.size.width)!
        self.heightConstraint.constant = (self.actorImageView.image?.size.height)!
    }
    
}
