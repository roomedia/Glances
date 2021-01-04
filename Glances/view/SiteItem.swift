//
//  SiteItem.swift
//  Glances
//
//  Created by 김동호 on 2020/12/16.
//

import Cocoa

class SiteItem: NSCollectionViewItem {

    @IBOutlet weak var preview: NSTextField!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var url: NSTextField!
    @IBOutlet weak var xpath: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let area = NSTrackingArea(
            rect: self.view.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        self.view.addTrackingArea(area)
        self.view.wantsLayer = true
    }
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            if isSelected {
                colorAnimation(from: CGColor.clear, to: CGColor(gray: 0.3, alpha: 0.5))
            } else {
                colorAnimation(from: CGColor(gray: 0.3, alpha: 0.5), to: CGColor.clear)
            }
        }
    }
    
    func colorAnimation(from: CGColor, to: CGColor) {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = from
        animation.toValue = to
        self.view.layer?.add(animation, forKey: "color")
        view.layer?.backgroundColor = to
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        scaleAnimation(duration: 0.15, from: 1, to: 1.01)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        scaleAnimation(duration: 0.15, from: 1.01, to: 1)
    }

    func scaleAnimation(duration: CFTimeInterval, from: Float, to: Float) {
        let frame = self.view.layer?.frame
        self.view.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view.layer?.frame = frame!
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = from
        scaleAnimation.toValue = to
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = CAMediaTimingFillMode.forwards
        self.view.layer?.add(scaleAnimation, forKey: "scale")
    }
    
    // TODO: can't click sometimes after editing
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        // dismiss click once
        if event.clickCount < 2 {
            return
        }
        
        // open add site modal
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addViewController = storyboard.instantiateController(withIdentifier: "AddModalIdentifier") as! AddViewController
        presentAsModalWindow(addViewController)
        
        // set selected site info
        addViewController.name.stringValue = name.stringValue
        addViewController.url.stringValue = url.stringValue
        addViewController.xpath.stringValue = xpath.stringValue
        
        addViewController.isUpdate = true
        addViewController.siteCollection = collectionView
        addViewController.index = collectionView!.indexPath(for: self)
    }
}
