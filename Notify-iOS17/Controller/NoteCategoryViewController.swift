//
//  NoteCategoryViewController.swift
//  Notify-iOS17
//
//  Created by Andreas Sauerwein on 06.04.24.
//

import CoreData
import UIKit

class NoteCategoryViewController: UITableViewController {

    var noteCategoryArray = [NoteCategory]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteCategoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let noteCategory = noteCategoryArray[indexPath.row].categoryTitle
        cell.textLabel?.text = noteCategory
        return cell
    }
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
            print("Categories saved") //debug
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<NoteCategory> = NoteCategory.fetchRequest()) {
          do {
            noteCategoryArray = try context.fetch(request)
              print("Categories loaded") //debug
        } catch {
            print("Error fetching data from context \(error)")
        }
        self.tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let categoryToDelete = noteCategoryArray[indexPath.row]
            let alert = UIAlertController(title: "Delete Category", message: "Are you sure you want to delete '\(categoryToDelete.categoryTitle ?? "this category")'? This will also delete all notes in this category.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteCategory(at: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }

    //MARK: - delete Category with Swipe
    // UI Contextual Action for Swipe to delete
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            let alert = UIAlertController(title: "Delete Category", message: "Are you sure you want to delete '\(self.noteCategoryArray[indexPath.row].categoryTitle ?? "this category")'? This will also delete all notes in this category.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteCategory(at: indexPath)
                completionHandler(true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            }))
            self.present(alert, animated: true)
        }

        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
    // delete Category in Core Data
    func deleteCategory(at indexPath: IndexPath) {
        context.delete(noteCategoryArray[indexPath.row])
        noteCategoryArray.remove(at: indexPath.row)
        saveCategories()
    }

    
    
    //MARK: - add new Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { [weak self] _ in
            guard let self = self, let text = textField.text, !text.isEmpty else {
                print("Error: Category name is empty")
                return
            }
            let newCategory = NoteCategory(context: self.context)
            newCategory.categoryTitle = text
            print("New Category: \(String(describing: newCategory.categoryTitle))") //debug
            self.noteCategoryArray.append(newCategory)
            self.saveCategories()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNotesList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NoteListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = noteCategoryArray[indexPath.row]
        }
    }
    
}
