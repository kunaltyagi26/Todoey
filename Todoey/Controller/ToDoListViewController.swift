//
//  ToDoListViewController.swift
//  Todoey
//
//  Created by Kunal Tyagi on 18/01/20.
//  Copyright © 2020 Kunal Tyagi. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    fileprivate var items: [Item] = [Item(itemName: "Find Mike", isSelected: false), Item(itemName: "Buy Eggos", isSelected: false), Item(itemName: "Destroy Demogorgon", isSelected: false)]
    fileprivate let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
            let addAction  = UIAlertAction(title: "Add Item", style: .default) { (action) in
                if let item = alert.textFields?.first?.text, item != "" {
                    let newItem = Item(itemName: item, isSelected: false)
                    self.items.append(newItem)
                    self.saveData()
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
    
    func saveData() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(items)
            guard self.dataFilePath != nil else { return }
            try? data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding item array \(error.localizedDescription)")
        }
    }
    
    func loadItems() {
        guard self.dataFilePath != nil else { return }
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                items = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error encoding item array \(error.localizedDescription)")
            }
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
        let item = items[indexPath.row]
        cell.textLabel?.text = item.itemName
        cell.accessoryType = item.isSelected ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.isSelected.toggle()
        saveData()
        self.tableView.reloadRows(at: [indexPath], with: .fade)
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
