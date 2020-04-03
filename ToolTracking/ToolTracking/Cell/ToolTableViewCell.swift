//
//  ToolTableViewCell.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/17/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import UIKit

class ToolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblToolName: UILabel!
    @IBOutlet weak var lblToolCount: UILabel!
    @IBOutlet weak var lblToolBorrowed: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateView(_ item: Tool) {
        self.lblToolName.text = item.name
        self.lblToolCount.text = "Total: \(item.total)"
        self.lblToolBorrowed.text = "Borrowed: \(item.total - item.remain)"
    }
    
}
