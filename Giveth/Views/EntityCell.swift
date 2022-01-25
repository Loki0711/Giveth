//
//  EntityCell.swift
//  Giveth
//
//  Created by Jagsifat Makkar on 2022-01-23.
//

import UIKit

class EntityCell: UITableViewCell {

    @IBOutlet weak var entityImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var isConnectedLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
