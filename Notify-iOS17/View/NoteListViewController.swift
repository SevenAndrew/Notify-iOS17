//
//  NoteListViewController.swift
//  Notify-iOS17
//
//  Created by Andreas Sauerwein on 06.04.24.
//

import CoreData
import UIKit

class NoteListViewController: UITableViewController {

    var noteArray = [Note]()
    var selectedCategory: NoteCategory? {
        didSet {
            loadNotes()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    //MARK: - Manipulate Data
    
    func saveNotes() {
        do {
            try context.save()
            print("Note saved") //debug
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadNotes(with request: NSFetchRequest<Note> = Note.fetchRequest(), predicate: NSPredicate? = nil) {
        guard let categoryTitle = selectedCategory?.categoryTitle else {
            print("Error: No category selected")
            noteArray = []
            self.tableView.reloadData()
            return
        }
        let categoryPredicate = NSPredicate(format: "parent.categoryTitle MATCHES %@", categoryTitle)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            noteArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        self.tableView.reloadData()
    }

    // MARK: - Add new Notes
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Note", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Note", style: .default) { [weak self] _ in
            guard let self = self, let text = textField.text, !text.isEmpty else {
                print("Error: Note title is empty")
                return
            }
            let newNote = Note(context: self.context)
            newNote.title = text
            newNote.text = "Enter note text here..."
            newNote.parent = self.selectedCategory
            
            self.noteArray.append(newNote)
            print("Note added") //debug
            self.saveNotes()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Note"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - delete Notes
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in

            guard let self = self else {
                completionHandler(false)
                return
            }

            let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to delete this note?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteNote(at: indexPath)
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

    
    func deleteNote(at indexPath: IndexPath) {
        let noteToDelete = noteArray[indexPath.row]
        context.delete(noteToDelete)
        noteArray.remove(at: indexPath.row)
        do {
            try context.save()
        } catch {
            print("Error saving context after deleting note: \(error)")
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    
    
    //MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNote", sender: self)
        print("Selected row: \(indexPath.row)") //debug
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NoteViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedNote = noteArray[indexPath.row]
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as UITableViewCell
        let note = noteArray[indexPath.row]
        cell.textLabel?.text = note.title
        return cell
    }
    
}
