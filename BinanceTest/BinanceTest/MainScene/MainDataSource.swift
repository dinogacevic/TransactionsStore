//
//  MainDataSource.swift
//  BinanceTest
//
//  Created by Dino Gacevic on 22/03/2023.
//

import UIKit

class MainDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var currentKey: String?
    var currentValue: String?
    
    var tableViewData: [ViewModel] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch tableViewData[indexPath.row] {
        case is ActionTextCellViewModel:
            cell = self.tableView(tableView, actionTextCellForRowAt: indexPath)
            
        case is TextCellViewModel:
            cell = self.tableView(tableView, textCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, actionTextCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionTextCell.cellId, for: indexPath) as? ActionTextCell,
              let model = tableViewData[indexPath.row] as? ActionTextCellViewModel else {
            return UITableViewCell()
        }
        
        cell.setup(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, textCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.cellId, for: indexPath) as? TextCell,
              let model = tableViewData[indexPath.row] as? TextCellViewModel else {
            return UITableViewCell()
        }
        
        cell.setup(with: model)
        
        return cell
    }
}
