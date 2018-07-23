//
//  grjIDML.swift
//  GreatPriceGrids
//
//  Created by Tim Colley on 20/07/2018.
//  Copyright © 2018 GreatRail. All rights reserved.
//

import Foundation


class rdIDML : NSObject {
    
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
        /// container for the IDML output to be added
        var output = ""
        /// Counter for tracking the table row currently being built
        var currentRow = 0
        
        addColumns(gridsize: gridSize)
        
        addHeader(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
        addDepartureYear(row: String(currentRow), colSpan: String(numberOfCOLS), year: yearOne); currentRow += 1
        
        
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

            for i in 0 ... (Col1.count-1) {
                rowDefs.append(addRowDef(ownID: "", name: "\(String(currentRow))", textTopInset: "0", textLeftInset: "0", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "11.338582677165356", minimumHeight: "11.338582677165356", autoGrow: " AutoGrow=\"false\" "))
                addDeparture(row: String(currentRow), leftStrokeColor: "White", colStart: 0, monthValue: Col1[i][9], dayValue: Col1[i][8], priceValue: Col1[i][2])
                addDeparture(row: String(currentRow), leftStrokeColor: "White", colStart: 3, monthValue: Col2[i][9], dayValue: Col2[i][8], priceValue: Col2[i][2])
                addDeparture(row: String(currentRow), leftStrokeColor: "Regular", colStart: 6, monthValue: Col3[i][9], dayValue: Col3[i][8], priceValue: Col3[i][2])
                currentRow += 1
            }
        }
        
