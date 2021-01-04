//
//  AddViewController.swift
//  Glances
//
//  Created by 김동호 on 2020/12/19.
//

import Cocoa
import RealmSwift

class AddViewController: NSViewController {

    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var url: NSTextField!
    @IBOutlet weak var xpath: NSTextField!
    @IBOutlet weak var preview: NSTextField!

    @IBOutlet weak var cancel: NSButton!
    @IBOutlet weak var add: NSButton!
    
    var site: Site?
    var index: IndexPath?
    var isUpdate = false
    var siteCollection: NSCollectionView?

    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        name.delegate = self
        url.delegate = self
        xpath.delegate = self
    }
    
    override func viewWillLayout() {
        guard isUpdate == true,
              let name = name?.stringValue,
              let url = url?.stringValue,
              let xpath = xpath?.stringValue
        else {
            return
        }
        
        site = realm.objects(Site.self).filter {
            $0.name == name && $0.url == url && $0.xpath == xpath
        }.first
        Site.crawl(href: url, xpath: xpath) { result in
            self.preview.stringValue = result
        }
    }

    @IBAction func cancelDidClicked(_ sender: NSButton) {
        dismiss(self)
    }

    @IBAction func addDidClicked(_ sender: Any) {
        // check all required filled
        guard let name = validate(textfield: name),
              let url = validate(textfield: url),
              let xpath = validate(textfield: xpath),
              add.isEnabled == true
        else { return }

        // process item into DB & UI
        if isUpdate {
            update(name: name, url: url, xpath: xpath)
        } else {
            insert(name: name, url: url, xpath: xpath)
        }

        // destroy popup
        dismiss(self)
    }
    
    func update(name: String, url: String, xpath: String) {
        guard let site = site,
              let index = index,
              let siteCollection = siteCollection
        else {
            return
        }
        
        // update item to DB
        try? realm.write {
            site.name = name
            site.url = url
            site.xpath = xpath
            realm.add(site, update: .modified)
        }

        // update item to UI
        siteCollection.animator().performBatchUpdates {
            siteCollection.reloadItems(at: Set(arrayLiteral: index))
        }
    }

    func insert(name: String, url: String, xpath: String) {
        // insert item to DB
        try? realm.write {
            site = Site(url: url, name: name, xpath: xpath)
            realm.add(site!, update: .modified)
        }
    
        // insert item to UI
        siteCollection = (presentingViewController as! MainViewController).siteCollection!
        siteCollection!.animator().performBatchUpdates {
            siteCollection!.insertItems(at: Set(arrayLiteral: IndexPath(item: 0, section: 0)))
        }
    }

    // TODO: Enter to submit if condition fulfilled
}

extension AddViewController: NSTextFieldDelegate {
    // check all required filled to enable add button
    func controlTextDidChange(_ obj: Notification) {
        
        guard validate(textfield: name) != nil,
              let url = validate(textfield: url),
              let xpath = validate(textfield: xpath)
        else {
            add.isEnabled = false
            return
        }
        add.isEnabled = true
        
        switch obj.object as! NSTextField {
        case self.url:
            Site.crawl(href: url, xpath: xpath) { result in
                self.preview.stringValue = result
            }
        case self.xpath:
            Site.crawl(href: url, xpath: xpath) { result in
                self.preview.stringValue = result
            }
        default:
            break
        }
    }

    // verify textfield, return nil or text
    func validate(textfield: NSTextField?) -> String? {
        guard let text = textfield?.stringValue.trimmingCharacters(in: .whitespacesAndNewlines),
              text.isEmpty == false
        else {
            return nil
        }
        return text
    }
}
