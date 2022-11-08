//
//  CategoryViewController.swift
//  TodoApp
//
//  Created by Murat on 6.11.2022.
//

import UIKit
import CoreData
import SwipeCellKit

class CategoryViewController: SwipeTableViewController {

    var categoryArray = [TodoCategory]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 75.0
        
        loadCategory()
      
    }
    
    //MARK: - TableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
 
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toItemsList", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toItemsList" {
            
            let destinationVC = segue.destination as! ItemViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.selectedCategory = categoryArray[indexPath.row]
            }
            
        }
    }
    
    
    //MARK: - Add Category Button
    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add New Category", style: .default) { (action) in
            
            if let safeItemText = textField.text {
                
                if safeItemText != "" {
                    
                    let newTodoCategory = TodoCategory(context: self.context)
                    
                    newTodoCategory.name = safeItemText
                    
                    self.categoryArray.append(newTodoCategory)
                    
                    self.saveCategory()
                }
                else{
                    print("Enter a categoryName")
                }

            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style:.default){(cancelAction) in
            
            self.dismiss(animated: true)
            
        }
        
        alert.addTextField {(alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    //MARK: - Data Process
    
    func loadCategory(with request: NSFetchRequest<TodoCategory> = TodoCategory.fetchRequest()) {
        
        do{
          
           categoryArray = try context.fetch(request)
        
        }
        catch{
            print("Error occured \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveCategory(){
        do{
            try context.save()
            
        }
        catch{
            print("Error occured \(error)")
        }
        
        tableView.reloadData()
    }
    
    override func remove(at indexPath: IndexPath) {
        
        context.delete(categoryArray[indexPath.row])
        categoryArray.remove(at: indexPath.row)
        saveCategory()
    }
    
}
