//
//  HomeViewController.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/17/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var managerTool: ToolStorageManager!
    var managerLoan: LoanStorageManager!
    var toolSelected: Tool!
    var btnBackground: UIButton!
    
    fileprivate lazy var pickerView = UIView()
    fileprivate lazy var picker = FriendPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Garage"
        self.managerTool = ToolStorageManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func itemTool(index: Int) -> Tool {
        let items = self.managerTool.fetchData().sorted(by: { $0.id < $1.id })
        return items[index]
    }
    
    func loadPickerFriend() {
        self.managerLoan = LoanStorageManager()
        
        self.btnBackground = UIButton(type: .custom)
        self.btnBackground.backgroundColor = .black
        self.btnBackground.alpha = 0.7
        self.btnBackground.frame = self.view.frame
        self.view.addSubview(self.btnBackground)
        
        self.pickerView.frame = CGRect(x: 0, y: self.view.frame.height - 260, width: view.frame.width, height: 260)
        
        let doneButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(self.doneTapped))
        let titleTool = UIBarButtonItem(title: self.toolSelected.name, style: .plain, target: self, action: nil)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))
        
        let barAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        barAccessory.barStyle = .default
        barAccessory.isTranslucent = false
        barAccessory.items = [cancelButton, spaceButton, titleTool, spaceButton, doneButton]
        self.pickerView.addSubview(barAccessory)
        
        self.picker.frame = CGRect(x: 0, y: barAccessory.frame.height, width: view.frame.width, height: self.pickerView.frame.height - barAccessory.frame.height)
        self.pickerView.addSubview(self.picker)
        self.picker.reloadAllComponents()
        
        self.view.addSubview(self.pickerView)
    }
    
    @objc func doneTapped() {
        let row = self.picker.selectedRow(inComponent: 0)
        let items = self.picker.managerPerson.fetchData()
        let person = items[row]
        self.picker.selectRow(row, inComponent: 0, animated: false)
        self.removePickerView()
        self.managerLoan.updateLoan(idPerson: person.id, idTool: self.toolSelected.id, isIncrease: true)
        self.managerTool.updateTool(toolId: self.toolSelected.id, name: self.toolSelected.name ?? "", isIncrease: false)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func cancelTapped() {
        self.removePickerView()
    }
    
    func removePickerView() {
        self.btnBackground.removeFromSuperview()
        self.pickerView.removeFromSuperview()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.managerTool.fetchData().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToolTableViewCell", for: indexPath) as! ToolTableViewCell
        cell.updateView(self.itemTool(index: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = self.itemTool(index: indexPath.row)
        if item.remain == 0  {
            Utils.displayAlert(title: "Notice", message: "\(item.name ?? "") out of stock!!!")
            return
        }
        self.toolSelected = item
        self.loadPickerFriend()
    }
    
}

