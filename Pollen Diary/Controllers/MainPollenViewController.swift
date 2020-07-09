//
//  MainPollenViewController.swift
//  Pollen Diary
//
//  Created by Wolfgang Sigel on 02.07.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MainPollenViewController: UIViewController {
    
    var regionId: Int?
    var partRegionId: Int?
    var pollenbelastung: [String:String] = [:]
    var dataController: DataController?
    var lastMeasurement: Measurement?
    
    @IBOutlet weak var pollenBelastungTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLastMeasurementFromStorage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pollenBelastungTableView.dataSource = self
        checkRegionSelection()
        guard let _ = regionId, let _ = partRegionId else {
            return
        }
        // 1. get last stored measurement
        getLastMeasurementFromStorage()
        // 2. check if we already have the current data
        if !currentDataAvailable() {
            // 3a. download current data
            if !AppDelegate.isNetworkAvailable() {
                var alert = UIAlertController(title: "Network Availability", message: "There is no network available to download the requied pollen data. Please check your network settings.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            activityIndicator.startAnimating()
            DWDClient.getPollenData(completion: handlePollenResponse(response:error:))
        } else {
            // 3b. load current data
            pollenbelastung["Ambrosia"] = lastMeasurement!.ambrosia
            pollenbelastung["Beifuss"] = lastMeasurement!.beifuss
            pollenbelastung["Birke"] = lastMeasurement!.birke
            pollenbelastung["Erle"] = lastMeasurement!.erle
            pollenbelastung["Esche"] = lastMeasurement!.esche
            pollenbelastung["Graeser"] = lastMeasurement!.graeser
            pollenbelastung["Hasel"] = lastMeasurement!.hasel
            pollenbelastung["Roggen"] = lastMeasurement!.roggen
        }
        pollenBelastungTableView.reloadData()
    }
    
    fileprivate func getLastMeasurementFromStorage() {
        let fetchRequest: NSFetchRequest<Measurement> = Measurement.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let result = try dataController?.persistentContainer.viewContext.fetch(fetchRequest)
            
            guard let measurements = result else {
                return
            }
            if measurements.count > 0 {
                lastMeasurement = measurements[0]
            }
        } catch {
            fatalError("The last stored measurement could not be retrieved: \(error.localizedDescription)")
        }
    }
    
    func currentDataAvailable() -> Bool {
        var isCurrent = false
        
        if let currentMeasurement = lastMeasurement {
            let today = Date()
            let calendar = Calendar(identifier: .gregorian)
            
            if let creationDate = currentMeasurement.creationDate {
                if calendar.compare(today, to: creationDate, toGranularity:  .day) == ComparisonResult.orderedSame {
                    isCurrent = true
                }
            }
        }
        return isCurrent
    }
    
    @IBAction func symptomsTapped(_ sender: Any) {
        // check for existing measurement from today
        if checkForPresentDayMeasurement() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Symptoms") as! SymptomsViewController
            vc.measurement = lastMeasurement
            vc.dataController = dataController
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Zuordnung Symptome <=> aktuelle Pollenbelastung", message: "Sie müssen die aktuelle Pollenbelastung speichern bevor Sie Symptome zuordnen können.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkForPresentDayMeasurement() -> Bool {
        var measurementAvailable = false
        
        let today = Date()
        let calendar = Calendar(identifier: .gregorian)
        
        if let lastMeasurement = self.lastMeasurement {
            if let creationDate = lastMeasurement.creationDate {
                if calendar.compare(today, to: creationDate, toGranularity: .day) == ComparisonResult.orderedSame {
                    measurementAvailable = true
                }
            }
        }
        return measurementAvailable
    }
    
    @IBAction func zuruecksetzenTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Datenbank zurücksetzen", message: "Hiermit werden alle Einträge unwiderbringlich aus der Datenbank entfernt. Wollen Sie die Aktion trotzdem ausführen?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ja", style: .default, handler: { action in
            self.resetDatabase()
        }))
        alert.addAction(UIAlertAction(title: "Nein", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetDatabase() {
        let fetchRequest: NSFetchRequest<Measurement> = Measurement.fetchRequest()
        do {
            let result = try dataController?.persistentContainer.viewContext.fetch(fetchRequest)
            
            guard let allMeasurements = result else {
                return
            }
            for measurement in allMeasurements {
                dataController?.persistentContainer.viewContext.delete(measurement)
            }
            do {
                try dataController?.persistentContainer.viewContext.save()
                lastMeasurement = nil
            } catch {
                fatalError("Could not save viewContext after deletion: \(error.localizedDescription)")
            }
        } catch {
            fatalError("Could not execute fetchRequest: \(error.localizedDescription)")
        }
    }
    
    @IBAction func statistikTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Statistics") as! StatistikViewController
        vc.dataController = dataController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func speichernTapped(_ sender: Any) {
        let today = NSDate()
        let calendar = Calendar(identifier: .gregorian)
        var measurementToSave: Measurement?
        if let lastMeasurement = self.lastMeasurement {
            if calendar.compare(lastMeasurement.creationDate!, to: today as Date, toGranularity: .day) == ComparisonResult.orderedSame {
                // only 1 measurement per day: display alert
                let alert = UIAlertController(title: "Speichern der aktuellen Pollenbelastung", message: "Die aktuelle Pollenbelastung wurde bereits gespeichert", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // create new measurement for storage
                measurementToSave = createNewMeasurement()
            }
        } else {
            // create new measurement for storage
            measurementToSave = createNewMeasurement()
        }
        guard let measurement = measurementToSave else {
            return
        }
        do {
            try dataController?.persistentContainer.viewContext.save()
            lastMeasurement = measurement
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func createNewMeasurement() -> Measurement {
        let measurement = Measurement(context: dataController!.persistentContainer.viewContext)
        measurement.ambrosia = pollenbelastung["Ambrosia"]!
        measurement.beifuss = pollenbelastung["Beifuss"]!
        measurement.birke = pollenbelastung["Birke"]!
        measurement.erle = pollenbelastung["Erle"]!
        measurement.esche = pollenbelastung["Esche"]!
        measurement.graeser = pollenbelastung["Graeser"]!
        measurement.hasel = pollenbelastung["Hasel"]!
        measurement.roggen = pollenbelastung["Roggen"]!
        measurement.creationDate = Date()
        return measurement
    }
    
    
    @IBAction func einstellungenTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegionSelection") as! RegionSelectionViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkRegionSelection(){
        if UserDefaults.standard.integer(forKey: "RegionId") == 0 && UserDefaults.standard.integer(forKey: "PartRegionId") == 0 {
            // show region selection
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RegionSelection") as! RegionSelectionViewController
            navigationController?.pushViewController(vc, animated: true)
        } else {
            regionId = UserDefaults.standard.integer(forKey: "RegionId")
            partRegionId = UserDefaults.standard.integer(forKey: "PartRegionId")
        }
    }
    
    func handlePollenResponse(response: PollenResult?, error: Error?){
        activityIndicator.stopAnimating()
        if error != nil {
            return
        } else {
            
            let areaPollen = response?.content.filter({ (ContentType) -> Bool in
                ContentType.region_id == regionId && ContentType.partregion_id == partRegionId
            })
            
            let pollenList = areaPollen![0].Pollen
            pollenbelastung["Ambrosia"] = pollenList.Ambrosia.today
            pollenbelastung["Beifuss"] = pollenList.Beifuss.today
            pollenbelastung["Birke"] = pollenList.Birke.today
            pollenbelastung["Erle"] = pollenList.Erle.today
            pollenbelastung["Esche"] = pollenList.Esche.today
            pollenbelastung["Graeser"] = pollenList.Graeser.today
            pollenbelastung["Hasel"] = pollenList.Hasel.today
            pollenbelastung["Roggen"] = pollenList.Roggen.today
            pollenBelastungTableView.reloadData()
        }
    }
}

extension MainPollenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollenbelastung.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! BelastungTableViewCell
        let dictKeys = [String](pollenbelastung.keys)
        let dictValues = [String](pollenbelastung.values)
        cell.pollenartLabel.text = dictKeys[indexPath.row]
        
        var imageStufe: UIImage?
        var bgColor: UIColor?
        
        switch dictValues[indexPath.row] {
            case "-1":
                imageStufe = UIImage(systemName:  "0.circle")
                bgColor = .lightGray
            case "0":
                imageStufe = UIImage(systemName:  "0.circle")
                bgColor = .green
            case "0-1", "1":
                imageStufe = UIImage(systemName:  "1.circle")
                bgColor = .yellow
            case "1-2", "2":
                imageStufe = UIImage(systemName: "2.circle")
                bgColor = .orange
            case "2-3", "3":
                imageStufe = UIImage(systemName: "3.circle")
                bgColor = .red
            default: break
        }
        
        cell.belastungsstufeImageView.backgroundColor = bgColor
        cell.belastungsstufeImageView.image = imageStufe
        cell.belastungsstufeImageView.setNeedsDisplay()
        
        return cell
    }
}
