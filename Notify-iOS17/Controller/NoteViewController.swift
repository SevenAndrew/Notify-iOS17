//
//  ViewController.swift
//  Notify-iOS17
//
//  Created by Andreas Sauerwein on 06.04.24.
//

import CoreData
import UIKit

class NoteViewController: UIViewController {
   
    @IBOutlet weak var NoteHeading: UITextView!
    @IBOutlet weak var NoteText: UITextView!

    var selectedNote: Note? {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    //MARK: - Data Handling methods
    
    func updateUI() {
        NoteHeading.text = selectedNote?.title
        NoteText.text = selectedNote?.text
    }
    
    func saveNote() {
        guard let note = selectedNote else {
            print("Error: No note selected")
            return
        }
        note.text = NoteText.text
        do {
            try context.save()
            print("Note saved") //debug
            print(note.title as Any)
            print(note.text as Any)
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        saveNote()
        navigationController?.popViewController(animated: true)
    }
    
}

