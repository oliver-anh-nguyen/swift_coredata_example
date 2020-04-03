//
//  FriendViewController.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import UIKit

class FriendViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var manager: PersonStorageManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Friends"
        self.manager = PersonStorageManager()
    }
    
    func itemPerson(index: Int) -> Person {
        let items = self.manager.fetchData().sorted(by: { $0.id < $1.id })
        return items[index]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loanSegue" {
            let loanVC = segue.destination as! LoanViewController
            let person = sender as! Person
            loanVC.person = person
        }
    }
    
}

// MARK: - UITableViewDataSource
extension FriendViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager.fetchData().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath)
        let item = self.itemPerson(index: indexPath.row)
        cell.textLabel?.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.itemPerson(index: indexPath.row)
        self.performSegue(withIdentifier: "loanSegue", sender: item)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
