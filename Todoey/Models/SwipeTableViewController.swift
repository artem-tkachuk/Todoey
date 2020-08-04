//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Artem Tkachuk on 8/3/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    //MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.swipeCellID, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    
    //MARK: - Edit Actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return nil
        }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
        }

        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    //MARK: - Edit Actions Options
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    //MARK: - Delete a category
    //This method will be overridden in the child classes
    func updateModel(at indexPath: IndexPath) {
        //Update our data model
    }
}
