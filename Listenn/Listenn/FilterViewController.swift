//
//  FilterViewController.swift
//  Listenn
//
//  Created by Monte with Pillow on 7/2/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit

var savedState = NSUserDefaults.standardUserDefaults()

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var sectionHeaders = ["", "Siri Voice", "Wikipedia Landmarks", "", ""]
    var sectionFooters = ["For best experience, please turn on both.", "", "Makes your wikipedia search results more specific", "", ""]
    var filters = [["Play sound automatically", "Update location with movement"],["Day", "Default", "Regina", "Taylor"], ["All", "Historic", "Modern", "Popular","Touristic"], ["Submit Feedback", "Rate the App"], ["Reset All Filters"]]
    
    var filterVoiceIndex: NSIndexPath?
    
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
        var indexNumber = NSNumber(integer: indexPath.row)
        
        switch(indexPath.section) {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                cell.descriptionLabel.text = filters[indexPath.section][indexPath.row]
                cell.delegate = self
                
                if let value = savedState.objectForKey("soundSwitchValue") {
                    if(indexPath.row == 0) {
                        cell.switchButton.on = value.boolValue
                    }
                } else {
                    print("First time?")
                    cell.switchButton.on = true
                    NSUserDefaults.standardUserDefaults().setObject(true, forKey: "soundSwitchValue")
                    NSUserDefaults.standardUserDefaults().setObject(true, forKey: "locationSwitchValue")
                }
                
                if let value = savedState.objectForKey("locationSwitchValue") {
                    if(indexPath.row == 1) {
                        cell.switchButton.on = value.boolValue
                    }
                }
                    
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("SelectCell", forIndexPath: indexPath) as! SelectCell
                
                if ((savedState.objectForKey("filterVoiceIndex")?.isEqualToNumber(indexPath.row) == true)) {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                    self.filterVoiceIndex = indexPath
                }
                
                //clear NSUserDefaults
//                for key in Array(NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys) {
//                    NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
//                }
                
                if (indexPath.row == 1)
                {
                    let checkedCellObject = savedState.objectForKey("filterVoiceIndex")
                    if ((checkedCellObject) == nil) {
                        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                        self.filterVoiceIndex = indexPath
                    }
                }
                cell.descriptionLabel.text = filters[indexPath.section][indexPath.row]
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("MultipleSelectCell", forIndexPath: indexPath) as! MultipleSelectCell
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch(indexPath.section) {
            case 1:
                if (filterVoiceIndex != nil && filterVoiceIndex != indexPath) {
                    let uncheckCell = tableView.dequeueReusableCellWithIdentifier("SelectCell", forIndexPath: filterVoiceIndex!) as! SelectCell
                    uncheckCell.accessoryType = UITableViewCellAccessoryType.None
                }
                self.filterVoiceIndex = indexPath
                NSUserDefaults.standardUserDefaults().setObject(filterVoiceIndex?.row, forKey: "filterVoiceIndex")
                break;
            default:
                break;
        }
        tableView.reloadData()
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value:Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)
        if (indexPath?.row == 0) {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "soundSwitchValue")
        } else if (indexPath?.row == 1) {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "locationSwitchValue")
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
