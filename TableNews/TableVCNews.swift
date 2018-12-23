//
//  TableVCNews.swift
//  TableNews
//  These are view and controller
//  Created by Valeriy on 12/11/2018.
//
// View and controller class
// Controller - to assign task for model.
// Model updates view through delegates
// Copyright © 2018 Valeriy Nikolaev. All rights reserved.

import UIKit

//model of view
struct NewsForDisplay {
    var author:String! = ""
    var descriptionOfNews:String! = ""
    var imgStr:String! = ""
}

class TableVCNews: UITableViewController,UISearchResultsUpdating,CoreActionsUpdaterDelegate{
    
    var rowsNewsForView:[NewsForDisplay] = []
    var rowsFoundForView:[NewsForDisplay] = []
    var searchCtroller:UISearchController!
    var sessionTask:URLSessionDataTask?
    
    //MARK:Delegate methods,view actions
    func resetViewModel() {
        rowsNewsForView.removeAll()
    }
    
    func insertNewRowInView(newAuthor: String, newDescr: String, newUrlStr: String) {
        let newNews = NewsForDisplay(author: newAuthor, descriptionOfNews: newDescr, imgStr: newUrlStr)
        tableView.beginUpdates()
        rowsNewsForView.append(newNews)
        tableView.insertRows(at: [IndexPath(row: rowsNewsForView.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    //After view model updating calls from model
    func updateRows() {
        tableView.reloadData()
    }
    
    func displayError(error:String) {
        let alert = UIAlertController(title: "ERROR!", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .destructive , handler: nil)
        alert.addAction(ok)
        self.present(alert,animated:true,completion:nil)
    }
    //MARK:End delegate methods
    
    func isSearchActive() -> Bool {
        return searchCtroller.isActive && !searchBarIsEmpty()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchContent(searchText:searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchCtroller.searchBar.text?.isEmpty ?? true
    }
    
    func searchContent(searchText: String) {
        rowsFoundForView = rowsNewsForView.filter({( news : NewsForDisplay) -> Bool in
            let foundNews =  news.descriptionOfNews
            let foundAuthor = news.author
            if foundNews!.uppercased().contains(searchText.uppercased()) || foundAuthor!.uppercased().contains(searchText.uppercased())
            {
                return true
            }else {
                return false
            }
        })
        tableView.reloadData()
    }
    
    func calcHeightOfRow() -> CGFloat {
        if  UIDevice.current.orientation.isPortrait {
            return UIScreen.main.bounds.width * 0.4 + 2
        }else {
            return UIScreen.main.bounds.height * 0.4 + 2
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CellOfTableView.self, forCellReuseIdentifier: "cellId")
        self.tableView.rowHeight = calcHeightOfRow()
        createSearchController()
        let coreActionsModel = CoreActionsModel()
        coreActionsModel.delegateActions = self
        coreActionsModel.setNotificationReminder()
        coreActionsModel.requestInfoFromSite()
        coreActionsModel.freshNews(everySeconds: 900)
        tableView.separatorInset.left = 0
        tableView.separatorColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cellForAligning =  cell as? CellOfTableView {
            cellForAligning.setNeededContentDimensions()
        }
    }
    
    func createSearchController() {
        searchCtroller = UISearchController(searchResultsController:nil)
        searchCtroller.searchResultsUpdater = self
        searchCtroller.obscuresBackgroundDuringPresentation = false
        searchCtroller.searchBar.placeholder = "Search News"
        navigationItem.searchController = searchCtroller
        navigationItem.title = "News"
        definesPresentationContext = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  isSearchActive() {
            return rowsFoundForView.count
        }else {
            return rowsNewsForView.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellContent =  tableView.cellForRow(at: indexPath) as? CellOfTableView else {return}
        let moreInfo = MoreInfoVC()
        cellContent.transmitImageDelegate = moreInfo
        moreInfo.authorLabel.text = "Author: " + cellContent.authorLabel.text!
        moreInfo.moreInfoLabel.text = cellContent.descrLabel.text!
        moreInfo.pictureView.image = cellContent.imageNews.image
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(moreInfo, animated: true)
    }
    
    override func tableView(_ tableViews: UITableView, cellForRowAt: IndexPath) -> UITableViewCell {
        guard let cell = tableViews.dequeueReusableCell(withIdentifier: "cellId") as? CellOfTableView else {
             fatalError("couldn't initialize")
        }
        var valueOfModel:NewsForDisplay?
        if isSearchActive() {
            valueOfModel = rowsFoundForView[cellForRowAt.row]
        }else {
            //to avoid possible crash during scrolling while updating
            if cellForRowAt.row < rowsNewsForView.count {
                valueOfModel = rowsNewsForView[cellForRowAt.row]
            }
        }
        let author = valueOfModel?.author
        let description = valueOfModel?.descriptionOfNews
        let urlStrToImg = valueOfModel?.imgStr
        cell.authorLabel.text = author!
        cell.descrLabel.text = description!
        cell.urlToImg = URL(string: urlStrToImg!)
        return cell
    }
}

protocol ImageTransmitDelegate {
    //In case if user tapped on row but image was not ready
    func imageTransmitDelegateMethod(image:UIImage?)
}

extension UIFont {
    func calcSizeFont() -> CGFloat {
        if  UIDevice.current.orientation.isPortrait {
            return UIScreen.main.bounds.width * 0.05 + 2
        }else {
            return UIScreen.main.bounds.height * 0.05 + 2
        }
    }
}
