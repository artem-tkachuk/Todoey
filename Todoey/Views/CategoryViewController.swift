//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Artem Tkachuk on 8/2/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categoriesArray = [Category]()
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //MARK: - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Todoey category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            //Initialize the new category
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            if newCategory.name != "" {
                self.categoriesArray.append(newCategory)
                self.saveCategories()
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create a new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Categories.categoryCellID, for: indexPath)
        cell.textLabel?.text = categoriesArray[indexPath.row].name
        return cell
    }
    
    //MARK: - Save items
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error while savin the context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Load items
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoriesArray = try context.fetch(request)
        } catch {
            print("Error while fetching data from the context, \(error)")
        }
        
        tableView.reloadData()
    }

    //MARK: - TableView delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Categories.goToItemsSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Categories.goToItemsSegueID {
            let destinationVC = segue.destination as! ToDoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoriesArray[indexPath.row]
            }
        }
    }
}
