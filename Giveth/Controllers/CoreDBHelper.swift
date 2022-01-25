//
//  CoreDBHelper.swift
//  Giveth
//
//  Created by Jagsifat Makkar on 2022-01-23.
//

import Foundation
import CoreData
import UIKit

class CoreDBHelper{
    
    private static var shared : CoreDBHelper?
    private let moc : NSManagedObjectContext
    
    static func getInstance() -> CoreDBHelper {
        if shared != nil{
            //instance of CoreDBHelper class already exists, so return the same
            return shared!
        }else{
            //there is no existing instance of CoreDBHelper class, so create new and return
            shared = CoreDBHelper(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            return shared!
        }
    }
    
    private init(context: NSManagedObjectContext){
        self.moc = context
    }
    
    func insertEntity(_ name : String, _ desc : String, _ type : String, _ email : String, _ password : String, _ address : [String]?, _ deliveryPartnerInfo : [String]?, _ images : [String]?, _ foodItems : [String:Int]?){
        do{
            
            let entityToBeInserted = NSEntityDescription.insertNewObject(forEntityName: "Entity", into: self.moc) as! Entity
            
            entityToBeInserted.name = name
            entityToBeInserted.desc = desc
            entityToBeInserted.email = email
            entityToBeInserted.password = password
            entityToBeInserted.type = type
            entityToBeInserted.address = address
            entityToBeInserted.deliveryPartnerInfo = deliveryPartnerInfo
            entityToBeInserted.images = images
            entityToBeInserted.foodItems = foodItems
            entityToBeInserted.connectionRequests = nil
            entityToBeInserted.activeDonations = nil
            entityToBeInserted.pastDonations = nil
            entityToBeInserted.connections = nil

            if self.moc.hasChanges{
                try self.moc.save()
                print(#function, "Data is saved successfully")
            }
            
        }catch let error as NSError{
            print(#function, "Could not save the data \(error)")
        }
    }
    
    func validateLogin(_ email : String, _ password : String) -> Entity?{
        let entity = self.searchEntityByEmail(email)
        if entity?.password == password{
            return entity
        }
        else{
            return nil
        }
    }
    
    func getEntitiesForHomePage(_ type : String) -> [Entity]?{
        return self.searchEntitiesByType(type)
    }
    
    private func searchEntityByEmail(_ email : String) -> Entity?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        let predicateID = NSPredicate(format: "email == %@", email as CVarArg)
        fetchRequest.predicate = predicateID
        
        do{
            let result = try self.moc.fetch(fetchRequest)
            if result.count > 0{
                return result.first as? Entity
            }
            
        }catch let error as NSError{
            print(#function, "Unable to search for entity \(error)")
        }
        
        return nil
    }
    
    private func searchEntitiesByType(_ type : String) -> [Entity]?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        let predicateID = NSPredicate(format: "type == %@", type as CVarArg)
        fetchRequest.predicate = predicateID
        
        do{
            let result = try self.moc.fetch(fetchRequest)
            if result.count > 0{
                return result as? [Entity]
            }
            
        }catch let error as NSError{
            print(#function, "Unable to search for entities \(error)")
        }
        
        return nil
    }
    
    func getEntityByName(_ name : String) -> Entity?{
        self.searchEntityByName(name)
    }
    
    private func searchEntityByName(_ name : String) -> Entity?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        let predicateID = NSPredicate(format: "name == %@", name as CVarArg)
        fetchRequest.predicate = predicateID
        
        do{
            let result = try self.moc.fetch(fetchRequest)
            if result.count > 0{
                return result.first as? Entity
            }
            
        }catch let error as NSError{
            print(#function, "Unable to search for entities \(error)")
        }
        
        return nil
    }
    
    func deleteAllEntities(){
        let fetchRequest = NSFetchRequest<Entity>(entityName: "Entity")
        do{
            let results = try moc.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as NSManagedObject
                moc.delete(managedObjectData)
                print(#function, "Deleteddddddd")
            }
            UserDefaults.standard.set(false, forKey: "isDataPreLoaded")
        } catch let error as NSError {
            print("Detele all data in Entity - error : \(error) \(error.userInfo)")
        }
    }
    
    func getAllEntities() -> [Entity]? {
        let fetchRequest = NSFetchRequest<Entity>(entityName: "Entity")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: false)]
        
        do{
            let result = try self.moc.fetch(fetchRequest)
            print(#function, "Fetched data : \(result as [Entity])")
            
            return result as [Entity]
            
        }catch let error as NSError{
            print(#function, "Could not fetch data from Database \(error)")
        }
        
        return nil
    }
    
    func updateEntityConnectionRequests(_ senderName : String, _ receiverName : String){
        let searchResult = self.searchEntityByName(receiverName)
        
        if (searchResult != nil){
            do{
                let receiverEntity = searchResult!
                if receiverEntity.connectionRequests == nil{
                    receiverEntity.connectionRequests = []
                }
                receiverEntity.connectionRequests?.append(senderName)
                
                try self.moc.save()
                print(#function, "Entity Updated Successfully")
                
            }catch let error as NSError{
                print(#function, "Unable to update entity \(error)")
            }
            
        }else{
            print(#function, "No matching entity found")
        }
    }
    
    func deleteConnectionRequest(_ senderName : String, _ rejectorName : String){
        let searchResult = self.searchEntityByName(rejectorName)
        
        if (searchResult != nil){
            do{
                let rejectorEntity = searchResult!
                var i = -1
                print(rejectorEntity.connectionRequests!.count)
                for x in 0..<rejectorEntity.connectionRequests!.count{
                    if rejectorEntity.connectionRequests![x] == senderName{
                        i = x
                        break
                    }
                }
                if i > -1{
                    rejectorEntity.connectionRequests?.remove(at: i)
                }
                try self.moc.save()
                print(#function, "Entity Updated Successfully 1")
                
            }catch let error as NSError{
                print(#function, "Unable to update entity \(error)")
            }
            
        }else{
            print(#function, "No matching entity found")
        }
    }
    
    func deleteConnection(_ name1 : String, _ name2 : String){
        var searchResult = self.searchEntityByName(name1)
        
        if (searchResult != nil){
            do{
                let entity1 = searchResult!
                var i = -1
                for x in 0..<entity1.connections!.count{
                    if entity1.connections![x] == name2{
                        i = x
                        break
                    }
                }
                if i > -1{
                    entity1.connections?.remove(at: i)
                }
                try self.moc.save()
                print(#function, "Entity Updated Successfully 1")
                
            }catch let error as NSError{
                print(#function, "Unable to update entity \(error)")
            }
            
        }else{
            print(#function, "No matching entity found")
        }
        
        searchResult = self.searchEntityByName(name2)
        
        if (searchResult != nil){
            do{
                let entity2 = searchResult!
                var i = -1
                for x in 0..<entity2.connections!.count{
                    if entity2.connections![x] == name1{
                        i = x
                        break
                    }
                }
                if i > -1{
                    entity2.connections?.remove(at: i)
                }
                try self.moc.save()
                print(#function, "Entity Updated Successfully 2")
                
            }catch let error as NSError{
                print(#function, "Unable to update entity \(error)")
            }
            
        }else{
            print(#function, "No matching entity found")
        }
    }
    
    func updateEntitiesConnections(_ senderName : String, _ approverName : String){
        var searchResult = self.searchEntityByName(approverName)
        
        if (searchResult != nil){
            do{
                let approverEntity = searchResult!
                if approverEntity.connections == nil{
                    approverEntity.connections = []
                }
                approverEntity.connections?.append(senderName)
                var i = -1
                for x in 0..<approverEntity.connectionRequests!.count{
                    if approverEntity.connectionRequests![x] == senderName{
                        i = x
                        break
                    }
                }
                approverEntity.connectionRequests?.remove(at: i)
                
                try self.moc.save()
                print(#function, "Entity Updated Successfully 1")
                
            }catch let error as NSError{
                print(#function, "Unable to update entity \(error)")
            }
            
        }else{
            print(#function, "No matching entity found")
        }
        
        searchResult = self.searchEntityByName(senderName)
        
        if (searchResult != nil){
            do{
                let senderEntity = searchResult!
                if senderEntity.connections == nil{
                    senderEntity.connections = []
                }
                senderEntity.connections?.append(approverName)
                
                try self.moc.save()
                print(#function, "Entity Updated Successfully 2")
                
            }catch let error as NSError{
                print(#function, "Unable to update entity \(error)")
            }
            
        }else{
            print(#function, "No matching entity found")
        }
        
    }
    
    func preLoadData(){
        if UserDefaults.standard.bool(forKey: "isDataPreLoaded"){
            print(#function, "Data already loaded")
        }
        else{
            self.insertEntity("Alo Restaurant", "Alo, which opened in July of 2015, is a contemporary French restaurant located atop a heritage building in downtown Toronto. Our cuisine is internationally inspired and celebrates the finest in seasonal ingredients paired with a genuine sense of welcome. We are refiners: we take time-honoured comforts and seek to do them better than we did last time, evolving to make them ever more delightful.", "restaurant", "alo@gmail.com", "alo123", ["163 Spadina Ave", "Toronto", "Canada"], ["Mike Burnson", "6479371000"], ["alo-1", "alo-2"], ["Rice":3, "Orange Juice":5, "Apple Box":3, "White Bread":6, "Egg Tray":2])
            
            self.insertEntity("Miku", "ABURI Restaurant’s first East Coast location is situated in Toronto’s Harbour Front at Bay and Queen’s Quay. With over 7000 square feet, a raw bar, sushi bar, and large patio, Miku brings contemporary upscale design to the Southern Financial District.  Expanding East from Vancouver roots, ABURI Restaurants and Miku Vancouver are well known both locally and worldwide for Aburi Sushi.", "restaurant", "miku@gmail.com", "miku123", ["10 Bay St. #105", "Toronto", "Canada"], ["Gabe Topland", "6479371003"], ["miku-1", "miku-2"], ["Flour Pack":5, "Apple Juice":5, "Strawberry Box":2, "Brown Bread":9, "Cheese Slices Pack":5])
            
            self.insertEntity("Wilbur Mexicana", "This apothecary-inspired counter serve dishes up Mexican street food like tacos & burritos.", "restaurant", "wilbur@gmail.com", "wilbur123", ["552 King St W", "Toronto", "Canada"], ["Tom Holland", "6479341000"], ["wilbur-1", "wilbur-2"], ["Carrot Pack":2, "Peach Juice":8, "Orange Box":4, "Hot Dogs Pack":6, "Salami Pack":4])
            
            self.insertEntity("Rasa", "Located in the heart of Harbord Village, Rasa offers a globally inspired snacks and entrees in a sleek, dark space from food-truck mavens The Food Dudes.", "restaurant", "rasa@gmail.com", "rasa123", ["196 Robert Street", "Toronto", "Canada"], ["Trojan Goman", "6379371400"], ["rasa-1", "rasa-2"], ["Melon Box":3, "Mango Juice":6, "Burger Buns Box":1, "Oreo Cookies Pack":9, "Beans Pack":4])
            
            self.insertEntity("Seven Lives", "Seven Lives is located in the heart of Toronto's historic Kensington Market.  We established ourselves in 2012 with a mission serve the freshest and tastiest Baja style tacos in a fun and exciting atmosphere.", "restaurant", "seven@gmail.com", "seven123", ["72 Kensington Ave", "Toronto", "Canada"], ["Roman Empire", "6489371000"], ["seven-1", "seven-2"], ["Capsicum Pack":7, "Litchi Juice":2, "Donuts Box":4, "Watermelon":3, "Yogurt Pack":3])
            
            self.insertEntity("Vivid Issues", "The mission is to significantly improve the mental health and well-being of all members of the community through counseling, education, support, and advocacy.", "charity", "vivid@gmail.com", "vivid123", ["20 Major St", "Toronto", "Canada"], nil, ["vivid-1", "vivid-2"], nil)
            
            self.insertEntity("Time To Protect", "To provide medicines and health supplies to those in need around the world so they might experience life to the fullest.", "charity", "time@gmail.com", "time123", ["56 Harbord St", "Toronto", "Canada"], nil, ["time-1", "time-2"], nil)
            
            self.insertEntity("Go Heart", "We face the extinction of one million species in our lifetimes. But there is still hope. The solution to the extinction crisis lies in the expansion of natural habitats in threatened wild places. We must enlarge and protect the spaces devoted to the natural world in order to save the amazing variety of life on our planet – called biodiversity.", "charity", "go@gmail.com", "go123", ["32 College St", "Toronto", "Canada"], nil, ["go-1", "go-2"], nil)
            
            self.insertEntity("Save The Crying", "A nonprofit focused on preparing low-income populations to succeed as independent workers. We’ve brought together a passionate group of social entrepreneurs and educators who are reimagining workforce development for the 21st century.", "charity", "save@gmail.com", "save123", ["675 Queen St. W", "Toronto", "Canada"], nil, ["save-1", "save-2"], nil)
            
            self.insertEntity("High On Empathy", "Our mission is to improve the lives of refugees and the efficiency of humanitarian services by eliminating language barriers.", "charity", "high@gmail.com", "high123", ["954 Bathurst St", "Toronto", "Canada"], nil, ["high-1", "high-2"], nil)
            
            UserDefaults.standard.set(true, forKey: "isDataPreLoaded")
        }
    }
    
    func clearLoadedData(){
        
    }
    
    
}
