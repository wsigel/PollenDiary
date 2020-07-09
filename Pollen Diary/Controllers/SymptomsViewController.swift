//
//  SymptomsViewController.swift
//  Pollen Diary
//
//  Created by Wolfgang Sigel on 28.06.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SymptomsViewController: UIViewController {
    
    var pollenSymptoms : [String] = []
    var symptomSelection : [String] = []
    var measurement: Measurement!
    var dataController: DataController!
    
    @IBOutlet weak var symptomsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSymptoms()
        symptomsTableView.dataSource = self
        symptomsTableView.delegate = self
        
        // populate array to provide checkmarks for selected symptoms
        if let symptoms = measurement.symptoms {
            for symptom in symptoms as! Set<Symptom> {
                symptomSelection.append(symptom.name!)
            }
        }
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let predicate = NSPredicate(format: "creationDate == %@", measurement.creationDate! as NSDate)
        let fetchRequest: NSFetchRequest<Measurement> = Measurement.fetchRequest()
        fetchRequest.predicate = predicate
        let result = try? dataController.persistentContainer.viewContext.fetch(fetchRequest)
        if result?.count == 1 {
            let fetchedMeasurement = result![0]
            if fetchedMeasurement.symptoms!.count > 0 {
                // remove all previous registered symptoms
                let symptoms = fetchedMeasurement.symptoms
                for symptom in symptoms! {
                    dataController.persistentContainer.viewContext.delete(symptom as! NSManagedObject)
                }
            }
            var indexpath = IndexPath(row: 0, section: 0)
            for i in 0...pollenSymptoms.count - 1 {
                indexpath.row = i
                if let cell = symptomsTableView.cellForRow(at: indexpath) {
                    if cell.accessoryType == .checkmark {
                        let symptom = Symptom(context: dataController.persistentContainer.viewContext)
                        symptom.name = cell.textLabel!.text
                        symptom.measurement = fetchedMeasurement
                    }
                }
            }
            do {
                try dataController.persistentContainer.viewContext.save()
                navigationController?.popViewController(animated: true)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        
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
}

extension SymptomsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollenSymptoms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell")!
        cell.textLabel?.text = pollenSymptoms[indexPath.row]
        if symptomSelection.contains(pollenSymptoms[indexPath.row]) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)
        
        if currentCell?.accessoryType == UITableViewCell.AccessoryType.none {
            currentCell?.accessoryType = .checkmark
        } else if currentCell?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            currentCell?.accessoryType = .none
        }
    }
}
