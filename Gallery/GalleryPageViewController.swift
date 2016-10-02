//
//  GalleryPageViewController.swift
//  NMSOrigins
//
//  Created by Didier Vandekerckhove on 15/05/2016.
//  Copyright © 2016 didierv. All rights reserved.
//

import UIKit


class GalleryPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var images:[String] = [] // datasource
    var youtubeId:String = ""
    var currentImage:Int = 0
    var pageIsAnimating:Bool=false // detection de l'animation page qui change
    var galleryOverlayView: GalleryOverlayView?
    var overlayIsVisible:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate=self
        self.dataSource=self
        currentImage = 0
        
        
        galleryOverlayView = (NSBundle.mainBundle().loadNibNamed("GalleryOverlayView", owner: self, options: nil)[0] as! GalleryOverlayView)
        galleryOverlayView?.galleryController = self
        galleryOverlayView?.frame.size.width = self.view.frame.size.width
        galleryOverlayView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        galleryOverlayView?.updateTitle("\(currentImage+1)/\(images.count)")
        self.view.addSubview(galleryOverlayView!)
        overlayIsVisible = true
        
        
         if let vc = createViewController(currentImage) {
            self.setViewControllers([vc], direction: .Forward, animated: true, completion: nil)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
    
    func createViewController(image:Int?) -> UIViewController? {
        if image != nil {
            let storyboard = UIStoryboard(name: "Gallery", bundle: nil)
            
            if !youtubeId.isEmpty && image==0 {
                let vc:VideoViewController = storyboard.instantiateViewControllerWithIdentifier("VideoViewController") as! VideoViewController
                vc.youtubeId = youtubeId
                return vc
            }
            else {
                let vc:GalleryViewController = storyboard.instantiateViewControllerWithIdentifier("GalleryViewController") as! GalleryViewController
                vc.image=images[image!]
                vc.imageIndex = image!
                vc.pageViewController = self

                return vc
            }
        }
        return nil
    }
    
    
    func didTouchOverlay(touch:UITouch) -> Bool {
        if(overlayIsVisible) {
            let point = touch.locationInView(galleryOverlayView)
            let width = galleryOverlayView!.frame.size.width
            let rect = CGRect(origin: CGPoint(x: width-44, y: 0),
                              size: CGSize(width: 44, height: 44)
                )
            // simulate close button click (bug with landscape mode)
            if CGRectContainsPoint(rect, point) {
                self.backToDiscovery()
                return true
            }
            
            return false //point.y <= galleryOverlayView?.toolBar.frame.height
            
        }
        return false
    }

    // MARK: - Actions

    @IBAction func didTap(sender: AnyObject) {
        if overlayIsVisible {
            galleryOverlayView?.removeFromSuperview()
        }
        else {
            galleryOverlayView?.frame.size.width = self.view.frame.size.width
            self.view.addSubview(galleryOverlayView!)
        }
        overlayIsVisible = !overlayIsVisible
    }

    // MARK: - Delegate
    
    func pageViewController(pageViewController: UIPageViewController,
                            willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pageIsAnimating=true
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        pageIsAnimating=false
        if let vc = pageViewController.viewControllers![0] as? GalleryViewController {
            currentImage = images.indexOf(vc.image!)!
            galleryOverlayView?.updateTitle("\(currentImage+1)/\(images.count)")
        }
        else if let _ = pageViewController.viewControllers![0] as? VideoViewController {
            currentImage = 0
        }
        
    }
    
    // MARK: - DataSource
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if(pageIsAnimating) { // jamais pendant une animation
            return nil
        }
        if(currentImage<=0) { // pas de page précédente
            return nil
        }
        
        if let vc = viewController as? GalleryViewController {
            if let d = images.indexOf(vc.image!) {
                return createViewController(d-1)
            }
        }
        else {
            if let _ = viewController as? VideoViewController {
                return nil
            }
        }

        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if(pageIsAnimating) { // jamais pendant une animation
            return nil
        }
        if(currentImage>=images.count-1) { // pas de page suivante
            return nil
        }
        
        if let vc = viewController as? GalleryViewController {
            if let d = images.indexOf(vc.image!) {
                return createViewController(d+1)
            }
        }
        else {
            if let _ = viewController as? VideoViewController {
                return createViewController(1)
            }
        }
        return nil
    }
    
    
    // MARK: - Navigation

    func backToDiscovery() {
        performSegueWithIdentifier("backToDiscoveryViewController", sender: self)        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    //}


}
