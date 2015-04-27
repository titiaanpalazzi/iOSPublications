//
//  PublicationTableViewController.swift
//  Publications
//
//  Created by Titiaan Palazzi on 1/31/15.
//  Copyright (c) 2015 Rocky Mountain Institute. All rights reserved.
//

import UIKit
import MessageUI

class PublicationTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate, MFMailComposeViewControllerDelegate {
    
    var publications = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Query for Parse data
        var query = PFQuery(className: "PublicationsLibraryTest")
        query.findObjectsInBackgroundWithBlock {
            (publications: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(publications.count) publications.")
                // Do something with the found objects
                for publication in publications {
                    let p = publication as PFObject
                    println("test: \(p.objectId)")
                    // println(p.valueForKey("fullTitle"))
    
                }
                // Fill in the array publications, defined on the line after class, with the data that's loaded in your PFQuery
                self.publications = publications
                self.tableView.reloadData()
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

////  THIS IS THE CODE FOR FILTERED PUBLICATIONS, NECESSARY FOR A SEARCHBAR
    var filteredPublications = [AnyObject]()
//    // Is this the right type of object? filteredPublications will sort parts of publications, which includes several strings. Alternative: PFObject
//    
    func filterContentForSearchText(searchText: String) {
//        // Filter the array using the filter method
//        
    var filteredPublications = publications.filter({ p in p.valueForKey("fullTitle") != nil})
    }
    
//        // attempt 1
//        // http://stackoverflow.com/questions/24117508/filtering-tuple-in-swift
//        self.filteredPublications = self.publications.filter({ ($0 as NSString).localizedCaseInsensitiveContainsString("\(searchText)") })
//        // attempt 2
//        // http://www.raywenderlich.com/76519/add-table-view-search-swift
//        self.filteredPublications = self.publications.filter({ (publication: publications[indexPath.row]) -> Bool in
//            let titleMatch = publication.valueForKey("fullTitle").rangeOfString(searchText)
//            return titleMatch
//            })
//        // attempt 3
//        // http://rshelby.com/2014/09/filtering-arrays-containing-multiple-data-types-in-swift/
//        let filteredPublications = publications.filter({ p in p.valueForKey("fullTitle").containsString(searchText)
//            })
//        
//        //attempt 4
//        //Can you write this as a for loop? For p in publications, if p = searchText, 1, else, 0? No, because then you'll re-write every instance again.
//        
//    }
//    // maybe I need to rewrite this code to (1) specify which part of publications should be filtered (journal, title, etc.) and (2) to include the code from Ray Wenderlich's tutorial
//    
//    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
//        self.filterContentForSearchText(searchString)
//        return true
//    }
////  End of code for filtered publications

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

//  UNCOMMENT TO SHOW UNSORTED LIST
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publications.count
    }

////    UNCOMMENT TO SHOW SORTED LIST
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == self.searchDisplayController!.searchResultsTableView {
//            return self.filteredPublications.count
//        } else {
//            return self.publications.count
//        }
//    }

    
//    (UN)COMMENT TO SHOW UNSORTED LIST
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

         let publication = self.publications[indexPath.row] as PFObject
         cell.textLabel?.text = publication.valueForKey("fullTitle") as? String
         cell.detailTextLabel?.text = publication.valueForKey("journal") as? String
        
//        //  (UN)COMMMENT TO SHOW SORTED LIST
//            if tableView == self.searchDisplayController!.searchResultsTableView {
//                cell.textLabel?.text = filteredPublications[indexPath.row].valueForKey("fullTitle") as? String
//                cell.detailTextLabel?.text = filteredPublications[indexPath.row].valueForKey("journal") as? String
//            } else {
//                cell.textLabel?.text = publications[indexPath.row].valueForKey("fullTitle") as? String
//                cell.detailTextLabel?.text = publications[indexPath.row].valueForKey("journal") as? String
//            }
        
    return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    var emailText = String()
    
    @IBAction func mail(sender: AnyObject) {
        if let selected = tableView.indexPathsForSelectedRows() {
            // the if let in Ronald's code is used to say if any of the articles are selected, than write down the indexPaths
        
            var selectedPublications = [PFObject]()
            
            
            for index in selected {
                
                let i = index as NSIndexPath
                
                let publication = self.publications[i.row] as PFObject
                let fullTitle = publication.valueForKey("fullTitle") as? String
                let journal = publication.valueForKey("journal") as? String
                let url = publication.valueForKey("url") as? String
                
                if let fullTitle = fullTitle {
                    emailText += "\(fullTitle) "
                }
                if let url = url {
                    emailText += "\n\(url)\n\n"
                }
            }
            println("emailtext:\n \(emailText)")
        }
        
        let mailComposeViewController = configuredMailComposeViewController(emailText)
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController(text: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("Articles from Amory Lovins")
        mailComposerVC.setMessageBody("Thank you for your interest in RMI. Please find selected articles below:\n\n \(emailText)", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "MailSegue" {
            
            if let selected = tableView.indexPathsForSelectedRows() {

                var selectedPublications = [PFObject]()
                for index in selected {
                    
                    let i = index as NSIndexPath
                    selectedPublications.append(self.publications[i.row] as PFObject)
                }
                println("Selected: \(selectedPublications)")
                
            }
        }
    }
}