//
//  ServiceManager.swift
//  SimpsonsCrew
//
//  Created by aarthur on 8/14/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

class ServiceManager {

    func serviceRequest() -> URLRequest {
        let url = URL.init(string: API.serviceAddress)
        let request = URLRequest.init(url: url!, timeoutInterval: 8)
        
        return request
    }
    
    func startService(completionClosure:@escaping (Error?,Dictionary<String, Any>?)->()) {
        let task = URLSession.shared.dataTask(with: self.serviceRequest(), completionHandler: { (payload: Data?, response: URLResponse?, error: Error?) in
            completionClosure(error,self.parseJSON(payload))
        })
        task.resume()
    }
    
    func parseJSON(_ payload: Data?) -> (Dictionary<String,Any>?) {
        guard let dataResponse = payload else {
                return nil
        }
        do{
            //here dataResponse received from a network request
            let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
            
            guard let jsonDict = jsonResponse as? [String: Any] else {
                return nil
            }
            return jsonDict

        } catch let parsingError {
            print("JSON parse error ", parsingError)
        }
        return nil
    }
}
