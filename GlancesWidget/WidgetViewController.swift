//
//  WidgetViewController.swift
//  GlancesWidgetExtension
//
//  Created by 김동호 on 2021/01/04.
//

import Cocoa
import NotificationCenter

class WidgetViewController: NSViewController {

    @IBOutlet weak var label: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

extension WidgetViewController: NCWidgetProviding {
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        print(NCUpdateResult.newData)
        completionHandler(.newData)
    }
}
