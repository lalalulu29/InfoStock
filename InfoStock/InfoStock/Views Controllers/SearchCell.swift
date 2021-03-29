//
//  SearchCell.swift
//  InfoStock
//
//  Created by Кирилл Любарских  on 28.03.2021.
//

import UIKit

class SearchCell: UITableViewCell {

   
    @IBOutlet weak var imageCompany: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var ticketNameLabel: UILabel!
    
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
