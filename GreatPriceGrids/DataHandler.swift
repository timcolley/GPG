//
//  DataHandler.swift
//  GreatPriceGrids
//
//  Created by Tim Colley on 06/03/2018.
//  Copyright © 2018 GreatRail. All rights reserved.
//

import Foundation


/**
 A class that holds the objects dataset and all contained variables.
 it accepts a tourCode and start & end date for filtering the results
 
 - Author: Tim Colley
 - Copyright: Great Rail Journeys 2018

 */
class DataHandler : NSObject {
    ///Source Data
    var tours = [[String]]()
    ///Date Range Start
    var startDate = Date()
    ///Date Range End
    var endDate = Date()
    ///The Tour Title
    var tourTitle = ""
    ///Duration of the tour
    var numOfDays = ""
    ///Where does the tour start?
    var departureLocation = ""
    ///What's the tour code?
    var tourCode = ""
    ///Does the customer nned a visa (Currently  mode 0, 1 or NA)
    var requiresVisa = ""
    ///Do we need a Late departures box on this grid? (this isn't in the source data, it is a user option)
    var lateDeparturesBox = false
    ///Does the data cover more that one calender Year?
    var doubleYearMode = false
    ///What year is Year 1? If doubleYearMode is false, then this is the only year
    var yearOne = ""
    ///What Year is Year 2?
    var yearTwo = ""
    ///Is the tour First class?
    var hasRailClass1 = false
    ///Is the tour Standard Class?
    var hasRailClass2 = false
    ///Is the tour First AND Standard class?
    var hasRailClass12 = false
    ///Are there flights on theis tour? if yes then add the 'with Economy Class Flights' text below the rail class
    var hasFlights = false
    ///Does this tour have Regional Departures?
    var hasRegionalDepartures = false
    ///Regional Departures List
    var regionalDeparturesAirports = ""
    ///Regional Departures Prices
    var regionalDeparturesSupplements = ""
    ///Is there a flight upgrade box on this tour? (this isn't in the source data, it is a user option)
    var hasFlightUpgrade = false
    ///How much is the tour deposit?
    var deposit = ""
    ///How much is the single supplement?
    var singleSupplement = ""
    ///What is the smallprint?
    var smallprint = ""
    ///DEPRECIATED!!
    var railClass = ""
    ///Dynamic rows, Price grid Data, Probably depreciated due to shift to IDML output
    var multiColumnPG = [[[String]]]()
    ///Do we want to remove the tour title?
    var removeTourTitle: Bool!
    ///Does the tour have Fly:Home departures?
    var hasFlyHome: Bool!
    ///Do we want a lates banner?
    var hasLatesBanner: Bool!
    ///Contaner to hold raw data before processing. Really shouldn't be here as it's a result of lazy coding. Should be removed in future refactoring.
    var rawdata = [[String]]()
    
    /**
     Initializes a new DataHandler with the provided TourCode and Date Range.
     
     - Parameter tourCode: The tour code of the currently selected tour
     - Parameter startDate: The start of the date range
     - Parameter endDate: The end of the date range
     
     - Returns: void
     */
    init(tourCode: String, startDate: String, endDate: String) {
        super.init()
        if (startDate == "" || endDate == "") {
            setTourData(tourData: DBManager.shared.returnTours(tourCode: tourCode))
            setTourCode(tc: tourCode)
        } else {
            setTourData(tourData: DBManager.shared.returnToursInDateRange(tourCode: tourCode, startDate: startDate, endDate: endDate))
            setTourCode(tc: tourCode)
        }
        
    }
    
