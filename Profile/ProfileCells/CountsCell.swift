//
//  CountsCell.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 02/08/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit
import SwiftyJSON

class CountsCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(params:JSON?) {
        if params != nil {
            let type = params!["type"].stringValue.lowercaseString
            typeLabel.text = type.uppercaseString
            numberLabel.text = String(params!["number"].intValue)
            if let category = DiscoveryCategory(rawValue: type.capitalizedString) {
                numberLabel.backgroundColor = category.color()
            }
            else {
                numberLabel.backgroundColor = UIColor.darkGrayColor()
            }
            if let image = UIImage(named: "cat-icon-"+type) {
                typeImageView.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                typeImageView.tintColor = UIColor.whiteColor()
            }
            else {
                typeImageView.image = nil
            }
            
        }
        
    }

}
