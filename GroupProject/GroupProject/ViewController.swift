//
//  ViewController.swift
//  GroupProject
//
//  Created by 张梦凡 on 26/5/19.
//  Copyright © 2019 UTS. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    var items: [NSManagedObject] = []
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 1)
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addItem))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let err as NSError {
            print("Failed to fetch items", err )
        }
        
    }
    @objc func addItem(_ sender: AnyObject) {
        let alterController = UIAlertController(title: "Add New Question", message: "Please fill in the textfield below", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alterController.textFields?.first, let itemToAdd = textField.text else { return }
            self.save(itemToAdd)
            self.tableView.reloadData()
            }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alterController.addTextField(configurationHandler: nil)
        alterController.addAction(saveAction)
        alterController.addAction(cancelAction)
        present(alterController, animated: true, completion: nil)
        }
    func save(_ itemName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        item.setValue(itemName, forKey: "itemName")
        
        do {
            try managedContext.save()
            items.append(item)
        } catch let err as NSError {
            
            print("Failed to Save", err)
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.value(forKeyPath: "itemName") as? String
        return cell
    }
}





