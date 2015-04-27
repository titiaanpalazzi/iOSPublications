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
    
    // ADDED
    // var lastSelectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    var publications = [AnyObject]()
    var filteredPublications = [AnyObject]()
    var selectedCellTitle = String()
    var rowToSelect = NSIndexPath(forRow: 0, inSection: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Query for Parse data
        var query = PFQuery(className: "publicationsLibraryTest7April2014")
        // var query = PFQuery(className: "PublicationsLibraryTest")
        query.findObjectsInBackgroundWithBlock {
            (publications: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                NSLog("Successfully retrieved \(publications.count) publications.")
                // Do something with the found objects
                for publication in publications {
                    let p = publication as PFObject
                    // println(p.valueForKey("fullTitle"))
                }
                // Fill in the array publications, defined on the line after class, with the data that's loaded in your PFQuery
                self.publications = publications
                self.tableView.reloadData()
                println(publications[1])
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
        }
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

//    Stack Overflow answer #1 with full publication
    func filterContentForSearchText(searchText: String) -> [AnyObject] {
        filteredPublications.removeAll(keepCapacity: false)
        for publication in publications {
            if let fullTitle = publication.valueForKey("fullTitle") as? NSString {
                if fullTitle.containsString(searchText) {
                    filteredPublications.append(publication)
                }
            }
        }
        return filteredPublications
    }

    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    //ADDED APRIL 1
    func searchDisplayController(controller: UISearchDisplayController, willHideSearchResultsTableView tableView: UITableView) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredPublications.count
        } else {
            return self.publications.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            if tableView == self.searchDisplayController!.searchResultsTableView {
                cell.textLabel?.text = filteredPublications[indexPath.row].valueForKey("fullTitle") as? String
                cell.detailTextLabel?.text = filteredPublications[indexPath.row].valueForKey("journal") as? String
                println(filteredPublications)
            } else {
                cell.textLabel?.text = publications[indexPath.row].valueForKey("fullTitle") as? String
                cell.detailTextLabel?.text = publications[indexPath.row].valueForKey("journal") as? String
                self.tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: .Top)
            }
        /*
        for publication in publications {
            if let fullTitle = publication.valueForKey("fullTitle") as? NSString {
                if fullTitle.containsString(selectedCellTitle) {
                    var rowToSelectIndexPath = publication.indexPathsForSelectedItems()
                    self.tableView.selectRowAtIndexPath(rowToSelectIndexPath, animated: true, scrollPosition: .Top)
                }
            }
        }*/
    return cell
    }
    
    // New version based on StackOverflow feedback
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Code to store description of selected cell
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        println(selectedCell)
        // Code to store indexPath of selected cell
        rowToSelect = tableView.indexPathForSelectedRow()
        println(rowToSelect)
        // Code to store textLabel of selected cell
        selectedCellTitle = selectedCell?.textLabel?.text ?? ""
        println("The stored cell is called \(selectedCellTitle)")
    }

    
    // Next step: call reselectTheCell in your tableView

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