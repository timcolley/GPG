//
//  DBManager.swift
//  PricegridBuilder
//
//  Created by Tim Colley on 10/07/2017.
//  Copyright © 2017 GreatRail. All rights reserved.
//

import Cocoa

/**
 A class to access an SQLite Database using FMDB
 
 - Author: Tim Colley
 - Copyright: Great Rail Journeys 2018
 
 */
public class DBManager: NSObject {
    
    /// Shared FMDB SQLite Database Manager Object
    static let shared: DBManager = DBManager()
    
    /// Filename for the database
    let databaseFileName = "database.sqlite"
    
    /// Filepath to the database
    var pathToDatabase: String!
    
    /// The database
    var database: FMDatabase!
    
    /**
     Object init, sets up the paths to the database file
     
     - Returns: void
     
     */
    override init() {
        super.init()
        var bundlepath = String(describing: Bundle.main)
        bundlepath = bundlepath.replacingOccurrences(of: "> (loaded)", with: "")
        bundlepath = bundlepath.replacingOccurrences(of: "NSBundle <", with: "")
        pathToDatabase = bundlepath + "/Contents/Resources/database.sqlite"
    }
    
    
    /**
     Opens the database for use
    
     - Returns: **Bool** if the connection was successful or not
    
     */
    func openDatabase() -> Bool {
        database = FMDatabase(path: pathToDatabase!) // Overwrite original database
        database.open()
        return true
        
    }
    
    /**
     Resurns a subset of the database based on the supplied tourcode
     
     - Parameter input: **String** the tour code
     - Returns: **FMResultSet** the The result set in FMDB ResultSet format
     
     */
    func returnTours(tourCode: String) -> [[String]] {
        var data: FMResultSet!
        var dataArray = [[String]]()
        _ = openDatabase()
        do {
            try data = database.executeQuery("SELECT * from 'GRJ' WHERE MasterTourCode LIKE '\(NSString.localizedStringWithFormat("%%\(tourCode)%%" as NSString, ""))' order by DepartureDate ASC", values: nil)
        } catch {
            print("Error:" + error.localizedDescription)
        }
        //Format results into usable data (2d array or dictionary)
        while (data.next()) {
            var temp: [String] = []
            let tourcode = data.string(forColumn: "MasterTourCode")!
            let departureDate = data.string(forColumn: "DepartureDate")!
            let sellingPrice = data.string(forColumn: "SellingPrice")!
            let deposit = data.string(forColumn: "Deposit")!
            let SingleSupplement = data.string(forColumn: "SingleSupplement")!
            let railClass = data.string(forColumn: "RailClass")!
            let numOfNights = data.string(forColumn: "nights")!
            let tourTitle = data.string(forColumn: "tourTitle")!
            let dateDay = data.string(forColumn: "date_day")!
            let dateMonth = data.string(forColumn: "date_month")!
            let dateYear = data.string(forColumn: "date_year")!
            let departureLocation = data.string(forColumn: "departureLocation")!
            let visaRequired = data.string(forColumn: "visaRequired")!
            let LHR = data.string(forColumn: "LHR")!
            let LGW = data.string(forColumn: "LGW")!
            let BHX = data.string(forColumn: "BHX")!
            let MAN = data.string(forColumn: "MAN")!
            let NEW = data.string(forColumn: "NEW")!
            let EDI = data.string(forColumn: "EDI")!
            let GLW = data.string(forColumn: "GLW")!
            let STD = data.string(forColumn: "STD")!
            let capacity = data.string(forColumn: "capacity")!
            let taken = data.string(forColumn: "taken")!
            temp = [tourcode, departureDate, sellingPrice, deposit, SingleSupplement, railClass, numOfNights, tourTitle, dateDay, dateMonth, dateYear, departureLocation, visaRequired, LHR, LGW, BHX, MAN, NEW, EDI, GLW, STD, capacity, taken]
            dataArray.append(temp)
        }
        return dataArray
    }
    
