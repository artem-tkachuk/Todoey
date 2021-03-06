//
//  ViewController.swift
//  Todoey
//
//  Created by Artem Tkachuk on 8/2/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
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
    }
    
    //MARK: - viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            self.title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist.")
            }
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColor
                searchBar.searchBarStyle = UISearchBar.Style.minimal
//                searchBar.backgroundColor = navBarColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            }
        }
    }
    
    //MARK: - Add button pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            let currentText = textField.text!
            
            if currentText != "" {    //TODO other validation here
                let newItem = Item()
                newItem.title = textField.text! //never nil ==> we can force unwrap
                newItem.dateCreated = Date()
                self.save(what: newItem)
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new item"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Load Items
     func loadItems() {
         toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
         tableView.reloadData()
     }
    
    //MARK: - Save a new item
    func save(what newItem: Item) {
        if let currentCategory = self.selectedCategory {
            do {
                try self.realm.write {
                    currentCategory.items.append(newItem)
                }
            } catch {
                print("Error while savin the context, \(error)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let selectedItem = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(selectedItem)
                }
            } catch {
                print("Error while deleting items!")
            }
        }
    }
    
    //MARK: - TableView data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    //MARK: - Cell for row at
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            let categoryColor = UIColor(hexString: selectedCategory!.color)
            let darkeningPercentage = CGFloat(indexPath.row) / CGFloat(toDoItems!.count)
            
            if let darkenedColor = categoryColor?.darken(byPercentage: darkeningPercentage) {
                cell.backgroundColor = darkenedColor
                cell.textLabel?.textColor = ContrastColorOf(darkenedColor, returnFlat: true)
            }
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
