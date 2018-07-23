//
//  AppDelegate.swift
//  GreatPriceGrids
//
//  Created by Tim Colley on 27/02/2018.
//  Copyright © 2018 GreatRail. All rights reserved.
//

import Cocoa

@NSApplicationMain

/**
 AppDelegate, or window behaviour related stuff
 
 - Returns: void
 
 - Author: Tim Colley
 - Copyright: Great Rail Journeys 2018
 
 */
class AppDelegate: NSObject, NSApplicationDelegate {


    /**
     Initialize the application
     
     - Returns: void
     
     */
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    /**
     Tear down the application
     
     - Returns: void
     
     */
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    /**
     Kill the app when the last window has been closed (normal 'x' button behaviour)
     
     - Returns: void
     
     */
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
}

