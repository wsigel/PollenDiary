//
//  DWDClient.swift
//  Pollen Diary
//
//  Created by Wolfgang Sigel on 13.06.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation

class DWDClient {
    
    struct Endpoint {
        static let base = "https://opendata.dwd.de/climate_environment/health/alerts/s31fg.json"
    }
    
    class func getPollenData(completion: @escaping(PollenResult?, Error?) -> Void){
        let url = URL(string: Endpoint.base)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(PollenResult.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
