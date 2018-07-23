//
//  csvHandler.swift
//  GreatPriceGrids
//
//  Created by Tim Colley on 27/02/2018.
//  Copyright © 2018 GreatRail. All rights reserved.
//
// This code uses a file open dialogue for selection of a CSV file.
//  it then reads the file one line at a time and reformats the objects description
//  into a valid SQLite statement for insertion into the database it just opened or created.
//

import Foundation
import Cocoa

/**
 A Class to handle CSV Files and process them into an SQLite database
 
 - Author: Tim Colley
 - Copyright: Great Rail Journeys 2018
 
 */
class csvHandler : NSObject {
    ///The path to the CSV File
    var path: String!
    
    /**
     Converts a Comma Seperated Values (CSV) file into an SQLite statement and then executes it
     
     */
    func convertCSV() {
        var myString: String!
        _ = DBManager.shared.openDatabase()
        let dialog = NSOpenPanel()
        dialog.title                   = "Open data file..."
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["csv"]
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let results = dialog.urls // Pathnames of the files
            if (results.count > 0) {
                for result in results
                {
                    var csvPath = result.absoluteString
                    csvPath = csvPath.replacingOccurrences(of: "file://", with: "")
                    csvPath = csvPath.replacingOccurrences(of: "%20", with: " ")
                    do { try DBManager.shared.database.executeUpdate("DROP TABLE 'GRJ'", values: nil) } catch { print("Error:" + error.localizedDescription) }
                    _ = DBManager.shared.createTable(name: "GRJ")
                    do {
                        myString = try String(contentsOf: result, encoding: String.Encoding.utf8)
                        convertData(input: myString)
                        updateDbDates()
                    } catch { }
                }
            }
            
        }
    }
    
    /**
     Builds an SQLite Query from the contents of a properly formatted CSV String, then executes it
     
     - Parameter input: **String** the raw CSV String
     - Returns: **None**. However, the data from the CSV file is placed into the SQLite Database
     
     */
    func convertData(input : String) {
        var data = input.components(separatedBy: .newlines)
        data.remove(at: 0)
        for line in data {
            if line != "" {
                let components = line.components(separatedBy: ",")
                let item = components.description
                var output = "INSERT INTO GRJ (mastertourcode,departuredate,sellingprice,deposit,singlesupplement,RailClass,nights,tourTitle,visaRequired,departureLocation,LHR,LGW,BHX,MAN,NEW,EDI,GLW,STD,capacity,taken) VALUES "
                var cleancomponent = item
                cleancomponent = cleancomponent.replacingOccurrences(of: "[\"", with: "('")
                cleancomponent = cleancomponent.replacingOccurrences(of: "\"]", with: "')")
                cleancomponent = cleancomponent.replacingOccurrences(of: "\"", with: "'")
                cleancomponent = cleancomponent.replacingOccurrences(of: "\\'",  with: "''")
                cleancomponent = cleancomponent.replacingOccurrences(of: "', ' ", with: ", ")
                cleancomponent = cleancomponent.replacingOccurrences(of: "'''", with: "'")
                output = output + cleancomponent
                do { try DBManager.shared.database.executeUpdate(output, values: nil) } catch { print("Error:" + error.localizedDescription) }
            }
        }
    }
    
    
    /**
     Converts a numeric month date to a short alphanumeric date
     
     - Parameter input: **String** the original date (01, 02, etc.)
     - Returns: **String** the formatted date (Jan, Feb, etc.)
     
     */
    func convertShortToLongMonth(input: String) -> String {
        switch input {
        case "01":
            return "Jan"
        case "02":
            return "Feb"
        case "03":
            return "Mar"
        case "04":
            return "Apr"
        case "05":
            return "May"
        case "06":
            return "Jun"
        case "07":
            return "Jul"
        case "08":
            return "Aug"
        case "09":
            return "Sep"
        case "10":
            return "Oct"
        case "11":
            return "Nov"
        case "12":
            return "Dec"
        default:
            return ""
        }
    }
    
    /**
     Pulls the dates column from the database and updates the table with new columns for the seperated values
     
     */
    func  updateDbDates() {
        var data: FMResultSet!
        _ = DBManager.shared.openDatabase()
        var query = "ALTER TABLE 'GRJ' ADD COLUMN 'date_day' text"
        DBManager.shared.database.executeStatements(query)
        query = "ALTER TABLE 'GRJ' ADD COLUMN 'date_month' text"
        DBManager.shared.database.executeStatements(query)
        query = "ALTER TABLE 'GRJ' ADD COLUMN 'date_year' text"
        DBManager.shared.database.executeStatements(query)
        do {
            try data = DBManager.shared.database.executeQuery("Select id, departuredate from 'GRJ'", values: nil)
            while data.next() {
                let originalDate = data.string(forColumn: "departuredate")!
                /// DAYS
                let endOfDays = originalDate.index((originalDate.endIndex), offsetBy: -8)
                var day = originalDate[..<endOfDays]
                var id = data.string(forColumn: "id")!
                do {
                    try DBManager.shared.database.executeUpdate("UPDATE 'GRJ' SET date_day = \(day) WHERE id = \(id)", values: nil)
                } catch {
                    print("Error:" + error.localizedDescription)
                }
                //MONTHS
                let startOfmonth = originalDate.index((originalDate.startIndex), offsetBy: 3)
                let endOfmonth = originalDate.index((originalDate.endIndex), offsetBy: -5)
                var month = originalDate[startOfmonth..<endOfmonth]
                id = data.string(forColumn: "id")!
                let newmonth = convertShortToLongMonth(input: String(month))
                do {
                    try DBManager.shared.database.executeUpdate("UPDATE 'GRJ' SET date_month = '\(newmonth)' WHERE id = \(id)", values: nil)
                } catch {
                    print("Error:" + error.localizedDescription)
                }
                let startOfyear = originalDate.index((originalDate.startIndex), offsetBy: 6)
                let endOfyear = originalDate.index((originalDate.endIndex), offsetBy: 0)
                let year = originalDate[startOfyear..<endOfyear]
                id = data.string(forColumn: "id")!
                do {
                    try DBManager.shared.database.executeUpdate("UPDATE 'GRJ' SET date_year = \(year) WHERE id = \(id)", values: nil)
                } catch {
                    print("Error:" + error.localizedDescription)
                }
                do {
                    if (month.count <= 1) { month = "0" + month  }
                    if (day.count <= 1) { day = "0" + month  }
                    try DBManager.shared.database.executeUpdate("UPDATE 'GRJ' SET departuredate = \(year)\(month)\(day) WHERE id = \(id)", values: nil)
                } catch {
                    print("Error:" + error.localizedDescription)
                }
            }
        } catch {
            print("Error:" + error.localizedDescription)
        }
    }
}
