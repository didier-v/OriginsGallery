//
//  GalleryViewController.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 15/05/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class GalleryViewController: UIViewController, UIGestureRecognizerDelegate {

    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet var singleTapGesture: UITapGestureRecognizer!
    @IBOutlet var doubleTapGesture: UITapGestureRecognizer!
    
    var image:String?
    var imageIndex: Int!
    var needsZoomUpdate:Bool = false
    var pageViewController:GalleryPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        let imageDownloader = UIImageView.af_sharedImageDownloader
        let imageCache = imageDownloader.imageCache

        if (image != nil) && (image != "") {
            if let cachedImage = imageCache!.imageWithIdentifier(image!) {
                imageView.image = cachedImage
                scrollView.zoomScale = 1
                updateZoom()
            }
            else {
                activityIndicator.startAnimating()
                Alamofire.request(.GET, image!)
                    .responseImage { response in
                        self.activityIndicator.stopAnimating()
                        switch (response.result) {
                        case .Success(let img):
                            //                    debugPrint(response)
                            //                    print(response.request)
                            //                    print(response.response)
                            //                    debugPrint(response.result)
                                imageCache!.addImage(img, withIdentifier: self.image!)
                            self.imageView.image = img
                            self.updateZoom()
                        case .Failure(let error):
                            print("failed with error",error)
                        }
                }
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        if self.needsZoomUpdate {
           self.needsZoomUpdate  = false
            updateZoom()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Update zoom scale and constraints with animation. (rotation)
    override func viewWillTransitionToSize(size: CGSize,
                                           withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        let vc = self.pageViewController
        if self.imageIndex != vc.currentImage {
            if size != self.view.bounds.size {
                self.needsZoomUpdate = true
            }
        }

        coordinator.animateAlongsideTransition({ [weak self] _ in
            self?.updateZoom()
            }, completion: nil)

    }

    
    @IBAction func doubleTapZoom(sender: UITapGestureRecognizer) {
        toggleZoom()
    }
    
    @IBAction func singleTapScrollView(sender: UITapGestureRecognizer) {
        self.pageViewController.didTap(sender)
    }
    //MARK: - UIScrollViewDelegate
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    //MARK: - UIGestureRecognizerDelegate

    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
       return !pageViewController.didTouchOverlay(touch)
    }

    
    //MARK: -

    func updateZoom() {
        let height = view.bounds.size.height
        let width = view.bounds.size.width
        
        if let image = imageView.image {
            let minZoom = min(width / image.size.width,
                              height / image.size.height)
        
//            if minZoom > 1 { minZoom = 1 }
            
            scrollView.minimumZoomScale = minZoom
        
            scrollView.zoomScale = minZoom
        }
    }
    
    func toggleZoom() {
        if let image = imageView.image {
            let minZoom = min(scrollView.bounds.size.width / image.size.width,
                              scrollView.bounds.size.height / image.size.height)
            let maxZoom = max(scrollView.bounds.size.width / image.size.width,
                              scrollView.bounds.size.height / image.size.height)
            if scrollView.zoomScale < maxZoom {
                scrollView.zoomScale = maxZoom
            }
            else {
                scrollView.zoomScale=minZoom
            }
            

        }
    
    }
    
    func updateConstraints() {
        let viewHeight = view.bounds.size.height
        let viewWidth = view.bounds.size.width
        if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            // center image if it is smaller than the scroll view
            var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 { hPadding = 0 }
            
            var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 { vPadding = 0 }
            
            imageConstraintLeft.constant = hPadding
            imageConstraintRight.constant = hPadding
            
            imageConstraintTop.constant = vPadding
            imageConstraintBottom.constant = vPadding
            
            view.layoutIfNeeded()


        }
    }
    
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
