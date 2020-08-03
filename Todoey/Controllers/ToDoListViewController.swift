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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
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
               print("Error while saving context!")
           }
           
           tableView.reloadData()
       }
       
   //MARK: - Load Items
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let query = searchBar.text! //never nil
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
    }
}
