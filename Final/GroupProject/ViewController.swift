//
//  ViewController.swift
//  Askr
//
//  Created by Group 140 on 13/5/19.
//  Copyright © 2019 UTS. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    var db: DatabaseReference!          //Reference to the Firebase database
    var qList = [QuestionStruct]()      //List of questions in the database
    var selectedRow: Int! = 0

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        db = Database.database().reference()

        view.backgroundColor = .black
        
        //Logo at the top
        let image: UIImage = UIImage(named: "logo.png")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        //Set up nav bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1)
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addQuestion))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Answer", style: .plain, target: self, action: #selector(addAnswer))
        
        //Set up table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        
        //Listens for any change in the database
        db.observe(DataEventType.value, with: { (snapshot) in
            
            if snapshot.childrenCount >= 0 {
                
                self.qList.removeAll() //Remove the list of questions
                
                for Qs in snapshot.children.allObjects as![DataSnapshot]{
                    let qObject = Qs.value as? [String: AnyObject]
                    let questionQuestion = qObject?["Question"]
                    let questionVotes = qObject?["Votes"]
                    let questionAnswer = qObject?["Answer"]
                    let questionID = qObject?["ID"]
                    let questionReply = qObject?["Reply"]
                    
                    let question = QuestionStruct(question: questionQuestion as! String?, votes: questionVotes as! Int?, answer: questionAnswer as! String?, id: questionID as! String?, reply: questionReply as! Bool)
                    
                    self.qList.append(question) //Add a new list of questions
                    
                }
                
                self.qList.sort(by: { $0.votes > $1.votes }) //Sort the questions by highest votes
                self.tableView.reloadData() //Put the questions into the table view
                
            }
        })

    }
    

    @objc func addQuestion(_ sender: AnyObject) {
        
        let alterController = UIAlertController(title: "Post Question", message: "Ask away!", preferredStyle: .alert)
        let postAction = UIAlertAction(title: "Post", style: .default) { [unowned self] action in
            
            guard let textField = alterController.textFields?.first, let textEntry = textField.text else { return }
            
            //Add a new question record
            let randomID = self.db.childByAutoId()
            randomID.setValue(["Question": textEntry, "Votes": 0, "Answer": "", "ID": randomID.key as Any, "Reply": false])
            
            //Update the table view
            self.tableView.reloadData() }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        //Add the controls to the controller
        alterController.addTextField(configurationHandler: nil)
        alterController.addAction(cancelAction)
        alterController.addAction(postAction)
        
        present(alterController, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return qList.count
        
    }
    
    @objc func addAnswer(_ sender: AnyObject) {
        
        let i = selectedRow
        
        let msg = qList[i!].question
       
        let alterController = UIAlertController(title: "Post Answer", message: "\"\(msg!)\"", preferredStyle: .alert)
        let postAction = UIAlertAction(title: "Post", style: .default) { [unowned self] action in
            
            guard let textField = alterController.textFields?.first, let textEntry = textField.text else { return }
            
            let updateQuestion = ["Question": self.qList[i!].question!,
                                  "Votes": (self.qList[i!].votes!),
                                  "Answer": textEntry,
                                  "Reply": true,
                                  "ID": self.qList[i!].id!] as [String : Any]
            
            self.db.child(self.qList[i!].id!).setValue(updateQuestion)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alterController.addTextField(configurationHandler: nil)
        alterController.addAction(cancelAction)
        alterController.addAction(postAction)
        
        
        present(alterController, animated: true, completion: nil)
        
    }
    
    @objc func Swiped(sender: UITapGestureRecognizer) {
        
        let i = sender.view!.tag
        self.db.child(self.qList[i].id!).removeValue() //Delete question
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        
        cell.textLabel?.isUserInteractionEnabled = true
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.Swiped(sender:)))
        cell.addGestureRecognizer(swipe)
        cell.tag = indexPath.row
        
        if (qList[indexPath.row].reply == true)
        {
            cell.accessoryType = .detailButton
        }
        else
        {
            cell.accessoryType = .none
        }
        
        let question: QuestionStruct
        question = qList[indexPath.row]
        
        let cellText: String!
        
        if let num = question.votes  {
            cellText = String("\(num)")
        }
        else    {
            cellText = ""
        }
        
        cell.textLabel?.text = "\(cellText!)\t\(question.question!)"
        
        cell.backgroundColor = .black
        cell.selectionStyle = .blue
        
        if (qList[indexPath.row].reply == true) {
        
            cell.textLabel?.textColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
        }
        else
        {
            cell.textLabel?.textColor = .white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRow = indexPath.row
        let i = selectedRow
        
        let updateQuestion = ["Question": qList[i!].question!,
                              "Votes": (qList[i!].votes! + 1),
                              "Answer": qList[i!].answer!,
                              "Reply": qList[i!].reply,
                              "ID": qList[i!].id!] as [String : Any]
        
        self.db.child(qList[i!].id!).setValue(updateQuestion)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let i = indexPath.row
        
        if (qList[i].reply == false)
        {
            return
        }
        
        let msg = qList[i].answer
        
        let alterController = UIAlertController(title: "Answer", message: msg, preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alterController.addAction(OkAction)
        
        present(alterController, animated: true, completion: nil)
    }

}


