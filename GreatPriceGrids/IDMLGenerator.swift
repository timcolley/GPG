//
//  IDMLGenerator.swift
//  GreatPriceGrids
//
//  Created by Tim Colley on 21/05/2018.
//  Copyright © 2018 GreatRail. All rights reserved.
//

import Foundation
import Cocoa

/**
 A class to take in a data set and produce an IDML (In Design Markup Language) snippet file in a user-defined location.
 
 - Returns: void
 
 - Author: Tim Colley
 - Copyright: Great Rail Journeys 2018
 
 */

class idmlGenerator : NSObject {
    
    /// The number of table rows. A dynamic counter to track the progress of the table build.
    var numRows : Int!
    /// The grid mode, this determines the number of columns
    var gridMode : Int!
    /// Container for the column definitions
    var colDefs = ""
    /// Container for the row definitions
    var rowDefs = ""
     /// Container for the cell definitions
    var cellDefs = ""
    ///The number of table columns. A dynamic integer decided by the size of the data array
    var numberOfCOLS = 0;
    /// New var for manipulating init parameter railClass
    var newRailClass: String!
    /// Does the tour have any flights?
    var hasFlights: Bool!
    /// Does the grid need a Late Departures banner?
    var latesBanner: Bool!
    /// Does the tour have regional departures?
    var regDeps: Bool!
    /// Does the grid need any Fly:Home option boxes?
    var flyHome: Bool!
    /// Does the data to be formatted cover two years?
    var doubleYearMode: Bool!
    /// Do we want to discard the tour title (used for tactical brochures)
    var discardTourTitle: Bool!
    /// The first year in the date range
    var yearOne = ""
    /// The second year in the date range (if the range covers two years)
    var yearTwo = ""
    /// The data array
    var data: [[String]]!
    /// Does the tour have a No Single Supplement offer?
    var NSS: Bool!
    /// Does the tour have Standard Class departures?
    var hasStandardClassDepartures = true
    ///Path to bundle resource
    var completeUrl: URL!
    
    //GRJ Code Generation
    var grjGenerator = grjIDML()
    ///RD Code Generation
    var rdGenerator = rdIDML()
    
