//
//  ViewController.swift
//  Todoey
//
//  Created by Artem Tkachuk on 8/2/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemsArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Add button pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            //Initialize the new item
            let newItem = Item(context: self.context)
            newItem.title = textField.text! //never nil ==> we can force unwrap
            newItem.done = false    //all tasks are not completed by default
            newItem.parentCategory = self.selectedCategory
                        
            if newItem.title != "" {    //TODO other validation here
                self.itemsArray.append(newItem)
                self.saveItems()
            }
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
        return itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Items.itemCellID, for: indexPath)
        let item = itemsArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        context.delete(itemsArray[indexPath.row])
        //        itemsArray.remove(at: indexPath.row)
        
        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Save Items
       func saveItems() {
           do {
               try context.save()
           } catch {
               print("Error while saving context, \(error)")
           }
           
           tableView.reloadData()
       }
       
   //MARK: - Load Items
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), _ predicate: NSPredicate? = nil) {
        let categorypredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categorypredicate, additionalPredicate])
        } else {
            request.predicate = categorypredicate
        }
        
        do {
           itemsArray = try context.fetch(request)
        } catch {
           print("Error while fetching data from the context, \(error)")
        }
        
        tableView.reloadData()
   }
}



//MARK: - Search bar methods
extension ToDoListViewController: UISearchBarDelegate {
    //MARK: - Search button clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.delegate?.searchBar?(searchBar, textDidChange: searchBar.text!)
    }
    
    //MARK: - Text did change
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Erase button clicked
        if searchText.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            queryDB(with: searchText)
        }
    }
    
    //MARK: - query DB
    func queryDB(with query: String) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        
        loadItems(with: request, predicate)
    }
}
