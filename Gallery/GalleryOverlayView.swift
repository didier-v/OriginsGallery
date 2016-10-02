//
//  GalleryOverlayView.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 21/07/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit

class GalleryOverlayView: UIView {
    var galleryController:GalleryPageViewController!

    
    @IBOutlet weak var overlayTitleButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!

    
    @IBAction func close(sender: UIBarButtonItem) {
        galleryController.backToDiscovery()
    }
    
    func updateTitle(text: String) {
        overlayTitleButton.title = text
    }
}