    /**
     Builds a price grid by reading in a header file, building the price grid, closing the table using another file and finally replaceing placeholder data in the output with a search-replace.
     
        -  parameter tourTitle:                  **String**,     The title of the tour
        -  parameter duration:                   **String**,     The duration of the tour
        -  parameter departureLocation:          **String**,     Where the tour departs from
        -  parameter tourCode:                   **String**,     The tour code
        -  parameter railClass:                  **String**,     The class of the rail travel on the tour
        -  parameter rdl:                        **String**,     The list of regional departures locations for this tour
        -  parameter rdp:                        **String**,     The prices for the regional depature supplements
        -  parameter smallPrint:                 **String**,     The small print for the bottom of the price grid
        -  parameter deposit:                    **String**,     The deposit value for the tour
        -  parameter singlesupp:                 **String**,     The single supplement for the the tour
        -  parameter LatesPanel:                 **Bool**,       Does the price grind need a 'Late Departures' box?
        -  parameter HasFlights:                 **Bool**,       Does the tour have flights?
        -  parameter RegDeps:                    **Bool**,       Does the tour have regional departures?
        -  parameter FlyHome:                    **Bool**,       Does the price grid need a 'Fly:Home' box?
        -  parameter DoubleYearMode:             **Bool**,       Do the departures cover a period of two years?
        -  parameter DiscardTourTitle:           **Bool**,       Does the tour title need to be left off of the price grid?
        -  parameter YearOne:                    **String**,     The year of the departures (in the case of DoubleYearMode being true, this covers the first year on the grid)
        -  parameter YearTwo:                    **String**,     The second year of departures on the grid (if DoubleYearMode is true)
        -  parameter data:                       **[[String]]**, The data array
        -  parameter HasStandardClassDepartures: **Bool**,       Does the tour have a 'Standard Class Rail' option?
        -  parameter firstClassValue:            **String**,     In the case of HasStandardClassDepartures being true, this is the main rail class (not Standard)
        -  parameter format:                     **String**,     What format do we want for the grid? GRJ or RD?
     
     - Returns: void
     
     */
    func buldGrid(tourTitle : String, duration : String, departureLocation : String, tourCode : String, railClass : String, rdl : String, rdp : String, smallPrint : String, deposit : String, singlesupp : String, LatesPanel: Bool, HasFlights: Bool, RegDeps: Bool, FlyHome: Bool, DoubleYearMode: Bool, DiscardTourTitle: Bool, YearOne: String, YearTwo: String, data: [[String]], HasStandardClassDepartures: Bool, firstClassValue: String, format: String) {
        var myString: String! //Container for the final output of the IDML
        latesBanner = LatesPanel
        hasFlights = HasFlights
        regDeps = RegDeps
        flyHome = FlyHome
        doubleYearMode = DoubleYearMode
        discardTourTitle = DiscardTourTitle
        yearOne = YearOne
        yearTwo = YearTwo
        hasStandardClassDepartures = HasStandardClassDepartures
        if (singlesupp == "NSS") { NSS = true } else { NSS = false }
        if (railClass == "International") { newRailClass = "" } else {
            if (HasStandardClassDepartures) {
                newRailClass = firstClassValue
            } else {
                newRailClass = railClass + " Class Rail"
            }
        }
        do {
            /// Path to the app bundle
            var bundlepath = String(describing: Bundle.main)
            bundlepath = bundlepath.replacingOccurrences(of: "> (loaded)", with: "")
            bundlepath = bundlepath.replacingOccurrences(of: "NSBundle <", with: "")
            bundlepath = bundlepath + "/Contents/Resources/"
            /// Full path to the header include that contains the start of the IDML
            var completeUrl = URL(fileURLWithPath: bundlepath).appendingPathComponent("GRJBEGIN.gpg")
            if ( format == "RD" )  { completeUrl = URL(fileURLWithPath: bundlepath).appendingPathComponent("RDSTART.gpg") }
            myString = try String(contentsOf: completeUrl, encoding: String.Encoding.utf8)
            var gridColumns = 2 //the number of grid columns required. Default is 2
            
            if (format == "GRJ") {
                gridColumns = 2
                if (data.count <= 6 && DoubleYearMode == false) { gridColumns = 2 }
                if (data.count <= 6 && DoubleYearMode == true)  { gridColumns = 4 }
                if (data.count <= 4 && DoubleYearMode == true) { gridColumns = 2 }
                if (data.count > 6 && data.count <= 9 && DoubleYearMode == false)  { gridColumns = 3 }
                if (data.count > 9 ) { gridColumns = 4 }
                if (DoubleYearMode == false && HasStandardClassDepartures == true) { gridColumns = 2 }
                if (DoubleYearMode == true && HasStandardClassDepartures == true) { gridColumns = 4 }
                            myString.append(grjGenerator.buildIDMLGrid(gridSize: gridColumns, doubleYear: DoubleYearMode, removeTourTitle: discardTourTitle, LatesBanner: latesBanner, regionalDepartures: regDeps, HasFlights: hasFlights, YearOne: yearOne, YearTwo: yearTwo, HasStandardClassDepartures: HasStandardClassDepartures, FirstClassValue: firstClassValue, hasFlyHome: FlyHome, Data: data))
            }
            if (format == "RD") {
                gridColumns = 3
                if (data.count <= 15 ) { gridColumns = 2 }
                myString.append(rdGenerator.buildIDMLGrid(gridSize: gridColumns, doubleYear: DoubleYearMode, removeTourTitle: discardTourTitle, LatesBanner: latesBanner, regionalDepartures: regDeps, HasFlights: hasFlights, YearOne: yearOne, YearTwo: yearTwo, HasStandardClassDepartures: HasStandardClassDepartures, FirstClassValue: firstClassValue, hasFlyHome: FlyHome, Data: data))
            }
            
            myString = myString.replacingOccurrences(of: "$TOUR_TITLE$", with: tourTitle.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$DURATION$", with: duration.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$DEPARTURE_LOCATION$", with: departureLocation.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$TOUR_CODE$", with: tourCode.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$RAIL_CLASS$", with: newRailClass.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$REGIONAL_DEPARTURE_LIST$", with: rdl.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$REGIONAL_DEPARTURE_PRICES$", with: rdp.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$SMALLPRINT$", with: smallPrint.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$DEPOSIT$", with: deposit.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$SINGLE_SUPPLEMENT$", with: singlesupp.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$YEAR1$", with: yearOne.replacingOccurrences(of: "&", with: "&amp;"))
            myString = myString.replacingOccurrences(of: "$YEAR2$", with: yearTwo.replacingOccurrences(of: "&", with: "&amp;"))
            completeUrl = URL(fileURLWithPath: bundlepath).appendingPathComponent("GRJEND.gpg")
             if ( format == "RD" )  { completeUrl = URL(fileURLWithPath: bundlepath).appendingPathComponent("RDEND.gpg") }
            myString.append(try String(contentsOf: completeUrl, encoding: String.Encoding.utf8))
        } catch { print(error.localizedDescription) }
        /// Save file dialogue
        let saveDialog = NSSavePanel()
        saveDialog.title                   = "Save PriceGrid..."
        saveDialog.showsResizeIndicator    = true
        saveDialog.showsHiddenFiles        = false
        saveDialog.canCreateDirectories    = true
        saveDialog.allowedFileTypes        = ["idms"]
        saveDialog.nameFieldStringValue = tourCode + " " + tourTitle + ".idms"
        if (saveDialog.runModal() == NSApplication.ModalResponse.OK) {
            do {
                let data = Data(myString.utf8)
                try data.write(to: saveDialog.url!, options: .atomic)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