    /**
     Returns a subset of the database based on the supplied tourcode & date range
     
     - Parameter input: **String** the tour code
     - Parameter startDate: **String** the start date of the range
     - Parameter endDate: **String** the end date of the range
     - Returns: **FMResultSet** the The result set in FMDB ResultSet format
     
     */
    func returnToursInDateRange(tourCode: String, startDate: String, endDate: String) -> [[String]]
    {
        var data: FMResultSet!
        var dataArray = [[String]]()
        _ = openDatabase()
        do {
            try data = database.executeQuery("SELECT * from 'GRJ' WHERE MasterTourCode LIKE '\(NSString.localizedStringWithFormat("%%\(tourCode)%%" as NSString, ""))' AND DepartureDate >= '\(startDate)' AND DepartureDate <= '\(endDate)'order by DepartureDate ASC", values: nil)
        } catch {
            print("Error:" + error.localizedDescription)
        }
        //Format results into usable data (2d array or dictionary)
        while (data.next()) {
            var temp: [String] = []
            let tourcode = data.string(forColumn: "MasterTourCode")!
            let departureDate = data.string(forColumn: "DepartureDate")!
            let sellingPrice = data.string(forColumn: "SellingPrice")!
            let deposit = data.string(forColumn: "Deposit")!
            let SingleSupplement = data.string(forColumn: "SingleSupplement")!
            let railClass = data.string(forColumn: "RailClass")!
            let numOfNights = data.string(forColumn: "nights")!
            let tourTitle = data.string(forColumn: "TourTitle")!
            let dateDay = data.string(forColumn: "date_day")!
            let dateMonth = data.string(forColumn: "date_month")!
            let dateYear = data.string(forColumn: "date_year")!
            let departureLocation = data.string(forColumn: "departureLocation")!
             let visaRequired = data.string(forColumn: "visaRequired")!
            let LHR = data.string(forColumn: "LHR")!
            let LGW = data.string(forColumn: "LGW")!
            let BHX = data.string(forColumn: "BHX")!
            let MAN = data.string(forColumn: "MAN")!
            let NEW = data.string(forColumn: "NEW")!
            let EDI = data.string(forColumn: "EDI")!
            let GLW = data.string(forColumn: "GLW")!
            let STD = data.string(forColumn: "STD")!
            let capacity = data.string(forColumn: "capacity")!
            let taken = data.string(forColumn: "taken")!
            temp = [tourcode, departureDate, sellingPrice, deposit, SingleSupplement, railClass, numOfNights, tourTitle, dateDay, dateMonth, dateYear, departureLocation, visaRequired, LHR, LGW, BHX, MAN, NEW, EDI, GLW, STD, capacity, taken]
            dataArray.append(temp)
        }
        return dataArray
    }
    
    /**
     Gets all the tour codes from the dataset, removing year codes and duplicates
     
     - Returns: **[String]** a collection of tour codes
     
     */
    func returnAllTourCodes() -> [String] {
        var data: FMResultSet!
        var dataArray = [String]()
        _ = openDatabase()
        do {
            try data = database.executeQuery("SELECT MasterTourCode from 'GRJ' order by MasterTourCode ASC", values: nil)
        } catch {
            print("Error:" + error.localizedDescription)
        }
        var tempCode = ""
        while (data.next()) {
            
            if ( data.string(forColumn: "MasterTourCode")! == tempCode ) {
                tempCode = data.string(forColumn: "MasterTourCode")!
            } else {
                let cs = CharacterSet.init(charactersIn: "1234567890")
                tempCode = tempCode.description.trimmingCharacters(in: cs)
                dataArray.append(tempCode)
                tempCode = data.string(forColumn: "MasterTourCode")!
            }
        }
        dataArray.remove(at: 0)
        return dataArray
    }
    
    /**
     Creates a new table for the data to be supplied later
     
     - Parameter name: **String** the table name
     - Returns: **Bool** returns *true* if successful
     
     */
    func createTable(name: String) -> Bool {
        do {
            try  database.executeUpdate("CREATE TABLE '\(name)' (ID integer primary key autoincrement not null, MasterTourCode text not null, DepartureDate text not null, SellingPrice text not null, Deposit text not null, SingleSupplement text not null, RailClass text not null, nights text not null, tourTitle text not null, visaRequired text, departureLocation text not null, LHR text, LGW text, BHX text, MAN text, NEW text, EDI text, GLW text, STD text, capacity text not null, taken text not null)", values: nil)
        } catch { return false }
        return true
    }
}

