//
//  ViewController.swift
//  Listenn
//
//  Created by Monte's Pro 13" on 5/2/16.
//  Copyright © 2016 MonteThakkar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func indexChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            detailLabel.text = "Map view under construction"
        case 1:
            detailLabel.text = "List view coming soon"
        default:
            break;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

