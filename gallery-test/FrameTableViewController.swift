//
//  FrameTableViewController.swift
//  gallery-test
//
//  Created by Yelyzaveta Boiarchuk on 10.07.2022.
//

import UIKit

class FrameTableViewController: UITableViewController {
    
    var selectedOption: String = "Gold"
    
    private let labels = ["Gold", "Home", "Wooden", "Polaroid"]
    private let images = [UIImage(named: Bundle.main.path(forResource: "frame-gold", ofType: "png")!)!,
                          UIImage(named: Bundle.main.path(forResource: "frame-home", ofType: "png")!)!,
                          UIImage(named: Bundle.main.path(forResource: "frame-wooden", ofType: "png")!)!,
                          UIImage(named: Bundle.main.path(forResource: "frame-polaroid", ofType: "png")!)!,]
    
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
