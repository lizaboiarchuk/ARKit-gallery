//
//  ChoiceTableViewCell.swift
//  gallery-test
//
//  Created by Yelyzaveta Boiarchuk on 10.07.2022.
//

import UIKit

class ChoiceTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imgView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(label: String, image: UIImage) -> ChoiceTableViewCell {
        self.title.text = label
        self.imgView.image = image
        return self
    }
}
