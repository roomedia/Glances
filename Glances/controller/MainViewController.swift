//
//  ViewController.swift
//  Glances
//
//  Created by 김동호 on 2020/12/14.
//

import Cocoa
import RealmSwift

class MainViewController: NSViewController {

    @IBOutlet weak var siteCollection: NSCollectionView!
    @IBOutlet weak var removeItemButton: NSButton!
    
    let siteItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "siteItemIdentifier")
    var realm = try? Realm()
    lazy var sites = realm?.objects(Site.self).sorted(byKeyPath: "id", ascending: false)
// release
//    var realm = try! Realm()
//    lazy var sites = realm.objects(Site.self).sorted(byKeyPath: "id", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDBatDebug()
    }

    func configureCollectionView() {
        siteCollection.dataSource = self
        siteCollection.register(SiteItem.self, forItemWithIdentifier: siteItemIdentifier)
    }
    
    // reset database for debug
    func configureDBatDebug() {
        if realm != nil { return }
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        try! FileManager.default.removeItem(at: realmURL)
        realm = realm!
    }
    
    @IBAction func didRemoveClicked(_ sender: NSButton) {
        if siteCollection.selectionIndexes.count == 0 { return }
        
        // delete item from DB
        try? realm?.write {
            siteCollection.selectionIndexes.reversed().forEach {
                realm!.delete(sites![$0])
            }
        }
        
        // delete item from UI
        siteCollection.animator().performBatchUpdates {
            siteCollection.deleteItems(at: Set(siteCollection.selectionIndexPaths))
        }
    }
}

extension MainViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return sites?.count ?? 0
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: siteItemIdentifier, for: indexPath) as! SiteItem
        let site = sites![indexPath.item]

        item.name.stringValue = site.name
        item.url.stringValue = site.url
        item.xpath.stringValue = site.xpath
        Site.crawl(href: site.url, xpath: site.xpath) { result in
            item.preview.stringValue = result
        }
        return item
    }
}
