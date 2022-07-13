//
//  StylesTableViewController.swift
//  gallery-test
//
//  Created by Yelyzaveta Boiarchuk on 10.07.2022.
//

import UIKit

class StylesTableViewController: UITableViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var chosenStyle = 0
    
    
    var selectedOption: String = "Default"
    private let labels = ["Default", "Geometry", "Picasso", "Munch"]
    private let images = [UIImage(named: Bundle.main.path(forResource: "style0", ofType: "png")!)!,
                          UIImage(named: Bundle.main.path(forResource: "style1", ofType: "jpg")!)!,
                          UIImage(named: Bundle.main.path(forResource: "style2", ofType: "jpg")!)!,
                          UIImage(named: Bundle.main.path(forResource: "style3", ofType: "jpg")!)!]
    


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return labels.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choiceCell", for: indexPath) as! ChoiceTableViewCell
        return cell.configure(label: labels[Int(indexPath.row)], image: images[Int(indexPath.row)])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOption = labels[indexPath.row]
    }
    
    
}