    /**
        A method that initialises the objects dataset and all contained variables.
     
     - Parameter tourData: **[[String]]** a 3d Array of tour information
 
     */
    func setTourData(tourData: [[String]]) {
        rawdata = tourData
        tours = cleanTourDates(dates: setSoldOuts(tourData: tourData)) //import & scrub the data
        setDoubleYear()                         //Check the status of the year codes
        setRailClass()                          //Set the default rail class (TO DO : and check for standard class departures, those need 3/4 column grids)
        setDepartureLocation()                  //Set the default Departure Location for this tour.
        setStartDate()                          //Sets the start date of the tour
        setEndDate()                            //set the end date of the tour
        setStandardClassOption()                //Test for a standard class option
        
        smallprint = "E=Eurostar Meal, B=Breakfast, L=Lunch, D=Dinner. These meals, where shown are included in the price of your holiday. Please note, an increased deposit may be required for upgrades and variations. Please read our Booking Conditions available on request or online before you book"
        setupAirports()
        setupVisa()
        
    }
    
    /**
     returns the entire dataset in a *clean* format.
     
     - Returns: **[[String]]** a 3d Array of tour information
     
 
    func getAllData() -> [[String]] {
        return tours
    }
    */
    
    /**
     returns a boolean value indicating the presence of a standard class option
     
     - Returns: **String** the value of the departure location
     
     */
    func getStandardOptionStatus() -> Bool {
        if (hasRailClass1 == true && hasRailClass2 == true || hasRailClass12 == true && hasRailClass2 == true) {
            return true
        } else {
            return false
        }
    }
    
    
    /**
     Sets the departure location for the current tour
     
     */
    
    func setDepartureLocation() {
        
        departureLocation = tours[0][11]
        if ( departureLocation == "LHR Heathrow") { departureLocation = "London Heathrow" }
        if ( departureLocation == "LGW Gatwick") { departureLocation = "London Gatwick" }
        
    }
    
    /**
     Sets the rail class for the current tour
     
     - Returns: **String** the value of the rail class
     
     */
    
    func setRailClass() {
        railClass = tours[0][5]
    }
    
    /**
     sets the tour code for the current tour
     
     - Parameter: **String** the tour code
     
     */
    func setTourCode(tc: String) {
        tourCode = tc
    }
    
    /**
     Sets the Start date of the date range for the current tour
     
     */
    func setStartDate() {
        startDate = stringToDate(date: tours[0][1])
    }
    /**
     Sets the end date of the date range for the current tour
     
     */
    func setEndDate() {
        endDate = stringToDate(date: tours.last![1])
    }
    
    /**
     Converts s String to a Date object
     
     - Parameter date: **String** the string of the date
     
     - Returns: **Date** the date object
     
     */
    func stringToDate(date: String) -> Date {
        var newDate: Date!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        if let showDate = dateFormatter.date(from: date){
            dateFormatter.dateFormat = "dd/MM/YYYY"
            newDate = showDate
        }
        return newDate
    }
    
