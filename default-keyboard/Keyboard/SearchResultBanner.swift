//
//  SearchResultBanner.swift
//  TastyImitationKeyboard
//
//  Created by Abdulla Contractor on 10/10/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class SearchResultBanner: ExtraView, UITableViewDelegate, UITableViewDataSource {

    var resultTable: UITableView!
    var results: [String:String]!
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setNeedsLayout() {
        super.setNeedsLayout()
    }

    override func layoutSubviews() {

        super.layoutSubviews()

        self.resultTable = UITableView(frame: self.frame)
        self.resultTable.delegate = self
        self.resultTable.dataSource = self
        self.addSubview(resultTable)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
}
