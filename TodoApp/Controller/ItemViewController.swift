//
//  ItemViewController.swift
//  TodoApp
//
//  Created by Murat on 7.11.2022.
//

import UIKit
import CoreData
import SwipeCellKit


class ItemViewController: SwipeTableViewController {
    
    var itemArray = [Items]()
    
    var selectedCategory: TodoCategory? {
        didSet {
            loadItem()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 55.0
       
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        cell.accessoryType = itemArray[indexPath.row].done == true ? .checkmark : .none
        
        
        return cell
        
    }

 //MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        
        tableView.reloadData()
    }
    

    func loadItem(with request: NSFetchRequest<Items> = Items.fetchRequest(),predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@ ", selectedCategory!.name!)
        
        if let itemPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,itemPredicate])
        }
        else {
            
            request.predicate = categoryPredicate
            
        }

        do
        {
       itemArray = try context.fetch(request)
        }
        catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func saveItem() {
        
        do{
            try context.save()
        }
        catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    
    override func remove(at indexPath: IndexPath) {
    
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        
        saveItem()
    }
    
    
    //MARK: - Add new Item
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert =  UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Create new Item", style: .default) { (action) in
            
            let newItem = Items(context: self.context)
            newItem.title = textField.text
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItem()

        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
            
        }

        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
}

extension ItemViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Items> = Items.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        let descriptor = NSSortDescriptor(key: "title", ascending: true)
        
        request.sortDescriptors = [descriptor]
        
        loadItem(predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItem()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
}
