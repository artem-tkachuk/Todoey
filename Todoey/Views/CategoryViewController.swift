//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Artem Tkachuk on 8/2/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    let realm = try! Realm()
    
    var categoriesArray: Results<Category>?
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Todoey category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //Initialize the new category
            let newCategory = Category()
            newCategory.name = textField.text!
            
            if newCategory.name != "" {
                self.save(what: newCategory)
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Save categories
    func save(what category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error while saving the context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Load categories
    func loadCategories() {
        categoriesArray = realm.objects(Category.self)
        tableView.reloadData()
    }

    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Categories.categoryCellID, for: indexPath)
        cell.textLabel?.text = categoriesArray?[indexPath.row].name ?? "No categories added yet"
        return cell
    }
    
    //MARK: - TableView delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Categories.goToItemsSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Categories.goToItemsSegueID {
            let destinationVC = segue.destination as! ToDoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoriesArray?[indexPath.row]
            }
        }
    }
}
