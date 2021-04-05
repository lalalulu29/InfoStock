//
//  SaveCell.swift
//  InfoStock
//
//  Created by Кирилл Любарских  on 04.04.2021.
//

import UIKit

class SaveCell: UITableViewCell {

    @IBOutlet weak var companyNameLable: UILabel!
    @IBOutlet weak var ticketNameLable: UILabel!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var costLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
