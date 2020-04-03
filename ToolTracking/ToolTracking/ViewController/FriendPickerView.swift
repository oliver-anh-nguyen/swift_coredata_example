//
//  FriendPickerView.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import UIKit
import Foundation
import UIKit

class FriendPickerView: UIPickerView {
    
    var managerPerson: PersonStorageManager!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.managerPerson = PersonStorageManager()
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .white
    }
    
    func itemPerson(index: Int) -> Person {
        let items = self.managerPerson.fetchData()
        return items[index]
    }

}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension FriendPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.managerPerson.fetchData().count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.itemPerson(index: row).name
    }
    
}
