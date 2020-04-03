//
//  LoanTableViewCell.swift
//  ToolTracking
//
//  Created by Anh Nguyen on 2/18/20.
//  Copyright © 2020 Anh Nguyen. All rights reserved.
//

import UIKit

class LoanTableViewCell: UITableViewCell {

    @IBOutlet weak var lblToolName: UILabel!
    @IBOutlet weak var lblToolBorrowed: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateView(_ loan: Loan) {
        self.lblToolName.text = loan.nameTool
        self.lblToolBorrowed.text = "\(loan.totalTool)"
    }

}
