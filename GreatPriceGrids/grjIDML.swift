//
//  grjIDML.swift
//  GreatPriceGrids
//
//  Created by Tim Colley on 20/07/2018.
//  Copyright © 2018 GreatRail. All rights reserved.
//

import Foundation


class grjIDML : NSObject {
    
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
    ///Value for the Class header
    var firstClassValue = ""
    
    /**
     Builds the central data grid based upon data passed to it. Depending upon the data contained and the options provided, it can provide a 2, 3 or 4 column grid with or without Fly:Home option, regional departures, tour titles, standard class rail options in a combination of one or two year layouts. in the case of a 3 column grid, only a 1 year layout applies. It automatially calculates the required number of columns dependent on the nomber of rows that are required. These are set as thresholds that once passed, signals the requirement for a larger grid, although these are overridden if the tour has two years or standard class departures. It returns a string containing IDML code and content to be effectivly 'sandwiched' between the contents of two 'include' files.
     
     -  parameter gridSize:            **Int**,         The size of the grid in columns. This is *not* specified in table columns, but rather in price grid columns. For table columns, multiply by 3.
     -  parameter doubleYear:          **Bool**,        Is this a double year grid?
     -  parameter removeTourTitle:     **Bool**,        Do we want the tour title removing?
     -  parameter latesBanner:         **Bool**,        Do we want to add a 'Lates' Banner?
     -  parameter regionalDepartures:  **Bool**,        Does this tour need regional departures boxes?
     -  parameter hasFlights:          **Bool**,        Does this tour have flights?
     -  parameter flyHome:             **Bool**,        Do we need a 'Fly:Home' box?
     -  parameter yearOne:             **String**,      The content for the first year header
     -  parameter yearTwo:             **String**,      The content for the second year header (if doubleYear id true)
     -  parameter Data:                **[[String]]**,  The dates & prices for the grid
     
     - Returns: **String**, The output data to be injected into the middle of the table.
     
     */
    
    // HasStandardClassDepartures:
    
