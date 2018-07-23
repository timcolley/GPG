//
//  ViewController.swift
//  GreatPriceGrids
//
//  Created by Tim Colley on 27/02/2018.
//  Copyright © 2018 GreatRail. All rights reserved.
//

import Cocoa

/**
 View controller for the about box
 
 - Returns: void
 
 - Author: Tim Colley
 - Copyright: Great Rail Journeys 2018
 
 */
class aboutController: NSViewController {
    
    /**
     Actions to perform when the view has loaded
     
     - Returns: void
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    /**
     Update the view, if already loaded.
     
     - Returns: void
     
     */
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    /**
     Close the window
     
     - Returns: void
     
     */
    @IBAction func btnOK_Click(_ sender: Any) {
        self.view.window!.close()
    }
    
}



