//
//  RegionSelectionViewController.swift
//  Pollen Diary
//
//  Created by Wolfgang Sigel on 01.07.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import UIKit

class RegionSelectionViewController: UIViewController {
    
    @IBOutlet weak var regionTableView: UITableView!
    var pollenAreas: [PollenRegion] = []
    var currentCheckmarkedCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPollenAreas()
        regionTableView.dataSource = self
        regionTableView.delegate = self
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkmarkSelectedRegion()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        var indexpath = IndexPath(row: 0, section: 0)
        for i in 0...pollenAreas.count - 1 {
            indexpath.row = i
            if let cell = regionTableView.cellForRow(at: indexpath) {
                if cell.accessoryType == .checkmark {
                    let selection = pollenAreas.first(where: {$0.PartRegionName == cell.textLabel!.text! || $0.RegionName == cell.textLabel!.text!})
                    if let selection = selection {
                        // save to UserDefaults RegionId & PartRegionId
                        UserDefaults.standard.set(selection.RegionId, forKey: "RegionId")
                        UserDefaults.standard.set(selection.PartRegionId, forKey: "PartRegionId")
                        navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func checkmarkSelectedRegion() {
        let regionId = UserDefaults.standard.integer(forKey: "RegionId")
        let partRegionId = UserDefaults.standard.integer(forKey: "PartRegionId")
        
        if regionId != 0 && partRegionId != 0 {
            let region = pollenAreas.first(where: {$0.RegionId == regionId && $0.PartRegionId == partRegionId})
            var indexpath = IndexPath(row: 0, section: 0)
            for i in 0...pollenAreas.count - 1 {
                indexpath.row = i
                if let cell = regionTableView.cellForRow(at: indexpath) {
                    if cell.textLabel?.text == region?.RegionName || cell.textLabel?.text == region?.PartRegionName {
                        currentCheckmarkedCell = cell
                        cell.accessoryType = .checkmark
                    }
                }
            }
        }
    }
    
    // MARK: load all the local regions supported by the DWD for selection
    
    func initPollenAreas () {
        pollenAreas = [
            PollenRegion(RegionId: 10, RegionName: "Schleswig-Holstein und Hamburg", PartRegionId: 11, PartRegionName: "Inseln und Marschen"),
            
            PollenRegion(RegionId: 10, RegionName: "Schleswig-Holstein und Hamburg", PartRegionId: 12, PartRegionName : "Geest, Schleswig-Holstein und Hamburg"),
            PollenRegion(RegionId: 20, RegionName : "Mecklenburg-Vorpommern", PartRegionId: -1, PartRegionName: ""),
            PollenRegion(RegionId: 30, RegionName : "Niedersachsen und Bremen", PartRegionId: 31, PartRegionName : "Westl. Niedersachsen / Bremen"),
            PollenRegion(RegionId: 30, RegionName : "Niedersachsen und Bremen", PartRegionId: 32, PartRegionName : "Östl. Niedersachsen"),
            
            PollenRegion(RegionId: 40, RegionName : "Nordrhein-Westfalen", PartRegionId: 41, PartRegionName : "Rhein.-Westfäl. Tiefland"),
            PollenRegion(RegionId: 40, RegionName : "Nordrhein-Westfalen", PartRegionId: 42, PartRegionName : "Ostwestfalen"),
            PollenRegion(RegionId: 40, RegionName : "Nordrhein-Westfalen", PartRegionId: 43, PartRegionName : "Mittelgebirge NRW"),
            
            PollenRegion(RegionId: 50, RegionName : "Brandenburg und Berlin", PartRegionId: -1, PartRegionName: ""),
            PollenRegion(RegionId: 60, RegionName : "Sachsen-Anhalt", PartRegionId: 61, PartRegionName : "Tiefland Sachsen-Anhalt"),
            PollenRegion(RegionId: 60, RegionName : "Sachsen-Anhalt", PartRegionId: 62, PartRegionName : "Harz"),
            
            PollenRegion(RegionId: 70, RegionName : "Thüringen", PartRegionId: 71, PartRegionName : "Tiefland Thüringen"),
            PollenRegion(RegionId: 70, RegionName : "Thüringen", PartRegionId: 72, PartRegionName : "Mittelgebirge Thüringen"),
            
            PollenRegion(RegionId: 80, RegionName : "Sachsen", PartRegionId: 81, PartRegionName : "Tiefland Sachsen"),
            PollenRegion(RegionId: 80, RegionName : "Sachsen", PartRegionId: 82, PartRegionName : "Mittelgebirge Sachsen"),
            
            PollenRegion(RegionId: 90, RegionName : "Hessen", PartRegionId: 91, PartRegionName : "Nordhessen und hess. Mittelgebirge"),
            PollenRegion(RegionId: 90, RegionName : "Hessen", PartRegionId: 92, PartRegionName : "Rhein-Main"),
            
            PollenRegion(RegionId: 100, RegionName : "Rheinland-Pfalz", PartRegionId: 101, PartRegionName : "Rhein, Pfalz, Nahe und Mosel"),
            PollenRegion(RegionId: 100, RegionName : "Rheinland-Pfalz", PartRegionId: 102, PartRegionName : "Mittelgebirgsbereich Rheinland-Pfalz"),
            PollenRegion(RegionId: 100, RegionName : "Rheinland-Pfalz", PartRegionId: 103, PartRegionName : "Saarland"),
            
            PollenRegion(RegionId: 110, RegionName : "Baden-Württemberg", PartRegionId: 111, PartRegionName : "Oberrhein und unteres Neckartal"),
            PollenRegion(RegionId: 110, RegionName : "Baden-Württemberg", PartRegionId: 112, PartRegionName : "Hohenlohe/mittlerer Neckar/Oberschwaben"),
            PollenRegion(RegionId: 110, RegionName : "Baden-Württemberg", PartRegionId: 113, PartRegionName : "Mittelgebirge Baden-Württemberg"),
            
            PollenRegion(RegionId: 120, RegionName : "Bayern", PartRegionId: 121, PartRegionName : "Allgäu/Oberbayern/Bayerischer Wald"),
            PollenRegion(RegionId: 120, RegionName : "Bayern", PartRegionId: 122, PartRegionName : "Donauniederungen"),
            PollenRegion(RegionId: 120, RegionName : "Bayern", PartRegionId: 123, PartRegionName : "Bayern nördl. der Donau/o. Bayr. Wald/o. Mainfranken"),
            PollenRegion(RegionId: 120, RegionName : "Bayern", PartRegionId: 124, PartRegionName : "Mainfranken")
        ]

    }
}

extension RegionSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollenAreas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        var area: String
        if pollenAreas[indexPath.row].PartRegionName != "" {
            area = pollenAreas[indexPath.row].PartRegionName
        } else {
            area = pollenAreas[indexPath.row].RegionName
        }
        cell.textLabel?.text = area
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = currentCheckmarkedCell {
            cell.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    
}