    func buildIDMLGrid(gridSize: Int, doubleYear: Bool, removeTourTitle: Bool, LatesBanner: Bool, regionalDepartures: Bool, HasFlights: Bool, YearOne: String, YearTwo: String, HasStandardClassDepartures: Bool, FirstClassValue: String, hasFlyHome: Bool, Data: [[String]]) -> String {
        doubleYearMode = doubleYear
        discardTourTitle = removeTourTitle
        latesBanner = LatesBanner
        regDeps = regionalDepartures
        hasFlights = HasFlights
        flyHome = hasFlyHome
        yearOne = YearOne
        yearTwo = YearTwo
        hasStandardClassDepartures = HasStandardClassDepartures
        firstClassValue = FirstClassValue
        data = Data
        
        print(data.description)
        /// container for the IDML output to be added
        var output = ""
        /// Counter for tracking the table row currently being built
        var currentRow = 0
        addColumns(gridsize: gridSize)
        if (removeTourTitle == false)   { addTourTitle(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1 }
        if (latesBanner == true) { addLatesBanner(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1 }
        addDepartureLocationTourCode(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
        addDepartureYears(row: String(currentRow), colSpan: String(numberOfCOLS), doubleYear: doubleYear); currentRow += 1
        addRailClass(row: String(currentRow), colSpan: String(numberOfCOLS), doubleYear: doubleYear); currentRow += 1 //STANDARD CLASS CURRENTLY HERE
        
        if (gridSize == 4) {
            /// Column 1 of the grid
            var Col1 = [[String]]()
            /// Column 2 of the grid
            var Col2 = [[String]]()
            /// Column 3 of the grid
            var Col3 = [[String]]()
            /// Column 4 of the grid
            var Col4 = [[String]]()
            
            //Temp container to hold all year one departures in the case of a two year grid
            var year1 = [[String]]()
            //Temp container to hold all year two departures in the case of a two year grid
            var year2 = [[String]]()
            
            while (data.count % 4 != 0) {
                data.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "paper"])
            }
            
            if (doubleYear == true) {
                for element in data {
                    if (element[10] == yearOne) { year1.append(element) }
                    if (element[10] == yearTwo) { year2.append(element) }
                }
                if (hasStandardClassDepartures == true) {
                    for element in year1 {
                        if (element[5] == "First" || element[5] == "First & Standard") { Col1.append(element); print("Added Element to Col 1: \(element[5])") }
                        if (element[5] == "Standard") { Col2.append(element); print("Added Element to Col 2: \(element[5])") }
                    }
                    for element in year2 {
                        if (element[5] == "First" || element[5] == "First & Standard") { Col3.append(element); print("Added Element to Col 3: \(element[5])") }
                        if (element[5] == "Standard") { Col4.append(element); print("Added Element to Col 4: \(element[5])") }
                    }
                } else {
                    /// A counter
                    var i = 0
                    while (i <= (year1.count/2))     { Col1.append(year1[i]); i += 1;}
                    while (i <= year1.count-1)       { Col2.append(year1[i]); i += 1;}
                    i = 0
                    while (i <= (year2.count/2))     { Col3.append(year2[i]); i += 1;}
                    while (i <= year2.count-1)       { Col4.append(year2[i]); i += 1;}
                }
                
            } else {
                // A counter
                var i = 0
                while (i <= (data.count/4)-1)     { Col1.append(data[i]); i += 1;}
                while (i <= ((data.count/4)*2)-1) { Col2.append(data[i]); i += 1;}
                while (i <= ((data.count/4)*3)-1) { Col3.append(data[i]); i += 1;}
                while (i <= data.count-1)         { Col4.append(data[i]); i += 1;}
            }
            /// The highest number of elements in an array
            var highNumber: Int!
            highNumber = Col1.count
            if (Col2.count > highNumber) { highNumber = Col2.count }
            if (Col3.count > highNumber) { highNumber = Col3.count }
            if (Col4.count > highNumber) { highNumber = Col4.count }
            while (Col1.count != highNumber) { Col1.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "paper"]) }
            while (Col2.count != highNumber) { Col2.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "paper"]) }
            while (Col3.count != highNumber) { Col3.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "paper"]) }
            while (Col4.count != highNumber) { Col4.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "paper"]) }
            /// The bacckground colour for the cell
            var cellColor = "Gray"
            /// The last month to be used
            var prevMonth = Col1[0][9]
            for i in 0 ... (Col1.count-1) {
                if (Col1[i][9] == prevMonth || Col1[i][9] == "") {
                    Col1[i].append(cellColor);
                    prevMonth = Col1[i][9]
                    if (i > 0 ) {
                        Col1[i][9] = ""
                    }
                } else {
                    if (cellColor == "paper") { cellColor = "Gray" } else { cellColor = "paper" }
                    Col1[i].append(cellColor);
                    prevMonth = Col1[i][9]
                }
                
                if (Col1[i][23] == "") { Col1[i][23] = "paper"}
            }
            if (hasStandardClassDepartures == true) { cellColor = "Gray"; prevMonth = Col2[0][9]}
            if (Col2.count >= 1) {
                for i in 0 ... (Col2.count-1) {
                    if (Col2[i][9] == prevMonth || Col2[i][9] == "") {
                        Col2[i].append(cellColor);
                        prevMonth = Col2[i][9]
                        if (i > 0) {
                            Col2[i][9] = ""
                        }
                    } else {
                        if (cellColor == "paper") { cellColor = "Gray" } else { cellColor = "paper" }
                        Col2[i].append(cellColor);
                        prevMonth = Col2[i][9]
                    }
                    if (Col2[i][23] == "") { Col2[i][23] = "paper"}
                }
            }
            if (doubleYear == true || hasStandardClassDepartures == true) { cellColor = "Gray"; prevMonth = Col3[0][9] }
            if (Col3.count >= 1) {
                for i in 0 ... (Col3.count-1) {
                    if (Col3[i][9] == prevMonth || Col3[i][9] == "") {
                        Col3[i].append(cellColor);
                        prevMonth = Col3[i][9]
                        if (i > 0) {
                            Col3[i][9] = ""
                        }
                    } else {
                        if (cellColor == "paper") { cellColor = "Gray" } else { cellColor = "paper" }
                        Col3[i].append(cellColor);
                        prevMonth = Col3[i][9]
                    }
                    if (Col3[i][23] == "") { Col3[i][23] = "paper"}
                }
            }
            if (hasStandardClassDepartures == true) { cellColor = "Gray"; prevMonth = Col4[0][9]}
            if (Col4.count >= 1) {
                for i in 0 ... (Col4.count-1) {
                    if (Col4[i][9] == prevMonth || Col4[i][9] == "") {
                        Col4[i].append(cellColor);
                        prevMonth = Col4[i][9]
                        if (i > 0) {
                            Col4[i][9] = ""
                        }
                    } else {
                        if (cellColor == "paper") { cellColor = "Gray" } else { cellColor = "paper" }
                        Col4[i].append(cellColor);
                        prevMonth = Col4[i][9]
                    }
                    if (Col4[i][23] == "") { Col4[i][23] = "paper"}
                }
            }
            for i in 0 ... (Col1.count-1) {
                rowDefs.append(addRowDef(ownID: "", name: "\(String(currentRow))", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "11.338582677165356", minimumHeight: "11.338582677165356", autoGrow: " AutoGrow=\"false\" "))
                if (hasStandardClassDepartures == true) {
                    addDeparture(row: String(currentRow), leftStrokeColor: "Black", colStart: 0, monthValue: Col1[i][9], dayValue: Col1[i][8], priceValue: Col1[i][2], cellColor: Col1[i][23])
                } else {
                    addDeparture(row: String(currentRow), leftStrokeColor: "White", colStart: 0, monthValue: Col1[i][9], dayValue: Col1[i][8], priceValue: Col1[i][2], cellColor: Col1[i][23])
                }
                if (doubleYear == true || hasStandardClassDepartures == true) {
                    addDeparture(row: String(currentRow), leftStrokeColor: "Black", colStart: 3, monthValue: Col2[i][9], dayValue: Col2[i][8], priceValue: Col2[i][2], cellColor: Col2[i][23])
                } else {
                    addDeparture(row: String(currentRow), leftStrokeColor: "White", colStart: 3, monthValue: Col2[i][9], dayValue: Col2[i][8], priceValue: Col2[i][2], cellColor: Col2[i][23])
                }
                if (hasStandardClassDepartures == true) {
                    addDeparture(row: String(currentRow), leftStrokeColor: "Black", colStart: 6, monthValue: Col3[i][9], dayValue: Col3[i][8], priceValue: Col3[i][2], cellColor: Col3[i][23])
                } else {
                    addDeparture(row: String(currentRow), leftStrokeColor: "White", colStart: 6, monthValue: Col3[i][9], dayValue: Col3[i][8], priceValue: Col3[i][2], cellColor: Col3[i][23])
                }
                addDeparture(row: String(currentRow), leftStrokeColor: "Regular", colStart: 9, monthValue: Col4[i][9], dayValue: Col4[i][8], priceValue: Col4[i][2], cellColor: Col4[i][23])
                currentRow += 1
            }
        }
        
        if (gridSize == 3) {
            var Col1 = [[String]]()
            var Col2 = [[String]]()
            var Col3 = [[String]]()
            var i = 0
            
            while (data.count % 3 != 0) {
                data.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "paper"])
            }
            while (i <= (((data.count)/3)-1)) { Col1.append(data[i]); i += 1;}
            while (i <= (((data.count)/3)*2)-1) { Col2.append(data[i]); i += 1;}
            while (i <= data.count-1) { Col3.append(data[i]); i += 1;}
            var highNumber: Int!
            highNumber = Col1.count
            if (Col2.count > highNumber) { highNumber = Col2.count }
            if (Col3.count > highNumber) { highNumber = Col3.count }
            while (Col1.count != highNumber) { Col1.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "paper"]) }
            while (Col2.count != highNumber) { Col2.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "paper"]) }
            while (Col3.count != highNumber) { Col3.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "paper"]) }
            var cellColor = "Gray"
            var prevMonth = Col1[0][9]
            
            for i in 0 ... (Col1.count-1) {
                if (Col1[i][9] == prevMonth || Col1[i][9] == "") {
                    Col1[i].append(cellColor);
                    prevMonth = Col1[i][9]
                    if (i > 0 ) {
                        Col1[i][9] = ""
                    }
                } else {
                    if (cellColor == "paper") { cellColor = "Gray" } else { cellColor = "paper" }
                    Col1[i].append(cellColor);
                    prevMonth = Col1[i][9]
                }
                
                if (Col1[i][23] == "") { Col1[i][23] = "paper"}
            }
            if (Col3.count >= 1) {
                for i in 0 ... (Col2.count-1) {
                    if (Col2[i][9] == prevMonth || Col2[i][9] == "") {
                        Col2[i].append(cellColor);
                        prevMonth = Col2[i][9]
                        if (i > 0) {
                            Col2[i][9] = ""
                        }
                    } else {
                        if (cellColor == "paper") { cellColor = "Gray" } else { cellColor = "paper" }
                        Col2[i].append(cellColor);
                        prevMonth = Col2[i][9]
                    }
                    if (Col2[i][23] == "") { Col2[i][23] = "paper"}
                }
            }
            if (Col3.count >= 1) {
                for i in 0 ... (Col3.count-1) {
                    if (Col3[i][9] == prevMonth || Col3[i][9] == "") {
                        Col3[i].append(cellColor);
                        prevMonth = Col3[i][9]
                        if (i > 0) {
                            Col3[i][9] = ""
                        }
                    } else {
                        if (cellColor == "paper") { cellColor = "Gray" } else { cellColor = "paper" }
                        Col3[i].append(cellColor);
                        prevMonth = Col3[i][9]
                    }
                    if (Col3[i][23] == "") { Col3[i][23] = "paper"}
                }
            }
            for i in 0 ... (Col1.count-1) {
                rowDefs.append(addRowDef(ownID: "", name: "\(String(currentRow))", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "11.338582677165356", minimumHeight: "11.338582677165356", autoGrow: " AutoGrow=\"false\" "))
                addDeparture(row: String(currentRow), leftStrokeColor: "White", colStart: 0, monthValue: Col1[i][9], dayValue: Col1[i][8], priceValue: Col1[i][2], cellColor: Col1[i][23])
                addDeparture(row: String(currentRow), leftStrokeColor: "White", colStart: 3, monthValue: Col2[i][9], dayValue: Col2[i][8], priceValue: Col2[i][2], cellColor: Col2[i][23])
                addDeparture(row: String(currentRow), leftStrokeColor: "Regular", colStart: 6, monthValue: Col3[i][9], dayValue: Col3[i][8], priceValue: Col3[i][2], cellColor: Col3[i][23])
                currentRow += 1
            }
        }
        
        if (gridSize == 2) {
            var Col1 = [[String]]()
            var Col2 = [[String]]()
            if (doubleYear == true) {
                for element in data {
                    if (element[10] == yearOne) { Col1.append(element) }
                    if (element[10] == yearTwo) { Col2.append(element) }
                }
            } else {
                if (hasStandardClassDepartures == true) {
                    for element in data {
                        if (element[5] == "First" || element[5] == "First & Standard") { Col1.append(element) }
                        if (element[5] == "Standard") { Col2.append(element) }
                    }
                } else {
                    if (data.count == 1) {
                        Col1.append(data[0])
                        Col2.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""])
                    } else {
                        var i = 0
                        while (i <= (data.count/2)-1)     { Col1.append(data[i]); i += 1;}
                        while (i <= data.count-1)         { Col2.append(data[i]); i += 1;}
                    }
                }
            }
            if (Col1.count < Col2.count ) { while (Col1.count != Col2.count) { Col1.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) } }
            if (Col2.count < Col1.count ) { while (Col2.count != Col1.count) { Col2.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) } }
            var cellColor = "Gray"
            var prevMonth = Col1[0][9]
            
            for i in 0 ... (Col1.count-1) {
                if (Col1[i][9] == prevMonth || Col1[i][9] == "") {
                    Col1[i].append(cellColor);
                    prevMonth = Col1[i][9]
                    if (i > 0 ) {
                        Col1[i][9] = ""
                    }
                } else {
                    if (cellColor == "paper") { cellColor = "Gray" } else { cellColor = "paper" }
                    Col1[i].append(cellColor);
                    prevMonth = Col1[i][9]
                }
                if (Col1[i][23] == "") { Col1[i][23] = "paper"}
            }
            
            if (doubleYear == true || hasStandardClassDepartures == true) { cellColor = "Gray"; prevMonth = Col2[0][9] }
            
            for i in 0 ... (Col2.count-1) {
                if (Col2[i][9] == prevMonth || Col2[i][9] == "") {
                    Col2[i].append(cellColor);
                    prevMonth = Col2[i][9]
                    if (i > 0) {
                        Col2[i][9] = ""
                    }
                } else {
                    if (cellColor == "paper") { cellColor = "Gray" } else { cellColor = "paper" }
                    Col2[i].append(cellColor);
                    prevMonth = Col2[i][9]
                }
                if (Col2[i][23] == "") { Col2[i][23] = "paper"}
            }
            
            for i in 0 ... (Col1.count-1) {
                rowDefs.append(addRowDef(ownID: "", name: "\(String(currentRow))", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "11.338582677165356", minimumHeight: "11.338582677165356", autoGrow: " AutoGrow=\"false\" "))
                if (doubleYear == true || hasStandardClassDepartures == true) {
                    addDeparture(row: String(currentRow), leftStrokeColor: "Black", colStart: 0, monthValue: Col1[i][9], dayValue: Col1[i][8], priceValue: Col1[i][2], cellColor: Col1[i][23])
                } else {
                    addDeparture(row: String(currentRow), leftStrokeColor: "White", colStart: 0, monthValue: Col1[i][9], dayValue: Col1[i][8], priceValue: Col1[i][2], cellColor: Col1[i][23])
                }
                addDeparture(row: String(currentRow), leftStrokeColor: "Regular", colStart: 3, monthValue: Col2[i][9], dayValue: Col2[i][8], priceValue: Col2[i][2], cellColor: Col2[i][23])
                currentRow += 1
            }
        }
        
        if (flyHome == true ) { addFlyHomeOption(row: String(currentRow), colSpan: String(numberOfCOLS), doubleYear: doubleYear); currentRow += 1 }
        if (regionalDepartures == true) {
            addSpacer(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
            addRegionalDepartureLocations(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
            addRegionalDeparturePrices(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
        }
        addSpacer(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
        if (NSS == true) {
            addDepositArea(row: String(currentRow), colSpan: String(numberOfCOLS), content: "£ per person based on 2 sharing. Deposit $DEPOSIT$ per person.\rNo single supplement on selected departures - please call for details.\rThis tour may be suitable for reduced mobility passengers, please call for further information.");
        } else {
            addDepositArea(row: String(currentRow), colSpan: String(numberOfCOLS), content: "£ per person based on 2 sharing. Deposit $DEPOSIT$ per person.\rSupplement for single occupancy throughout from $SINGLE_SUPPLEMENT$\rThis tour may be suitable for reduced mobility passengers, please call for further information.");
        }
        currentRow += 1
        addSmallPrint(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
        output.append(addTableDef(rows: "\(String(currentRow))", cols: "\(gridSize*3)"))
        output.append(rowDefs)
        output.append(colDefs)
        output.append(cellDefs)
        output.append(endTable())
        return output
    }
    
    
    /**
     Builds the Column definitions for the IDML output according to the required grid size. The width of the columns are statically assgned as IDML parameters to ensure that the table output is always 94mm wide on page.
     
     
     -  parameter gridSize: **Int**, The size of the grid in columns. This is *not* specified in table columns, but rather in price grid columns. For table columns, multiply by 3.
     
     - Returns: **String**, The column definitions.
     
     */
    func addColumns(gridsize: Int) {
        var colTrack = 0
        switch (gridsize) {
        case 2 :
            for _ in 0 ..< gridsize {
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleColumnWidth: "28.34645669291339")); colTrack += 1;
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleColumnWidth: "25.511811023622048")); colTrack += 1;
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleColumnWidth: "79.370078736197474")); colTrack += 1;
                numberOfCOLS = 6
            }
            break;
        case 3:
            for _ in 0 ..< gridsize {
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleColumnWidth: "31.181102362218496")); colTrack += 1;
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleColumnWidth: "22.66716535433071")); colTrack += 1;
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleColumnWidth: "34.01574803149607")); colTrack += 1;
                numberOfCOLS = 9
            }
            break;
        case 4:
            for _ in 0 ..< gridsize {
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleColumnWidth: "19.84251968305937")); colTrack += 1;
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleColumnWidth: "11.338582677165356")); colTrack += 1;
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleColumnWidth: "35.43307086614173")); colTrack += 1;
                numberOfCOLS = 12
            }
            break;
        default:
            break;
        }
    }
    
    /**
     builds and returns the IDML required for the tour title element of the table
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, The tour title element of the table.
     
     */
    func addTourTitle(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "0", textTopInset: "0", textLeftInset: "0", textBottomInset: "8.503937007874017", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "22.67716535433071", minimumHeight: "22.67716535433071", autoGrow: "" ))
        cellDefs.append(addCell(  ownID: "", name: "0:0", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "0", textBottomInset: "8.503937007874017", textRightInset: "0", appliedCellStyle: "CellStyle/CellTourTitle", appliedParagraphStyle: "ParagraphStyle/Table Tour Title", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "$TOUR_TITLE$" ))
    }
    
    /**
     builds and returns the IDML required for the 'Lates Banner' element of the table
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, The tour 'Lates Banner' of the table.
     
     */
    func addLatesBanner(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "22.67716535433071", minimumHeight: "22.67716535433071", autoGrow: "" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/CellLateDepartures", appliedParagraphStyle: "ParagraphStyle/Lates Banner", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "Last few  spaces remaining -\nbook now to secure your place" ))
    }
    
    /**
     builds and returns the IDML required for the departure location element of the table, this element will also house the tour code and the visa information.
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, The departure location element of the table.
     
     */
    func addDepartureLocationTourCode(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "5.669291338582678", textLeftInset: "0", textBottomInset: "5.669291338582678", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "19.84251968503937", minimumHeight: "19.84251968503937", autoGrow: "" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "5.669291338582678", textLeftInset:  "0", textBottomInset: "5.669291338582678", textRightInset: "0", appliedCellStyle: "CellStyle/CellDurationTourCode", appliedParagraphStyle: "ParagraphStyle/Table Duration &amp; Tour Code",
                                  appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "$DURATION$ days from $DEPARTURE_LOCATION$ - Tour Code: $TOUR_CODE$" ))
    }
    
    /**
     builds and returns the IDML required for the tour departure years header element of the table
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     -  parameter doubleYear           **Bool**,        Is there a requirement to mearge the 1st half and 2nd half of the this row and allow for multiple years?, if false, then mearge across the entire row.
     
     - Returns: **String**, The departure years header element of the table.
     
     */
    func addDepartureYears(row: String, colSpan: String, doubleYear: Bool) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "22.67716535433071", minimumHeight: "22.67716535433071", autoGrow: "" ))
        if (doubleYear == true) {
            cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(String(Int(Double(colSpan)! / 2)))", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/CellYearWithStroke", appliedParagraphStyle: "ParagraphStyle/Table Year", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "\(yearOne) Departures" ))
            cellDefs.append(addCell(  ownID: "", name: "\(String(Int(Double(colSpan)! / 2))):\(row)", rowSpan: "1", colSpan:  "\(String(Int(Double(colSpan)! / 2)))", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/CellYearNoStroke", appliedParagraphStyle: "ParagraphStyle/Table Year", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "\(yearTwo) Departures" ))
        } else {
            cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/CellYearNoStroke", appliedParagraphStyle: "ParagraphStyle/Table Year", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "\(yearOne) Departures" ))
        }
    }
    
    /**
     builds and returns the IDML required for the tour rail class header element of the table
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     -  parameter doubleYear           **Bool**,        Is there a requirement to mearge the 1st half and 2nd half of the this row and allow for multiple years?, if false, then mearge across the entire row.
     
     - Returns: **String**, The tour rail class header element of the table.
     
     */
    func addRailClass(row: String, colSpan: String, doubleYear: Bool) {
        var charStyle = "$ID/[No character style]"
        var content = "$RAIL_CLASS$"
        if (newRailClass == "With Economy Class Flights") { charStyle = "With Economy Class Flights" }
        if (hasFlights == true) { content = "$RAIL_CLASS$</Content>\n</CharacterStyleRange>\n</ParagraphStyleRange>\n<Br />\n<ParagraphStyleRange AppliedParagraphStyle=\"ParagraphStyle/Table Class\">\n<CharacterStyleRange AppliedCharacterStyle=\"CharacterStyle/With Economy Class Flights\">\n<Content>With Economy Class Flights" }
        if (newRailClass == "") { content = "</Content>\n</CharacterStyleRange>\n</ParagraphStyleRange><ParagraphStyleRange AppliedParagraphStyle=\"ParagraphStyle/Table Class\">\n<CharacterStyleRange AppliedCharacterStyle=\"CharacterStyle/With Economy Class Flights\">\n<Content>With Economy Class Flights" }
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "22.67716535433071", minimumHeight: "22.67716535433071", autoGrow: "" ))
        if (doubleYear == true) {
            if (hasStandardClassDepartures == true) {
                cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan: "\(String(Int(Double(colSpan)! / 4)))", cellType: "TextTypeCell", textTopInset: "", textLeftInset:  "", textBottomInset: "", textRightInset: "", appliedCellStyle: "CellStyle/CellRailClassWithStroke", appliedParagraphStyle: "ParagraphStyle/Table Class", appliedCharacterStyle: "CharacterStyle/\(charStyle)", content: content ))
                cellDefs.append(addCell(  ownID: "", name: "3:\(row)", rowSpan: "1", colSpan: "\(String(Int(Double(colSpan)! / 4)))", cellType: "TextTypeCell", textTopInset: "", textLeftInset:  "", textBottomInset: "", textRightInset: "", appliedCellStyle: "CellStyle/CellRailClassWithStroke", appliedParagraphStyle: "ParagraphStyle/Table Class", appliedCharacterStyle: "CharacterStyle/\(charStyle)", content: "Standard\nClass Rail" ))
                cellDefs.append(addCell( ownID: "", name: "6:\(row)", rowSpan: "1", colSpan: "\(String(Int(Double(colSpan)! / 4)))", cellType: "TextTypeCell", textTopInset: "", textLeftInset:  "", textBottomInset: "", textRightInset: "", appliedCellStyle: "CellStyle/CellRailClassWithStroke", appliedParagraphStyle: "ParagraphStyle/Table Class", appliedCharacterStyle: "CharacterStyle/\(charStyle)", content: content ))
                cellDefs.append(addCell( ownID: "", name: "9:\(row)", rowSpan: "1", colSpan: "\(String(Int(Double(colSpan)! / 4)))", cellType: "TextTypeCell", textTopInset: "", textLeftInset:  "", textBottomInset: "", textRightInset: "", appliedCellStyle: "CellStyle/CellRailClassNoStroke", appliedParagraphStyle: "ParagraphStyle/Table Class", appliedCharacterStyle: "CharacterStyle/\(charStyle)", content: "Standard\nClass Rail" ))
            } else {
                cellDefs.append(addCell( ownID: "", name: "0:\(row)", rowSpan: "1", colSpan: "\(String(Int(Double(colSpan)! / 2)))", cellType: "TextTypeCell", textTopInset: "", textLeftInset:  "", textBottomInset: "", textRightInset: "", appliedCellStyle: "CellStyle/CellRailClassWithStroke", appliedParagraphStyle: "ParagraphStyle/Table Class", appliedCharacterStyle: "CharacterStyle/\(charStyle)", content: content ))
                cellDefs.append(addCell( ownID: "", name: "\(String(Int(Double(colSpan)! / 2))):\(row)", rowSpan: "1", colSpan:  "\(String(Int(Double(colSpan)! / 2)))", cellType: "TextTypeCell", textTopInset: "", textLeftInset:  "", textBottomInset: "", textRightInset: "", appliedCellStyle: "CellStyle/CellRailClassNoStroke", appliedParagraphStyle: "ParagraphStyle/Table Class", appliedCharacterStyle: "CharacterStyle/\(charStyle)", content: content ))
            }
        } else {
            if (hasStandardClassDepartures == true) {
                cellDefs.append(addCell( ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(String(Int(Double(colSpan)! / 2)))", cellType: "TextTypeCell", textTopInset: "", textLeftInset:  "", textBottomInset: "", textRightInset: "", appliedCellStyle: "CellStyle/CellRailClassWithStroke", appliedParagraphStyle: "ParagraphStyle/Table Class", appliedCharacterStyle: "CharacterStyle/\(charStyle)", content: content ))
                cellDefs.append(addCell( ownID: "", name: "3:\(row)", rowSpan: "1", colSpan: "3", cellType: "TextTypeCell", textTopInset: "", textLeftInset:  "", textBottomInset: "", textRightInset: "", appliedCellStyle: "CellStyle/CellRailClassNoStroke", appliedParagraphStyle: "ParagraphStyle/Table Class", appliedCharacterStyle: "CharacterStyle/\(charStyle)", content: "Standard Class Rail" ))
            } else {
                cellDefs.append(addCell( ownID: "", name: "0:\(row)", rowSpan: "1", colSpan: "\(String(colSpan))", cellType: "TextTypeCell", textTopInset: "", textLeftInset:  "", textBottomInset: "", textRightInset: "", appliedCellStyle: "CellStyle/CellRailClassNoStroke", appliedParagraphStyle: "ParagraphStyle/Table Class", appliedCharacterStyle: "CharacterStyle/\(charStyle)", content: content ))
            }
        }
    }
    
    
    /**
     builds and returns the IDML required for one departure. This function allows specification for various options such as stroke and fill colours. it retuns a configured block of three cells.
     
     -  parameter row:             **String**, The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter leftStrokeColor: **String**, The left hand stroke colour of the last cell in the block, can be White for inside a single year, Black for seperating years or Regular for the last stroke in the row.
     -  parameter colStart:        **Int**,    The starting column for the block. Since we are not generating the entire row, we need to know where to start these cells off from.
     -  parameter monthValue:      **String**, The value of the Month field in the block.
     -  parameter dayValue:        **String**, The value of the day(s) field in the block.
     -  parameter priceValue:      **String**, The value of the price field in the block.
     -  parameter cellColor:       **String**, The fill colour of the block.
     
     - Returns: **String**, The departure: a block of three cells to append to the grid.
     
     */
    func addDeparture(row: String, leftStrokeColor: String, colStart: Int, monthValue: String, dayValue: String, priceValue: String, cellColor: String) {
        var pricevalue = priceValue
        var monthCellColor: String!
        var dayCellColor: String!
        var priceCellColor: String!
        var soldout: String!
        
        if (priceValue.count == 4) { pricevalue = priceValue; pricevalue.insert(",", at: pricevalue.index(pricevalue.startIndex, offsetBy: 1)) }
        if (priceValue.count == 5) { pricevalue = priceValue; pricevalue.insert(",", at: pricevalue.index(pricevalue.startIndex, offsetBy: 2)) }
        if (priceValue == "" || priceValue == "SOLD OUT") { } else { pricevalue = "£" + pricevalue }
        if (cellColor == "paper") {
            monthCellColor = "CellMonthRegular"
            dayCellColor = "CellDayRegular"
            priceCellColor  = "CellPriceRegular"
        } else {
            monthCellColor = "CellMonthHighlight"
            dayCellColor = "CellDayHighlight"
            priceCellColor  = "CellPriceHighlight"
        }
        if (priceValue == "SOLD OUT") { soldout = "CharacterStyle/SOLD OUT" } else { soldout = "CharacterStyle/$ID/[No character style]" }
        
        cellDefs.append(addCell(  ownID: "", name: "\(colStart):\(row)", rowSpan: "1", colSpan:  "1", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "4.251968503937009", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/\(monthCellColor!)", appliedParagraphStyle: "ParagraphStyle/Table Month", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: monthValue))
        cellDefs.append(addCell(  ownID: "", name: "\(colStart + 1):\(row)", rowSpan: "1", colSpan:  "1", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/\(dayCellColor!)", appliedParagraphStyle: "ParagraphStyle/Table Day", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: dayValue))
        
        if (leftStrokeColor == "Black") {
            cellDefs.append(addCell(  ownID: "", name: "\(colStart+2):\(row)", rowSpan: "1", colSpan:  "1", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/\(priceCellColor!)Black", appliedParagraphStyle: "ParagraphStyle/Table Price", appliedCharacterStyle: soldout, content: pricevalue))
        }
        if (leftStrokeColor == "White") {
            cellDefs.append(addCell(  ownID: "", name: "\(colStart+2):\(row)", rowSpan: "1", colSpan:  "1", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/\(priceCellColor!)White", appliedParagraphStyle: "ParagraphStyle/Table Price", appliedCharacterStyle: soldout, content: pricevalue))
        }
        if (leftStrokeColor == "Regular") {
            cellDefs.append(addCell(  ownID: "", name: "\(colStart+2):\(row)", rowSpan: "1", colSpan:  "1", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/\(priceCellColor!)", appliedParagraphStyle: "ParagraphStyle/Table Price", appliedCharacterStyle: soldout, content: pricevalue))
        }
    }
    
    
    /**
     builds and returns the IDML required for fly:home option cells
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     -  parameter doubleYear           **Bool**,        Is there a requirement to mearge the 1st half and 2nd half of the this row and allow for multiple years?, if false, then mearge across the entire row.
     
     - Returns: **String**, The fly:home option element of the table.
     
     */
    func addFlyHomeOption(row: String, colSpan: String, doubleYear: Bool) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "2.834645669291339", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "22.67716535433071", minimumHeight: "22.67716535433071", autoGrow: "" ))
        if (doubleYear == true) {
            cellDefs.append(addCell( ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(String(Int(Double(colSpan)! / 2)))", cellType: "TextTypeCell", textTopInset: "2.834645669291339", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/CellFlyHomeOptionBlackStroke", appliedParagraphStyle: "ParagraphStyle/Flyhome",
                                     appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "FLY HOME OPTION AVAILABLE FROM £0,005</Content>\n</CharacterStyleRange>\n</ParagraphStyleRange>\n<Br />\n<ParagraphStyleRange AppliedParagraphStyle=\"ParagraphStyle/Table Class\">\n<CharacterStyleRange AppliedCharacterStyle=\"CharacterStyle/With Economy Class Flights\">\n<Content>From Xxxxx Airport to London Xxxxxx" ))
            cellDefs.append(addCell( ownID: "", name: "\(String(Int(Double(colSpan)! / 2))):\(row)", rowSpan: "1", colSpan:  "\(String(Int(Double(colSpan)! / 2)))", cellType: "TextTypeCell", textTopInset: "2.834645669291339", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/CellFlyHomeOptionNoStroke", appliedParagraphStyle: "ParagraphStyle/Flyhome", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "FLY HOME OPTION AVAILABLE FROM £0,005</Content>\n</CharacterStyleRange>\n</ParagraphStyleRange>\n<Br />\n<ParagraphStyleRange AppliedParagraphStyle=\"ParagraphStyle/Table Class\">\n<CharacterStyleRange AppliedCharacterStyle=\"CharacterStyle/With Economy Class Flights\">\n<Content>From Xxxxx Airport to London Xxxxxx" ))
        }
        else {
            cellDefs.append(addCell( ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "2.834645669291339", textLeftInset:  "0", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/CellFlyHomeOptionNoStroke", appliedParagraphStyle: "ParagraphStyle/Flyhome",                 appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "FLY HOME OPTION AVAILABLE FROM £0,005</Content>\n</CharacterStyleRange>\n</ParagraphStyleRange>\n<Br />\n<ParagraphStyleRange AppliedParagraphStyle=\"ParagraphStyle/Table Class\">\n<CharacterStyleRange AppliedCharacterStyle=\"CharacterStyle/With Economy Class Flights\">\n<Content>From Xxxxx Airport to London Xxxxxx" ))
        }
    }
    
    /**
     builds and returns the IDML required for regional departures locations option row
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, The regional departures locations element of the table.
     
     */
    func addRegionalDepartureLocations(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "4.251968503937008", textLeftInset: "0", textBottomInset: "4.251968503937008", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "14.173228346456694", minimumHeight: "14.173228346456694", autoGrow: "" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "4.251968503937008", textLeftInset:  "0", textBottomInset: "4.251968503937008", textRightInset: "0", appliedCellStyle: "CellStyle/CellRegionalDeparturesLocations", appliedParagraphStyle: "ParagraphStyle/Table Regional Departures", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "$REGIONAL_DEPARTURE_LIST$" ))
    }
    
    /**
     builds and returns the IDML required for regional departures option supplement prices row
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, The regional departures supplement prices element of the table.
     
     */
    func addRegionalDeparturePrices(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "4.251968503937008", textLeftInset: "0", textBottomInset: "4.251968503937008", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "22.67716535433071", minimumHeight: "22.67716535433071", autoGrow: "" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "4.251968503937008", textLeftInset:  "0", textBottomInset: "4.251968503937008", textRightInset: "0", appliedCellStyle: "CellStyle/CellRegionalDeparturesPrices", appliedParagraphStyle: "ParagraphStyle/Table Regional Departures",
                                  appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "$REGIONAL_DEPARTURE_PRICES$" ))
    }
    
    /**
     builds and returns the IDML required for a spacer row, this type of row will alway be spanned across all columns and be exactly 1.035mm high
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, A spacer element for the table.
     
     */
    func addSpacer(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "2.9990551181102365", minimumHeight: "2.9990551181102365", autoGrow: "AutoGrow=\"false\"" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "2.834645669291339", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/CellSpacer", appliedParagraphStyle: "ParagraphStyle/$ID/NormalParagraphStyle", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "" ))
    }
    
    /**
     builds and returns the IDML required for the deposit area. this will contain the single supplement and the deposit as well as other supplementory information
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     -  parameter content:             **String**,      The content for the deposit area.
     
     - Returns: **String**, A spacer element for the table.
     
     */
    func addDepositArea(row: String, colSpan: String, content: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "4.251968503937008", textLeftInset: "0", textBottomInset: "4.251968503937008", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "19.787872554749015", minimumHeight: "17.007874015748033", autoGrow: "" ))
        
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "4.251968503937008", textLeftInset:  "0", textBottomInset: "4.251968503937008", textRightInset: "0", appliedCellStyle: "CellStyle/CellDepositArea", appliedParagraphStyle: "ParagraphStyle/Table Deposit Area", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: content ))
    }
    
    
    /**
     builds and returns the IDML required for the small print element of the table
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, the small print element for the table.
     
     */
    func addSmallPrint(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "5.669291338582678", textLeftInset: "4.251968503937009", textBottomInset: "0", textRightInset: "4.251968503937009", clipContentToTextCell: "false", singleRowHeight: "28.34645669291339", minimumHeight: "28.34645669291339", autoGrow: "" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "5.669291338582678", textLeftInset:  "2.834645669291339", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/CellSmallPrint", appliedParagraphStyle: "ParagraphStyle/Table Small Print", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "$SMALLPRINT$" ))
    }
    
    /**
     builds and returns the IDML required for the table definition. This specifies all options in IDML for the table including columns & rows
     
     -  parameter rows:              **String**,         The number of rows required by the table
     -  parameter cols:              **String**,         The number of columns required by the table
     
     - Returns: **String**, the table definition.
     
     */
    func addTableDef(rows: String, cols: String) -> String {
        let output = "<Table Self=\"u12ei217\" HeaderRowCount=\"0\" FooterRowCount=\"0\" TextTopInset=\"4\" TextLeftInset=\"4\" TextBottomInset=\"4\" TextRightInset=\"4\" ClipContentToTextCell=\"false\" BodyRowCount=\"\(rows)\" ColumnCount=\"\(cols)\" AppliedTableStyle=\"TableStyle/$ID/[No table style]\" TableDirection=\"LeftToRightDirection\">\n"
        return output
    }
    
    /**
     builds and returns the IDML required for a row definition. IDML requires that the row definitions are listed *before* the cell definitions, unlike HTML where cell definition is implicit. This means that row definitions, although created dynamically, are stored in a seperate holding variable at the top level of the class, then added to the output *before* the cell definitions
     
     -  parameter ownID:                 **String**,    Not used, should be *""*
     -  parameter name:                  **String**,    Used for the row number, provided by a counter that keeps track of the progress through the table in the parant function
     -  parameter textTopInset:          **String**,    The top side cell padding for the cells in the row
     -  parameter textLeftInset:         **String**,    The left side cell padding for cells in the row
     -  parameter textBottomInset:       **String**,    The bottom cell padding for cells in the row
     -  parameter textRightInset:        **String**,    The right side cell padding for cells in the row
     -  parameter clipContentToTextCell: **String**,    The clipping mode, if set to *'true'* then this will block overflow errors in preflight
     -  parameter singleRowHeight:       **String**,    The default height of the row. This is not calculated in mm, specified as a *String(Double)*
     -  parameter minimumHeight:         **String**,    The minimum height that the cell should be.
     -  parameter autoGrow:              **String**,    The autogrow function lets a cell expand for additional content. if setting to true, use *'autogrow="true"'* not *'true'* as the IDML tag isn't be included in the default output.
     
     - Returns: **String**, the row definition.
     
     */
    func addRowDef(ownID: String, name: String, textTopInset: String, textLeftInset: String, textBottomInset: String, textRightInset: String, clipContentToTextCell: String, singleRowHeight: String, minimumHeight: String, autoGrow: String) -> String {
        let output = "<Row Self=\"\(ownID)\" Name=\"\(name)\" TextTopInset=\"\(textTopInset)\" TextLeftInset=\"\(textLeftInset)\" TextBottomInset=\"\(textBottomInset)\" TextRightInset=\"\(textRightInset)\" ClipContentToTextCell=\"\(clipContentToTextCell)\" SingleRowHeight=\"\(singleRowHeight)\" MinimumHeight=\"\(minimumHeight)\" \(autoGrow)/>\n"
        return output
    }
    
    /**
     builds and returns the IDML required for column definition.
     
     -  parameter ownID:                 **String**,    Not used, should be *""*
     -  parameter name:                  **String**,    Used for the column number
     -  parameter textTopInset:          **String**,    The top side cell padding for the cells in the column
     -  parameter textLeftInset:         **String**,    The left side cell padding for cells in the column
     -  parameter textBottomInset:       **String**,    The bottom cell padding for cells in the column
     -  parameter textRightInset:        **String**,    The right side cell padding for cells in the column
     -  parameter clipContentToTextCell: **String**,    The clipping mode, if set to *'true'* then this will block overflow errors in preflight
     -  parameter singleColumnWidth:     **String**,    The width of the column, Explicitly set depending on the numbers of columns required and the content housed in them
     
     - Returns: **String**, the column definition.
     
     */
    func addColDef(ownID: String, name: String, textTopInset: String, textLeftInset: String, textBottomInset: String, textRightInset: String, clipContentToTextCell: String, singleColumnWidth: String) -> String {
        let output = "<Column Self=\"\(ownID)\" Name=\"\(name)\" TextTopInset=\"\(textTopInset)\" TextLeftInset=\"\(textLeftInset)\" TextBottomInset=\"\(textBottomInset)\" TextRightInset=\"\(textRightInset)\" ClipContentToTextCell=\"\(clipContentToTextCell)\" SingleColumnWidth=\"\(singleColumnWidth)\" />\n"
        
        return output
    }
    
    /**
     builds and returns the IDML required for column definition.
     
     - Returns: **String**, a simple string to close out the table build in IDML
     
     */
    func endTable() -> String {
        return "</Table>\n"
    }
    
    
    /**
     builds and returns the IDML required for cell definition.
     
     -  parameter ownID:                 **String**,    Not used, should be *""*
     -  parameter name:                  **String**,    Used for the column number and the row number, relates the cell to them by (col):(row), eg 1:1, 2:1, 3:1 etc.
     -  parameter rowSpan:               **String**,    How many cells to merge down or up
     -  parameter colSpan:               **String**,    How many cells to merge across
     -  parameter cellType:              **String**,    The cell type, text, image, interactive etc.
     -  parameter textTopInset:          **String**,    The top side cell padding for the cells in the column
     -  parameter textLeftInset:         **String**,    The left side cell padding for cells in the column
     -  parameter textBottomInset:       **String**,    The bottom cell padding for cells in the column
     -  parameter textRightInset:        **String**,    The right side cell padding for cells in the column
     -  parameter appliedCellStyle:      **String**,    The cell style to be used with this cell. Price, Day, Month, Class, TourTitle etc...
     -  parameter appliedParagraphStyle: **String**,    The paragraph style to be applied, if "" then it's usually inherited from the cell style anyway
     -  parameter appliedCharacterStyle: **String**,    The character style to use. this should *always* be "" as any style here will override the paragraph and cell styles
     -  parameter content:               **String**,    The content to be housed in teh cell.
     
     - Returns: **String**, the column definition.
     
     */
    func addCell( ownID: String, name: String, rowSpan: String, colSpan: String, cellType: String, textTopInset: String, textLeftInset: String, textBottomInset: String, textRightInset: String, appliedCellStyle: String, appliedParagraphStyle: String, appliedCharacterStyle: String, content: String ) -> String {
        var output = "<Cell Self=\"\(ownID)\" Name=\"\(name)\" "
        if (rowSpan != "")                  { output.append("RowSpan=\"\(rowSpan)\" ") }
        if (colSpan != "")                  { output.append("ColumnSpan=\"\(colSpan)\" ") }
        if (cellType != "")                 { output.append("CellType=\"\(cellType)\" ") }
        if (textTopInset != "")             { output.append("TextTopInset=\"\(textTopInset)\" ") }
        if (textLeftInset != "")            { output.append("TextLeftInset=\"\(textLeftInset)\" ") }
        if (textBottomInset != "")          { output.append("TextBottomInset=\"\(textBottomInset)\" ") }
        if (textRightInset != "")           { output.append("TextRightInset=\"\(textRightInset)\" ") }
        output.append("ClipContentToTextCell=\"false\" ")
        if (appliedCellStyle != "")         { output.append("AppliedCellStyle=\"\(appliedCellStyle)\" ") }
        output.append(">\n")
        output.append("<ParagraphStyleRange AppliedParagraphStyle=\"\(appliedParagraphStyle)\">\n")
        output.append("<CharacterStyleRange AppliedCharacterStyle=\"\(appliedCharacterStyle)\">\n")
        output.append("<Content>\(content)</Content>\n")
        output.append("</CharacterStyleRange>\n")
        output.append("</ParagraphStyleRange>\n")
        output.append("</Cell>\n")
        return output
    }
}