    /**
     Analyses the Regional departure options and bulds a human readable representation of the data.

     */
    func setupAirports() {
        var BHX = false
        var MAN = false
        var NEW = false
        var EDI = false
        var GLA = false
        var STD = false
        
        var BHXValue = ""
        var MANValue = ""
        var NEWValue = ""
        var EDIValue = ""
        var GLAValue = ""
        var STDValue = ""

        
        regionalDeparturesAirports = "Regional Departures Available from "
        regionalDeparturesSupplements = "Regional Departure supplement prices: "
        for x in 0 ... (tours.count-1){
            for i in 15 ... 20 {
                if (tours[x][i] != "") {
                    switch i {
                    case 15:
                        if (!BHX) {
                            regionalDeparturesAirports.append("Birmingham, ");
                            regionalDeparturesSupplements.append("Birmingham from £BHX extra, ");
                            BHXValue = tours[x][i]
                            BHX = true
                        } else {
                            if (tours[x][i] < BHXValue) {  BHXValue = tours[x][i] }
                        }
                        break;
                    case 16:
                        if (!MAN) {
                            regionalDeparturesAirports.append("Manchester, ");
                            regionalDeparturesSupplements.append("Manchester from £MAN extra, ");
                            MANValue = tours[x][i]
                            MAN = true
                        } else {
                            if (tours[x][i] < MANValue) {  MANValue = tours[x][i] }
                        }
                        break;
                    case 17:
                        if (!NEW) {
                            regionalDeparturesAirports.append("Newcastle, ");
                            regionalDeparturesSupplements.append("Newcastle from £NEW extra, ");
                            NEWValue = tours[x][i]
                            NEW = true
                        } else {
                            if (tours[x][i] < NEWValue) {  NEWValue = tours[x][i] }
                        }
                        break;
                    case 18:
                        if (!EDI) {
                            regionalDeparturesAirports.append("Edinbrugh, ");
                            regionalDeparturesSupplements.append("Edinbrugh from £EDI extra, ");
                            EDIValue = tours[x][i]
                            EDI = true
                        } else {
                            if (tours[x][i] < EDIValue) {  EDIValue = tours[x][i] }
                        }
                        break;
                    case 19:
                        if (!GLA) {
                            regionalDeparturesAirports.append("Glasgow, ");
                            regionalDeparturesSupplements.append("Glasgow from £GLA extra, ");
                            GLAValue = tours[x][i]
                            GLA = true
                        } else {
                            if (tours[x][i] < GLAValue) {  GLAValue = tours[x][i] }
                        }
                        break;
                    case 20:
                        if (!STD) {
                            regionalDeparturesAirports.append("Stansted, ");
                            regionalDeparturesSupplements.append("Stansted from £STD extra, ");
                            STDValue = tours[x][i]
                            STD = true
                        } else {
                            if (tours[x][i] < STDValue) {  STDValue = tours[x][i] }
                        }
                        break;
                    default:
                        break;
                    }
                    hasRegionalDepartures = true;
                }
            }
        }
        
        if (BHX) { regionalDeparturesSupplements = regionalDeparturesSupplements.replacingOccurrences(of: "BHX", with: BHXValue) }
        if (MAN) { regionalDeparturesSupplements = regionalDeparturesSupplements.replacingOccurrences(of: "MAN", with: MANValue) }
        if (NEW) { regionalDeparturesSupplements = regionalDeparturesSupplements.replacingOccurrences(of: "NEW", with: NEWValue) }
        if (EDI) { regionalDeparturesSupplements = regionalDeparturesSupplements.replacingOccurrences(of: "EDI", with: EDIValue) }
        if (GLA) { regionalDeparturesSupplements = regionalDeparturesSupplements.replacingOccurrences(of: "GLA", with: GLAValue) }
        if (STD) { regionalDeparturesSupplements = regionalDeparturesSupplements.replacingOccurrences(of: "STD", with: STDValue) }
        regionalDeparturesSupplements = regionalDeparturesSupplements.replacingOccurrences(of: ".00", with: "")
        regionalDeparturesSupplements = regionalDeparturesSupplements.replacingOccurrences(of: "from £0 extra", with: "from no extra cost")
        regionalDeparturesSupplements.removeLast(2)
        regionalDeparturesAirports.removeLast(2)
    }
    
    /**
     Sets the visa requirements for the tour.
     
     - Returns: void
     */
    func setupVisa() {
        if (tours[0][12] != "") {
            requiresVisa = tours[0][12]
        }
    }
    
    /**
     Gets the current dataset (or subset) in a preformatted string for the preview pane
     
     - Returns: **String** the dataset
     
     */
    func getPreviewOutput() -> String {
        var output = ""

        for element in setSoldOuts(tourData: rawdata) {
            output.append(element[0] + ", " + element[8] + " " + element[9] + " " + element[10] + ", Price: £" + element[2] +  ", Deposit: £" + element[3] + ", Single Supplement: £" + element[4] + "\n")
        }
        
        return output
    }
    
