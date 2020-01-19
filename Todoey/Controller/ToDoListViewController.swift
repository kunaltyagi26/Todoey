//
//  ToDoListViewController.swift
//  Todoey
//
//  Created by Kunal Tyagi on 18/01/20.
//  Copyright © 2020 Kunal Tyagi. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    fileprivate var items = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let toDoItems = self.defaults.array(forKey: "items") as? [String] {
            items = toDoItems
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
            let addAction  = UIAlertAction(title: "Add Item", style: .default) { (action) in
                if let item = alert.textFields?.first?.text, item != "" {
                    self.items.append(item)
                    self.defaults.set(self.items, forKey: "items")
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .fade)
                    self.tableView.endUpdates()
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "toDoItemCell") else { return UITableViewCell() }
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
}
