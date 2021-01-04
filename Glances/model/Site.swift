//
//  Site.swift
//  Glances
//
//  Created by 김동호 on 2020/12/14.
//

import Kanna
import Foundation
import RealmSwift

let db = try! Realm()
let html = "<html>...</html>"

class Site: Object {

    @objc dynamic var id = 0
    @objc dynamic var url = ""
    @objc dynamic var name = ""
    @objc dynamic var xpath = ""
    static let regex = try! NSRegularExpression(pattern: "[ \n\t\r]+")

    override init() {}
    
    init(url: String, name: String, xpath: String) {
        self.id = (db.objects(Site.self).map { $0.id }.max() ?? -1) + 1
        self.url = url
        self.name = name
        self.xpath = xpath
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override class func ignoredProperties() -> [String] {
        return ["regex"]
    }

    static func getEncoding(encoding encodingName: String) -> String.Encoding? {
        
        switch encodingName {
        case "utf-8":
            return .utf8

        case "euc-kr":
            return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))

        default:
            return nil
        }
    }

    static func crawl(href: String, xpath: String, completionHandler: @escaping (String) -> Void) {
        
        guard let href = href.components(separatedBy: "://").last,
              let url = URL(string: "http://" + href) ?? URL(string: "https://" + href)
        else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

            // TODO: Kanna parses CSS attribute as text
            // TODO: can't crawl JS generated text
            guard let data = data,
                  let response = response,
                  error == nil,
                  let name = response.textEncodingName,
                  let encoding = getEncoding(encoding: name),
                  let html = try? HTML(html: data, encoding: encoding),
                  let text = html.xpath(xpath).first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            else {
                DispatchQueue.main.async {
                    completionHandler("-")
                }
                return
            }

            let result = NSMutableString(string: text)
            regex.replaceMatches(in: result, range: NSRange(0..<text.count), withTemplate: " ")

            DispatchQueue.main.async {
                completionHandler(String(result))
            }
        }
        
        task.resume()
    }
}
