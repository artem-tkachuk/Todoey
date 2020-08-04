//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Artem Tkachuk on 8/2/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    var categoriesArray: Results<Category>?
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        
        navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
    }
    
    //MARK: - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Todoey category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //Initialize the new category
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
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
    
    //MARK: - Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let selectedCategory = categoriesArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(selectedCategory)
                }
            } catch {
                print("Error while deleting the category, \(error)")
            }
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numCategories = (categoriesArray?.count)!
        return numCategories != 0 ? numCategories : 1
    }
    
    //MARK: - Cell for row at
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
        if categoriesArray?.count != 0 {
            if let category = categoriesArray?[indexPath.row] {
                cell.textLabel?.text = category.name
                guard let categoryColor = UIColor(hexString: category.color) else {
                    fatalError()
                }
                cell.backgroundColor = categoryColor
                cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            }
        } else {
            cell.textLabel?.text =  "No categories added yet"
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    //MARK: - TableView delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Categories.goToItemsSegueID, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Categories.goToItemsSegueID {
            let destinationVC = segue.destination as! ToDoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoriesArray?[indexPath.row]
            }
        }
    }
}

