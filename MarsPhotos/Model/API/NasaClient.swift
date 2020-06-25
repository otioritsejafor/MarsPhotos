//
//  NasaClient.swift
//  MarsPhotos
//
//  Created by Oti Oritsejafor on 6/22/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import Foundation


protocol DataTaskMaker {
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: DataTaskMaker { }

class NasaClient {
    let session: DataTaskMaker
    let baseURL: URL
    
    static let shared = NasaClient(session: URLSession.shared,
                                   baseURL: URL(string: Endpoints.base)!)
    
    init(session: DataTaskMaker, baseURL: URL) {
        self.session = session
        self.baseURL = baseURL
    }
    
    enum Endpoints {
        static let base = "https://api.nasa.gov/mars-photos/api/v1/rovers"
        static let apiKeyParam = "&api_key=DEMO_KEY"
        
        // MARK: GET
        case getCuriosity(Int)
        case getSpirit
        case getOpportunity(Int)
        case getImage(String)
        
        var stringValue: String {
            switch self {
            case .getCuriosity(let page):
                
                return Endpoints.base + "/curiosity/photos?sol=1000&page=\(page)" + Endpoints.apiKeyParam
            case .getSpirit:
                return Endpoints.base + "/spirit/photos?sol=1000" + Endpoints.apiKeyParam
            case .getOpportunity(let page):
                switch page {
                case 0:
                    return Endpoints.base + "/opportunity/photos?sol=500" + Endpoints.apiKeyParam
                default:
                    return Endpoints.base + "/opportunity/photos?sol=500&page=\(page)" + Endpoints.apiKeyParam
                }
                
            case .getImage(let imageURL):
                return "\(imageURL)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
        
    }
    
    func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
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
    
    class func getRoverImage(imagePath: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getImage(imagePath).url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    print("Failed to return thumbnail image")
                    completionHandler(nil, error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(data, nil)
            }
        }
        
        task.resume()
    }
    
    func getCuriosityPhotos(page: Int, completion: @escaping (RoverData?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getCuriosity(page).url, response: RoverData.self) { response, error  in
            if let response = response {
                
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func getOpportunityPhotos(page: Int, completion: @escaping (RoverData?, Error?) -> Void) {
           taskForGETRequest(url: Endpoints.getOpportunity(page).url, response: RoverData.self) { response, error  in
               if let response = response {
                   
                   completion(response, nil)
               } else {
                   completion(nil, error)
               }
           }
       }
    
}
