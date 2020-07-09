//
//  DataController.swift
//  Pollen Diary
//
//  Created by Wolfgang Sigel on 04.07.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    static let sharedDataController = DataController()
    
    private init(){}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PollenDiary")
        
        
        container.loadPersistentStores(completionHandler: { (storeDesciption, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    

}
