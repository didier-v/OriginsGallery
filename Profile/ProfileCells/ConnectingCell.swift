//
//  ConnectingCell.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 17/05/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit

class ConnectingCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.startAnimating()
    }


}
