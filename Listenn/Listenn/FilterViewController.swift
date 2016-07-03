//
//  FilterViewController.swift
//  Listenn
//
//  Created by Monte with Pillow on 7/2/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var sectionHeaders = ["", "Siri Voice", "Wikipedia Landmarks", "", ""]
    var sectionFooters = ["For best experience, please turn on both.\nAlthough be aware of data usage.", "", "Makes your wikipedia search results more specific", "", ""]
    var filters = [["Play sound automatically", "Update location with movement"],["Day", "Default", "Regina", "Taylor"], ["All", "Historic", "Modern", "Popular","Touristic"], ["Submit Feedback", "Rate the App"], ["Reset All Filters"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Table view delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        //Customize the navigation bar title and color
        navigationItem.title = "Set Filters"
        navigationController?.navigationBar.barTintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    // MARK: - Table View Delegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaders[section]
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sectionFooters[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         switch(indexPath.section) {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                cell.descriptionLabel.text = filters[indexPath.section][indexPath.row]
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("SelectCell", forIndexPath: indexPath) as! SelectCell
                cell.descriptionLabel.text = filters[indexPath.section][indexPath.row]
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("SelectCell", forIndexPath: indexPath) as! SelectCell
                cell.descriptionLabel.text = filters[indexPath.section][indexPath.row]
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier("FeedbackCell", forIndexPath: indexPath) as! FeedbackCell
                cell.feebackLabel.text = filters[indexPath.section][indexPath.row]
                return cell
            case 4:
                let cell = tableView.dequeueReusableCellWithIdentifier("ResetCell", forIndexPath: indexPath) as! ResetCell
                cell.resetLabel.text = filters[indexPath.section][indexPath.row]
                return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("SelectCell", forIndexPath: indexPath)
            cell.textLabel?.text = filters[indexPath.section][indexPath.row]
            return cell
        }
    }
    
    @IBAction func cancelBarButton(sender: AnyObject) {
        dismissViewControllerAnimated(true) { 
            print("Cancel button pressed")
        }
    }
    
    @IBAction func doneBarButton(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
            print("Done button pressed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
