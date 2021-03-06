//
//  ToDoListViewController.swift
//  Todoey
//
//  Created by Kunal Tyagi on 18/01/20.
//  Copyright © 2020 Kunal Tyagi. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class ToDoListViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    fileprivate var items: [Item] = []
    fileprivate var itemResults: Results<ItemRealm>?
    /*var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }*/
    var selectedCategory: CategoryRealm? {
        didSet {
            loadRealmItems()
        }
    }
    fileprivate let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        //loadItems()
        loadRealmItems()
        self.tableView.rowHeight = 80.0
        self.tableView.separatorStyle = .none
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
            let addAction  = UIAlertAction(title: "Add Item", style: .default) { _ in
                if let item = alert.textFields?.first?.text, item != "" {
                    /*if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                        let newItem = Item(context: context)
                        newItem.name = item
                        newItem.isSelected = false
                        newItem.parentCategory = self.selectedCategory
                        self.saveItems()
                        self.items.append(newItem)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .fade)
                        self.tableView.endUpdates()
                    }*/
                    if let selectedCategory = self.selectedCategory {
                        do {
                            try self.realm.write({
                                let newItem = ItemRealm()
                                newItem.title = item
                                newItem.done = false
                                newItem.dateCreated = Date()
                                selectedCategory.items.append(newItem)
                                /*self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath(row: self.itemResults?.count ?? 1 - 1, section: 0)], with: .automatic)
                                self.tableView.endUpdates()*/
                                //self.tableView.insertRows(at: [IndexPath(row: self.itemResults?.count ?? 1 - 1, section: 0)], with: .automatic)
                                self.tableView.reloadData()
                            })
                        } catch {
                            print("Error is:", error)
                        }
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addTextField { (textField) in
                textField.placeholder = "Create new item."
            }
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveItems() {
        if let context = context {
            do {
                try context.save()
            } catch {
                print("Error saving context: ", error.localizedDescription)
            }
        }
        /*let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(items)
            guard self.dataFilePath != nil else { return }
            try? data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding item array \(error.localizedDescription)")
        }*/
    }
    
    /*func loadItems(with request: NSFetchRequest<Item> = NSFetchRequest<Item>(entityName: "Item"), predicate: NSPredicate? = nil) {
        if let name = selectedCategory?.name {
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
            
            if let additionalPredicate = predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            } else {
                request.predicate = categoryPredicate
            }
            
            if let context = context {
                do {
                    items = try context.fetch(request)
                    tableView.reloadData()
                } catch {
                    print("Error loading context: ", error.localizedDescription)
                }
            }
        }
        
        /*guard self.dataFilePath != nil else { return }
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                items = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error encoding item array \(error.localizedDescription)")
            }
        }*/
    }*/

    func loadRealmItems() {
        itemResults = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return items.count
        return itemResults?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "toDoItemCell") else { return UITableViewCell() }
        if let item = itemResults?[indexPath.row], let selectedCatagoryColor = selectedCategory?.color {
            cell.textLabel?.text = item.title
            if let count = itemResults?.count, let color = UIColor(hexString: selectedCatagoryColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added."
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let item = items[indexPath.row]
        try? realm.write({
            let item = itemResults?[indexPath.row]
            item?.done.toggle()
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            tableView.deselectRow(at: indexPath, animated: true)
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
    
    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let context = context {
                /*context.delete(items[indexPath.row])
                items.remove(at: indexPath.row)*/
                
                if let item = itemResults?[indexPath.row] {
                    do {
                        try realm.write {
                            realm.delete(item)
                        }
                    } catch {
                        print(error)
                    }
                }
                
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                //saveItems()
            }
        }
    }*/
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                if let item = self.itemResults?[indexPath.row] {
                    do {
                        try self.realm.write {
                            self.realm.delete(item)
                        }
                    } catch {
                        print(error)
                    }
                }
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                
                completionHandler(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }
}

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        //loadItems()
        loadRealmItems()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        if let text = searchBar.text {
            if let searchBartext = searchBar.text?.trimmingCharacters(in: .whitespaces), searchBartext != "" {
                /*let predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                loadItems(with: fetchRequest, predicate: predicate)*/
                
                itemResults = itemResults?.filter("title CONTAINS[cd] %@", text).sorted(byKeyPath: "dateCreated", ascending: true)
                self.tableView.reloadData()
            } else {
                searchBar.text = nil
            }
        }
    }
    
    /*func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchBartext = searchBar.text?.trimmingCharacters(in: .whitespaces), searchBartext == "" {
            loadItems()
            DispatchQueue.main.async {
                searchBar.text = nil
                searchBar.resignFirstResponder()
            }
            
        }
    }*/
}