    /**
     scans the data to check if there is more than one year of tours in play //need to add code to store YEAR1 & YEAR2 values
     */
    func setDoubleYear() {
        var previousYear = ""
        if (tours.count > 0) { previousYear = tours[0][10]; yearOne = previousYear; }
        for var row in  tours {
            if (row[10] != previousYear) {
                doubleYearMode = true
                previousYear = row[10]
                yearTwo = previousYear
            }
        }
    }
    
    /**
     scans the data to check if there is more than one class of rail in play
     */
    func setStandardClassOption() {
        if (tours.count > 0) {
        for var row in  tours {
            switch (row[5]) {
            case "Standard":
                hasRailClass2 = true
                break;
            case "First":
                hasRailClass1 = true
                break;
            case "First & Standard":
                hasRailClass12 = true
                break;
            default:
                hasRailClass12 = true
                break;
            }
            }
        }
    }
    
    /**
     Scans the data array and sets any sold out prices to 'SOLD OUT'.
     
     - Parameter tourData: [[String]] the data array.
    
     - Returns: toursData: [[String]] the corrected data array.
     */
    func setSoldOuts(tourData: [[String]]) -> [[String]] {
        var toursData = tourData
        for i in 0 ... (toursData.count-1) {
            if (toursData[i][22] == toursData[i][21]) {
                toursData[i][2] = "SOLD OUT"
            }
        }
        return toursData
    }
    
    
    
    /**
     Cleans the data by removing neighboring elements that contain both the same month and price
     
     - Parameter dates: **[[String]]** the original dataset
     - Returns: **[[String]]** the clean dataset
     - TODO: Need to stop this from throwing a wobbley every time there is only one departure
     
     */
    func cleanTourDates (dates: [[String]]) -> [[String]] {
        tours = dates
        var previousPrice: String!
        var previousMonth: String!
        var indexesToRemove = [0]
        var cellLimit = 1

        if (tours.count > 0) {
            numOfDays = tours[0][6]
            tourTitle = tours[0][7]
            railClass = tours[0][5]
        } else {
            tours.append(["","","","","","","","","","","","","","","","","","","","",""])
        }
        
        var counter = 0
        var singleSupp = ""
        var deposTemp = ""
        
        for var row in tours {
            if (counter-1 >= 0) {
                if (row[9] == tours[counter-1][9]) { row[9] = "" }
                if (row[4] > tours[counter-1][4]) { if (row[4] != "0") { singleSupp = row[4] } }
                if (row[3] > tours[counter-1][3]) { if (row[3] != "0") { deposTemp = row[3] } }
            } else {
                if ( row[4] != "0" ) { singleSupp = row[4] }
                deposTemp = row[3]
            }
            counter += 1
        }
        
        counter = 0
        for var row in tours {
            if (counter-1 >= 0) {
                if (row[9] == tours[counter-1][9]) { row[9] = "" }
                if (row[4] < tours[counter-1][4]) { if (row[4] != "0") { singleSupp = row[4] } }
                if (row[3] < tours[counter-1][3]) { if (row[3] != "0") { deposTemp = row[3] } }
            } else {
                if ( row[4] != "0" ) { singleSupp = row[4] }
                deposTemp = row[3]
            }
            counter += 1
        }
        singleSupplement = singleSupp
        deposit = deposTemp
        
        
        for i in stride(from: (tours.count-1), to: 0, by: -1) {
            previousPrice = tours[i-1][2]
            previousMonth = tours[i-1][9]
            if (i-1 >= 0) {
                if (tours[i][9] == previousMonth) {
                    if (tours[i][2] == previousPrice) {
                        if(cellLimit < 2) {
                            indexesToRemove.append(i)
                            tours[i-1][8].append(", " + tours[i][8])
                            cellLimit += 1
                        } else {
                            cellLimit = 1
                        }
                    }
                }
            }
        }
        if (indexesToRemove.count > 0) {
            indexesToRemove.remove(at: 0)
            for index in indexesToRemove {
                tours.remove(at: index)
            }
        }
        return tours
    }
}
