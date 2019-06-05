//
//  CoreActionsModel.swift
//  TableNews
//
//  Here is a model
//
//  Created by Valeriy on 25/11/2018.
//
// Class model logic (business logic) in MVC
// main tasks are:
// 1. Get data from server
// 2. Store data
// 3. Send data from storage to view
// 4. Triggers view updating
// 5. freshNews (To new update) implimentation here. Method  which is called from controller.
// Copyright © 2018-2019 Valeriy Nikolaev. All rights reserved.

import UIKit
import CoreData
import Foundation
import UserNotifications


class CoreActionsModel {

    var articlesDict:[[String: Any]]?
    weak var delegateActions:CoreActionsUpdaterDelegate?
    let appDelegate =
        UIApplication.shared.delegate as? AppDelegate
    var managedContext:NSManagedObjectContext!
    
    func cleanStorage() {
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ListOfRecords")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            self.delegateActions?.displayError(error: "There was an error while trying to clean storage")
            print ("There was an error while trying to clean storage")
        }
    }
    
    func save (author:String,descr:String,urlToImg:String) {
        let newEntityObj =
            NSEntityDescription.insertNewObject(forEntityName: "ListOfRecords", into: managedContext)
        newEntityObj.setValue(urlToImg, forKeyPath: "urltoimgstr")
        newEntityObj.setValue(author, forKeyPath: "author")
        newEntityObj.setValue(descr, forKeyPath: "descr")
        do {
            try managedContext.save()
        } catch let error as NSError {
            delegateActions?.displayError(error: "Fatal: data is failed to save,\(error.localizedDescription) ")
        }
    }
    
    //Notification by sceduele. It is triggered only once after application is started
    //The app reminds at 14:00
    func setNotificationReminder() {
        let content = UNMutableNotificationContent()
        content.title = "News reminder"
        content.body = "Tap me to check news"
        content.sound = UNNotificationSound.default
        content.badge = 1
        let date = Date()
        let currentCalendar = Calendar.current
        var calendarComponents = currentCalendar.dateComponents([.hour,.minute,.second,.day], from: date)
        if let day = calendarComponents.day  {
            calendarComponents.day = day + 1
        }
        calendarComponents.hour = 14
        calendarComponents.minute = 00
        calendarComponents.second = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendarComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "requestIdFirst", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    //Get data from server
    //Send data to view and to storage
    func demonstrationData() {
        delegateActions?.resetViewModel()
        delegateActions?.updateRows()
        let author  = "AUTHOR UNKNOWN"
        let description = "TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION TEST DESCRIPTION"
        let urlToImageStr = "NO IMAGE"
        print("demo data")
        for _ in 0 ..< 10 {
            delegateActions?.insertNewRowInView(newAuthor:author, newDescr: description, newUrlStr: urlToImageStr)
        }

    }

    @objc func requestInfoFromSite() {
        //MARK: ATTENTION ! URL with API key should be here:
        let url = URL(string:"<YOUR LINK SHOULD BE HERE>")
        if url == nil {
            DispatchQueue.main.async {
                self.sendRecordsFromCoreData()
                self.delegateActions?.errorSuggestTestPattern(error:"Seems URL with API key is incorrect. Please check URL in CoreActionsModel.swift file. \n Would you like to see a demo pattern instead?")
            }
            return
        }
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: url!) { [weak self] (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.sendRecordsFromCoreData()
                    self?.delegateActions?.displayError(error: error!.localizedDescription)
                }
                return
            }
            let jsonDic = try! JSONSerialization.jsonObject(with: data, options: [])
                as? [String: Any]
            self?.articlesDict = jsonDic?["articles"] as? [[String: Any]]
            var isDictEmpty = true
            if self?.articlesDict == nil {
                DispatchQueue.main.async {
                    self?.sendRecordsFromCoreData()
                    self?.delegateActions?.displayError(error: "Couldn't fetch info from server.\nMaybe link is wrong.")
                }
                return
            }
            if (self?.articlesDict?.count)! > 1 {
                isDictEmpty = false
            }
            for article in (self?.articlesDict)! {
                var author = article["author"] as? String
                if author  == nil {
                    author  = "AUTHOR UNKNOWN"
                }
                var description = article["description"] as? String
                if description == nil {
                    description = "NO DESCRIPTION"
                }
                var urlToImageStr = article["urlToImage"] as? String
                if urlToImageStr == nil {
                    urlToImageStr = "NO IMAGE"
                }
                //Going to pass data to the main queue
                //It is serial queue and works as FIFO.
                //Main queue will handle it consistently even if data goes too fast.
                DispatchQueue.main.async {
                    //Dictionary is not empty so delete all the old data and load new
                    if isDictEmpty == false {
                        self?.cleanStorage()
                        self?.delegateActions?.resetViewModel()
                        self?.delegateActions?.updateRows()
                        isDictEmpty = true
                    }
                    //Send data to view
                    self?.delegateActions?.insertNewRowInView(newAuthor:author!, newDescr: description!, newUrlStr: urlToImageStr!)
                    //Save to storage
                    self?.save(author: author!, descr: description!, urlToImg: urlToImageStr!)
                }
            }
        }.resume()
    }
    
    func sendRecordsFromCoreData () {
        //to avoid appending dublicates
        delegateActions?.resetViewModel()
        let fetchRequest =
                        NSFetchRequest<NSManagedObject>(entityName: "ListOfRecords")
        do {
            let newsModel = try managedContext.fetch(fetchRequest)
            for news in newsModel as! [ListOfRecords] {
                //Here is view is filling: model -> view
                delegateActions?.insertNewRowInView(newAuthor:news.author!, newDescr: news.descr!, newUrlStr: news.urltoimgstr!)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            self.delegateActions?.displayError(error: error.localizedDescription)
        }
        delegateActions?.updateRows()
    }
    
    init () {
        managedContext =
            appDelegate!.persistentContainer.newBackgroundContext()
    }
    
    //freshNews method is called from controller
    func freshNews(everySeconds:Double) {
        _ = Timer.scheduledTimer(timeInterval: everySeconds, target: self, selector: #selector(self.requestInfoFromSite), userInfo: nil, repeats: true)
    }
    
}

//MARK: Here is delegation declaring for send data to view and updating view
protocol CoreActionsUpdaterDelegate:class {
    func resetViewModel()
    func insertNewRowInView(newAuthor:String,newDescr:String,newUrlStr:String)
    func updateRows()
    func displayError(error:String)
    func errorSuggestTestPattern(error:String)
}

