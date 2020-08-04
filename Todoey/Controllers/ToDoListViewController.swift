//
//  ViewController.swift
//  Todoey
//
//  Created by Artem Tkachuk on 8/2/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    let realm = try! Realm()
    
    var toDoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedCategory?.name
    }
    
    //MARK: - Add button pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                if textField.text! != "" {    //TODO other validation here
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text! //never nil ==> we can force unwrap
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error while savin the context, \(error)")
                    }
                }
            }
            
             self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new item"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Items.itemCellID, for: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    //MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error while savong done status, \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   //MARK: - Load Items
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
   }
}



//MARK: - Search bar methods
extension ToDoListViewController: UISearchBarDelegate {
    //MARK: - Search button clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterItems(byQuery: searchBar.text!)
    }

    //MARK: - Text did change
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {  //Erase button clicked
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            filterItems(byQuery: searchText)
        }
    }
    
    //MARK: - Filter items
    func filterItems(byQuery query: String) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", query).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
}
