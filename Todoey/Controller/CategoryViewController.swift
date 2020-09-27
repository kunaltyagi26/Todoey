//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Kunal Tyagi on 23/02/20.
//  Copyright © 2020 Kunal Tyagi. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    fileprivate var categories: [Category] = []
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    @objc func contextDidSave(_ notification: Notification) {
        print(notification)
        guard let childContext = notification.object as? NSManagedObjectContext else { return }
        if childContext.parent === context {
            guard let context = context else { return }
            context.performAndWait {
                do {
                    try context.save()
                } catch {
                    print("Error saving context: ", error.localizedDescription)
                }
            }
        }
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Add new new category", message: "", preferredStyle: .alert)
            let addAction  = UIAlertAction(title: "Add Category", style: .default) { _ in
                if let category = alert.textFields?.first?.text, category != "" {
                    let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                    childContext.parent = self.context
                    let newCategory = Category(context: childContext)
                    newCategory.name = category
                    do{
                        try childContext.save()
                    } catch {
                        print("Error saving context: ", error.localizedDescription)
                    }
                    //self.saveCategories()
                    self.categories.append(newCategory)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .fade)
                    self.tableView.endUpdates()
                    /*if let context = self.context {
                        let newCategory = Category(context: context)
                        newCategory.name = category
                        self.saveCategories()
                        self.categories.append(newCategory)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .fade)
                        self.tableView.endUpdates()
                    }*/
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addTextField { (textField) in
                textField.placeholder = "Create new category."
            }
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveCategories() {
        if let context = context {
            do {
                try context.save()
            } catch {
                print("Error saving context: ", error.localizedDescription)
            }
        }
    }
    
    func loadItems(with request: NSFetchRequest<Category> = NSFetchRequest<Category>(entityName: "Category")) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = context?.persistentStoreCoordinator
        privateContext.performAndWait {
            do {
                self.categories = try privateContext.fetch(request)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error getting context: ", error.localizedDescription)
            }
        }
        
        /*(UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.performBackgroundTask({ (context) in
            do {
                self.categories = try context.fetch(request)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error getting context: ", error.localizedDescription)
            }
        })*/
        /*if let context = context {
            do {
               self.categories = try context.fetch(request)
               DispatchQueue.main.async {
                   self.tableView.reloadData()
               }
            } catch {
               print("Error getting context: ", error.localizedDescription)
            }
        }*/
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit",
            handler: { (_, _, completion) in
                let alert = UIAlertController(title: "Edit the category", message: "", preferredStyle: .alert)
                let addAction  = UIAlertAction(title: "Edit Category", style: .default) { _ in
                    if let category = alert.textFields?.first?.text, category != "" {
                        let categoryTobeEdited = self.categories[indexPath.row]
                        categoryTobeEdited.name = category
                        self.saveCategories()
                        self.tableView.reloadRows(at: [indexPath], with: .right)
                        completion(true)
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    tableView.setEditing(false, animated: true)
                })
                alert.addTextField { (textField) in
                    textField.placeholder = "Edit the category."
                    textField.text = self.categories[indexPath.row].name
                }
                alert.addAction(addAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
        })
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete",
            handler: { (_, _, completion) in
                if let context = self.context {
                    context.delete(self.categories[indexPath.row])
                    self.saveCategories()
                    self.categories.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    completion(true)
                }
        })
        
        editAction.backgroundColor = .systemGreen
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            guard let destination = segue.destination as? ToDoListViewController else { return }
            guard let selectedCategoryIndex = tableView.indexPathForSelectedRow else { return }
            destination.selectedCategory = categories[selectedCategoryIndex.row]
        }
    }
}
