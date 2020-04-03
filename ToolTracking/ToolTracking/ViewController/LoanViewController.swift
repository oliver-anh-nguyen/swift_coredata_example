//
//  LoanViewController.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import UIKit

class LoanViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var person: Person!
    var managerLoan: LoanStorageManager!
    var managerTool: ToolStorageManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.person.name
        self.managerLoan = LoanStorageManager()
        self.managerTool = ToolStorageManager()
    }

    func itemLoan(index: Int) -> Loan {
        let items = self.managerLoan.getTools(idPerson: self.person.id)
        return items[index]
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension LoanViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.managerLoan.getTools(idPerson: self.person.id).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoanTableViewCell", for: indexPath) as! LoanTableViewCell
        cell.updateView(self.itemLoan(index: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.itemLoan(index: indexPath.row)
        let alert = UIAlertController(title: nil, message: "Mark one item as returned?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                self.managerTool.updateTool(toolId: item.idTool, name: item.nameTool, isIncrease: true)
                self.managerLoan.updateLoan(idPerson: self.person.id, idTool: item.idTool, isIncrease: false)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            @unknown default:
                fatalError()
            }}))
        self.present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
