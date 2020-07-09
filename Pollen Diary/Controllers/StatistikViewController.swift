//
//  StatistikViewController.swift
//  Pollen Diary
//
//  Created by Wolfgang Sigel on 06.07.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class StatistikViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var pollenSymptoms : [String] = []
    var pollenType: [String] = []
    var intensity: [String] = []
    var intensitySelection: String?
    var dataController: DataController!
    var symptomsStatistic: [String] = []
    var pollenStatistic: [String] = []
    var dataStatistic: [[String]] = []
    let headerTitles: [String] = ["SYMPTOME", "POLLEN"]
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSymptoms()
        initPollentype()
        initIntensity()
        
       calculateSymptomsStatistic()
        calculatePollenStatistics()
        tableView.dataSource = self
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func calculateSymptomsStatistic() {
        
        let fetchRequest: NSFetchRequest<Symptom> = Symptom.fetchRequest()
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        for symptom in pollenSymptoms {
            let predicate: NSPredicate = NSPredicate(format: "name == %@", symptom)
            fetchRequest.predicate = predicate
            
            let result = try? dataController.persistentContainer.viewContext.fetch(fetchRequest)
            if let result = result {
                if result.count > 0 {
                    symptomsStatistic.append("\(result.count) x : \(symptom)")
                }
            }
        }
        dataStatistic.append(symptomsStatistic)
    }
    
    func calculatePollenStatistics() {
        let fetchRequest: NSFetchRequest<Measurement> = Measurement.fetchRequest()
        
        for pollen in pollenType {
            let predicate: NSPredicate = NSPredicate(format: "ANY \(pollen.lowercased()) IN %@", ["0-1", "1", "1-2", "2", "2-3", "3"])
            fetchRequest.predicate = predicate
            let result = try? dataController.persistentContainer.viewContext.fetch(fetchRequest)
            if let result = result {
                if result.count > 0 {
                    pollenStatistic.append("\(result.count) x : \(pollen)")
                }
            }
        }
        dataStatistic.append(pollenStatistic)
    }
    
    fileprivate func initSymptoms() {
        pollenSymptoms.append("Abgeschlagenheit")
        pollenSymptoms.append("Allergischer Schock")
        pollenSymptoms.append("Asthma")
        pollenSymptoms.append("Atemnot")
        pollenSymptoms.append("Augenjucken und Rötung / Schwellung")
        pollenSymptoms.append("Augentränen")
        pollenSymptoms.append("Beeinträchtigung des Allgemeinzustands")
        pollenSymptoms.append("Fieber")
        pollenSymptoms.append("Fließschnupfen")
        pollenSymptoms.append("Halsbeschwerden (Juckreiz, Kratzen, Trockenheit)")
        pollenSymptoms.append("Husten")
        pollenSymptoms.append("Kopfschmerzen")
        pollenSymptoms.append("Magen-Darm-Beschwerden, Übelkeit, Erbrechen")
        pollenSymptoms.append("Schlafstörungen")
        pollenSymptoms.append("Starker Niesreiz")
        pollenSymptoms.append("Verstopfte Nase")
    }
    
    fileprivate func initIntensity() {
        intensity.append("keine")
        intensity.append("schwach")
        intensity.append("mäßig")
        intensity.append("stark")
    }
    
    fileprivate func initPollentype() {
        pollenType.append("Ambrosia")
        pollenType.append("Beifuss")
        pollenType.append("Birke")
        pollenType.append("Erle")
        pollenType.append("Esche")
        pollenType.append("Graeser")
        pollenType.append("Hasel")
        pollenType.append("Roggen")
    }
}



extension StatistikViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataStatistic.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStatistic[section].count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataStatistic[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        return nil
    }
}