        if (gridSize == 2) {
            var firstYear = [[String]]()
            var secondYear = [[String]]()
            var Y1Col1 = [[String]]()
            var Y1Col2 = [[String]]()
            
            for element in data {
                if (element[10] == yearOne) { firstYear.append(element) }
            }
            
            if (firstYear.count == 1) {
                firstYear.append(data[0])
                firstYear.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""])
            } else {
                var i = 0
                while (i <= (firstYear.count/2)-1)     { Y1Col1.append(firstYear[i]); i += 1;}
                while (i <= firstYear.count-1)         { Y1Col2.append(firstYear[i]); i += 1;}
            }
            
            if (Y1Col1.count < Y1Col2.count ) { while (Y1Col1.count != Y1Col2.count) { Y1Col1.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) } }
            if (Y1Col2.count < Y1Col1.count ) { while (Y1Col2.count != Y1Col1.count) { Y1Col2.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) } }
            
            for i in 0 ... (Y1Col1.count-1) {
                rowDefs.append(addRowDef(ownID: "", name: "\(String(currentRow))", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleRowHeight: "8.503937007874017", minimumHeight: "8.503937007874017", autoGrow: " AutoGrow=\"false\" "))
                addDeparture(row: String(currentRow), leftStrokeColor: "Black", colStart: 0, monthValue: Y1Col1[i][9], dayValue: Y1Col1[i][8], priceValue: Y1Col1[i][2])
                addDeparture(row: String(currentRow), leftStrokeColor: "", colStart: 2, monthValue: Y1Col2[i][9], dayValue: Y1Col2[i][8], priceValue: Y1Col2[i][2])
                currentRow += 1
            }
            
            if (doubleYear == true) {
                var Y2Col1 = [[String]]()
                var Y2Col2 = [[String]]()
                
                for element in data {
                    if (element[10] == yearTwo) { secondYear.append(element) }
                }
                
                if (secondYear.count == 1) {
                    firstYear.append(data[0])
                    firstYear.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""])
                } else {
                    var i = 0
                    while (i <= (secondYear.count/2)-1)     { Y2Col1.append(secondYear[i]); i += 1;}
                    while (i <= secondYear.count-1)         { Y2Col2.append(secondYear[i]); i += 1;}
                }
                if (Y2Col1.count < Y2Col2.count ) { while (Y2Col1.count != Y2Col2.count) { Y2Col1.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) } }
                if (Y2Col2.count < Y2Col1.count ) { while (Y2Col2.count != Y2Col1.count) { Y2Col2.append(["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) } }
                addDepartureYear(row: String(currentRow), colSpan: String(numberOfCOLS), year: yearTwo); currentRow += 1
                
                for i in 0 ... (Y2Col1.count-1) {
                    rowDefs.append(addRowDef(ownID: "", name: "\(String(currentRow))", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleRowHeight: "8.503937007874017", minimumHeight: "8.503937007874017", autoGrow: " AutoGrow=\"false\" "))
                    addDeparture(row: String(currentRow), leftStrokeColor: "Black", colStart: 0, monthValue: Y2Col1[i][9], dayValue: Y2Col1[i][8], priceValue: Y2Col1[i][2])
                    addDeparture(row: String(currentRow), leftStrokeColor: "", colStart: 2, monthValue: Y2Col2[i][9], dayValue: Y2Col2[i][8], priceValue: Y2Col2[i][2])
                    currentRow += 1
                }
            }
        }
        
        
        
        
        
        if (regionalDepartures == true) {
            addSpacer(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
            addRegionalDepartureLocations(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
            addRegionalDeparturePrices(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
        }
        addMealKeys(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
        addSmallPrint(row: String(currentRow), colSpan: String(numberOfCOLS)); currentRow += 1
        output.append(addTableDef(rows: "\(String(currentRow))", cols: "\(gridSize*2)"))
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
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleColumnWidth: "61.653543307086615")); colTrack += 1;
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleColumnWidth: "28.34645669291339")); colTrack += 1;
                numberOfCOLS = 4
            }
            break;
        case 3:
            for _ in 0 ..< gridsize {
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleColumnWidth: "31.69133858267717")); colTrack += 1;
                colDefs.append(addColDef(ownID: "", name: "\(colTrack)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleColumnWidth: "28.34645669291339")); colTrack += 1;
                numberOfCOLS = 6
            }
            break;
        default:
            break;
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
    func addDeparture(row: String, leftStrokeColor: String, colStart: Int, monthValue: String, dayValue: String, priceValue: String) {
        var pricevalue = priceValue
        var datesCellColor = "Table Alt Dates NoStroke"
        var priceCellColor = "Table Alt Price NoStroke"
        var soldout = "CharacterStyle/SOLD OUT"
        
        if (Int(row)! % 2 == 0) {
            datesCellColor = "Table Dates NoStroke"
            priceCellColor = "Table Price NoStroke"
        }
        
        if (leftStrokeColor == "Black" && priceCellColor == "Table Price NoStroke") { priceCellColor = "Table Price Stroke" }
        if (leftStrokeColor == "Black" && priceCellColor == "Table Alt Price NoStroke") { priceCellColor = "Table Alt Price Stroke" }
        
        if (priceValue.count == 4) { pricevalue = priceValue; pricevalue.insert(",", at: pricevalue.index(pricevalue.startIndex, offsetBy: 1)) }
        if (priceValue.count == 5) { pricevalue = priceValue; pricevalue.insert(",", at: pricevalue.index(pricevalue.startIndex, offsetBy: 2)) }
        if (priceValue == "" || priceValue == "SOLD OUT") { } else { pricevalue = "£" + pricevalue }

        if (priceValue == "SOLD OUT") { soldout = "CharacterStyle/SOLD OUT" } else { soldout = "CharacterStyle/$ID/[No character style]" }
        
        cellDefs.append(addCell(  ownID: "", name: "\(colStart):\(row)", rowSpan: "1", colSpan:  "1", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", appliedCellStyle: "CellStyle/\(datesCellColor)", appliedParagraphStyle: "ParagraphStyle/Table Dates", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "\(monthValue) \(dayValue)"))
        
        cellDefs.append(addCell(  ownID: "", name: "\(colStart + 1):\(row)", rowSpan: "1", colSpan:  "1", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", appliedCellStyle: "CellStyle/\(priceCellColor)", appliedParagraphStyle: "ParagraphStyle/Table Price", appliedCharacterStyle: soldout, content: "\(pricevalue)"))
    }
    
    
    
    /**
     builds and returns the IDML required for regional departures locations option row
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, The regional departures locations element of the table.
     
     */
    func addRegionalDepartureLocations(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleRowHeight: "8.508661417322837", minimumHeight: "8.508661417322837", autoGrow: " AutoGrow=\"true\"" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "2.834645669291339", textBottomInset: "1.415645669291339", textRightInset: "2.834645669291339", appliedCellStyle: "CellStyle/Table RegDeps Locations", appliedParagraphStyle: "ParagraphStyle/Table RegDep Locations", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "$REGIONAL_DEPARTURE_LIST$" ))
    }
    
    /**
     builds and returns the IDML required for regional departures option supplement prices row
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.

     - Returns: **String**, The regional departures supplement prices element of the table.
     
     */
    func addRegionalDeparturePrices(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleRowHeight: "8.508661417322837", minimumHeight: "8.508661417322837", autoGrow: " AutoGrow=\"true\"" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "2.834645669291339", textBottomInset: "1.415645669291339", textRightInset: "2.834645669291339", appliedCellStyle: "CellStyle/Table RegDeps Prices", appliedParagraphStyle: "ParagraphStyle/Table RegDep Prices", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "$REGIONAL_DEPARTURE_PRICES$" ))
    }
    
    /**
     builds and returns the IDML required for Meal Keys row
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, The regional departures supplement prices element of the table.
     
     */
    func addMealKeys(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleRowHeight: "8.508661417322837", minimumHeight: "8.508661417322837", autoGrow: " AutoGrow=\"true\"" ))
        
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "1.4173228346456694", textLeftInset:  "2.834645669291339", textBottomInset: "1.415645669291339", textRightInset: "2.834645669291339", appliedCellStyle: "CellStyle/Table MealKeys", appliedParagraphStyle: "ParagraphStyle/Table MealKeys", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "B=Breakfast, L=Lunch, D=Dinner. These meals, where shown are included in the price of your holiday." ))
    }
    
    /**
     builds and returns the IDML required for a spacer row, this type of row will alway be spanned across all columns and be exactly 1.035mm high
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, A spacer element for the table.
     
     */
    func addSpacer(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "0", clipContentToTextCell: "false", singleRowHeight: "2.9990551181102365", minimumHeight: "2.9990551181102365", autoGrow: "AutoGrow=\"false\"" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "2.834645669291339", textBottomInset: "0", textRightInset: "0", appliedCellStyle: "CellStyle/Table Spacer", appliedParagraphStyle: "ParagraphStyle/$ID/NormalParagraphStyle", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "" ))
    }
    
    /**
     builds and returns the IDML required for the small print element of the table
     
     -  parameter row:                 **String**,         The row number of this table element. Since IDML requires the the 'name' parameter be used to track the rows and column locations of a cell, this needs to be dynamic.
     -  parameter colSpan:             **String**,         The number of columns to span, used to provide a horizontally merged cell within a row.
     
     - Returns: **String**, the small print element for the table.
     
     */
    func addSmallPrint(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleRowHeight: "28.34645669291339", minimumHeight: "28.34645669291339", autoGrow: "AutoGrow=\"True\"" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", appliedCellStyle: "CellStyle/Table SmallPrint", appliedParagraphStyle: "ParagraphStyle/Table SmallPrint", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "$SMALLPRINT$" ))
    }
    
    /**
     builds and returns the IDML required for the table Header. This specifies all options in IDML for the table including columns & rows
     
     -  parameter row:              **String**,         The number of rows required by the table
     -  parameter colSpan:          **String**,         The number of columns required by the table
     
     - Returns: **String**, the table definition.
     
     */
    func addHeader(row: String, colSpan: String) {
        rowDefs.append(addRowDef( ownID: "", name: "0", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleRowHeight: "18.708661417322837", minimumHeight: "18.708661417322837", autoGrow: "" ))
        cellDefs.append(addCell(  ownID: "", name: "0:0", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", appliedCellStyle: "CellStyle/Table Header", appliedParagraphStyle: "ParagraphStyle/Table Header", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "Departures" ))
    }
    
    /**
     builds and returns the IDML required for the Year, Duration and tour code field. This specifies all options in IDML for the table including columns & rows
     
     -  parameter row:              **String**,         The number of rows required by the table
     -  parameter colSpan:          **String**,         The number of columns required by the table
     
     - Returns: **String**, the table definition.
     
     */
    func addDepartureYear(row: String, colSpan: String, year: String) {
        rowDefs.append(addRowDef( ownID: "", name: "\(row)", textTopInset: "0", textLeftInset: "2.834645669291339", textBottomInset: "0", textRightInset: "2.834645669291339", clipContentToTextCell: "false", singleRowHeight: "11.508661417322837", minimumHeight: "11.508661417322837", autoGrow: "" ))
        cellDefs.append(addCell(  ownID: "", name: "0:\(row)", rowSpan: "1", colSpan:  "\(colSpan)", cellType: "TextTypeCell", textTopInset: "0", textLeftInset:  "2.834645669291339", textBottomInset: "2.834645669291339", textRightInset: "2.834645669291339", appliedCellStyle: "CellStyle/Table Departure &amp; Tour Code", appliedParagraphStyle: "ParagraphStyle/Table Departure &amp; Tour Code", appliedCharacterStyle: "CharacterStyle/$ID/[No character style]", content: "\(year) Departures from $DEPARTURE_LOCATION$, Tour Code: $TOUR_CODE$ " ))
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

