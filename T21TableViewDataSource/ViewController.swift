//
//  ViewController.swift
//  T21TableViewDataSource
//
//  Created by Eloi Guzmán Cerón on 17/01/17.
//  Copyright © 2017 Worldline. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let dataSource = TableViewDataSource<DataSourceItem>()
    
    private var sortingFunctionType : Bool = false
    
    @IBOutlet
    weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.cellForRowFunction = { (tableview, indexpath, item) in
            
            var cell = tableview.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
            }
            
            let title = item.value as! String
            cell?.textLabel?.text = title
            return cell!
        }
        
        
        dataSource.tableView = tableView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction
    func buttonAddRowPressed() {
        let r = drand48()
        let di = DataSourceItem("Title: \(String(format: "%.4f", r))",String(format: "%.4f", r),Float(r))
        dataSource.addItems([di])
    }
    
    @IBAction
    func buttonRemoveRowPressed() {
        if dataSource.count > 0 {
            let row = Int(arc4random_uniform(UInt32(dataSource.count)))
            let oldItem = dataSource[row]!
            dataSource.removeItems([oldItem])
        }
    }
    
    @IBAction
    func buttonRefreshRowPressed() {
        if dataSource.count > 0 {
            let row = Int(arc4random_uniform(UInt32(dataSource.count)))
            let oldItem = dataSource[row]!
            let r = drand48()
            
            let newItem = DataSourceItem("Title: \(String(format: "%.4f", r))",oldItem.uid,oldItem.index)
            dataSource.addItems([newItem])
        }
    }
    
    @IBAction
    func buttonAddRowsPressed() {
        var newItems = [DataSourceItem]()
        for _ in 0..<5 {
            let r = drand48()
            let di = DataSourceItem("Title: \(String(format: "%.4f", r))",String(format: "%.4f", r),Float(r))
            newItems.append(di)
        }
        dataSource.addItems(newItems)
    }
    
    @IBAction
    func buttonRemoveRowsPressed() {
        if dataSource.count > 0 {
            var removeItems = [DataSourceItem]()
            for _ in 0..<5 {
                let row = Int(arc4random_uniform(UInt32(dataSource.count)))
                let oldItem = dataSource[row]!
                removeItems.append(oldItem)
            }
            dataSource.removeItems(removeItems)
        }
    }
    
    @IBAction
    func buttonRefreshRowsPressed() {
        if dataSource.count > 0 {
            var refreshItems = [DataSourceItem]()
            for _ in 0..<5 {
                let row = Int(arc4random_uniform(UInt32(dataSource.count)))
                let oldItem = dataSource[row]!
                let r = drand48()
                let newItem = DataSourceItem("Title: \(String(format: "%.4f", r))",oldItem.uid,oldItem.index)
                refreshItems.append(newItem)
            }
            
            dataSource.addItems(refreshItems)
        }
    }
    
    @IBAction
    func buttonChangeSortingFunctionPressed() {
        if sortingFunctionType {
            dataSource.sortingFunction = { return $0 < $1 }
        } else {
            dataSource.sortingFunction = { return $1 < $0 }
        }
        sortingFunctionType = !sortingFunctionType
    }
    
    
}

