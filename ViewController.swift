//
//  ViewController.swift
//  GreatPriceGrids
//
//  Created by Tim Colley on 27/02/2018.
//  Copyright © 2018 GreatRail. All rights reserved.
//

import Cocoa

/**
 View controller for the main window
 
 - Author: Tim Colley
 - Copyright: Great Rail Journeys 2018
 
 */
class ViewController: NSViewController {
    
    ///Value for overriding the rail class
    var railClassOverrideValue: String!
    ///Value for overriding the visa requirements
    var visaOverrideValue: String!
    ///Value for overriding the tour code
    var tourCodeOverrideValue: String!
    ///Value for overriding the tour title
    var tourTitleOverrideValue: String!
    ///Value for overriding the length of the tour in days
    var tourDaysOverrideValue: String!
    ///Value for overriding the departure location of the tour
    var tourDepartureLocationOverrideValue: String!
    //Value for overriding the flights status of the tour
    var flightsOverrideValue: String!
    ///The data handler. Used to access the data model
    var data: DataHandler!
    ///The IDML generator. used to push the data model, overrides and options to the building phase
    var IDML: idmlGenerator!
    ///does the tour have a Fly:Home option?
    var addFlyHome: Bool!
    ///Do we need a Late Departures panel?
    var addLates: Bool!
    ///Do we need to remove the tour title?
    var removeTourTitle: Bool!
    //What is the format we need?
    var gridFormat: String!
    
    ///Quit Button
    @IBOutlet weak var btnQuit: NSButton!
    ///About Button
    @IBOutlet weak var btnAbout: NSButton!
    //Format Pop Up Button
    @IBOutlet weak var pubFormat: NSPopUpButton!
    
    ///Update database button
    @IBOutlet weak var btnUpdate: NSButton!
    ///Tour code selection pop-up button
    @IBOutlet weak var pubTourCode: NSPopUpButton!
    ///Start date date picker
    @IBOutlet weak var dateSpinStart: NSDatePicker!
    ///End date date picker
    @IBOutlet weak var dateSpinEnd: NSDatePicker!
    ///Regional departures checkbox
    @IBOutlet weak var chkRegionalDepartures: NSButton!
    ///Regional departures text view
    @IBOutlet weak var txtRegionalDeparturesList: NSTextField!
    ///Regional departures priceing text view
    @IBOutlet weak var txtRegionalDeparturesPricing: NSTextField!
    ///Small print text view
    @IBOutlet weak var txtSmallPrint: NSTextField!
    ///Departure Location override text view
    @IBOutlet weak var txtOverrideDepartureLocation: NSTextField!
    ///Requires a visa radio button
    @IBOutlet weak var rdoRequiresVisaYes: NSButton!
    ///Does not require visa radio button
    @IBOutlet weak var rdoRequiresVisaNo: NSButton!
    ///Visa not applicable radio button
    @IBOutlet weak var rdoRequiresVisaNA: NSButton!
    ///Add Flights override checkbox
    @IBOutlet weak var chkAddFlights: NSButton!
    ///Add fly:Home checkbox
    @IBOutlet weak var chkAddFlyHome: NSButton!
    ///Main override check box (use of this is syslogged)
    @IBOutlet weak var chkOverrideDefaults: NSButton!
    ///Tour code override textbox
    @IBOutlet weak var txtOverrideTourCode: NSTextField!
    ///Tour title override text box
    @IBOutlet weak var txtOverrideTourTitle: NSTextField!
    ///Duration override text box
    @IBOutlet weak var txtOverrideNumDays: NSTextField!
    ///Rail class override radio button - First class
    @IBOutlet weak var rdoRailClass1: NSButton!
    ///Rail class override radio button - Standard class
    @IBOutlet weak var rdoRailClass2: NSButton!
    ///Rail class override radio button - First & Standard class
    @IBOutlet weak var rdoRailClass12: NSButton!
    ///Rail class override radio button - International
    @IBOutlet weak var rdoRailClassI: NSButton!
    ///Single supplement valu override text box
    @IBOutlet weak var txtOverrideSingleSupp: NSTextField!
    ///Deposit value override text box
    @IBOutlet weak var txtOverrideDeposit: NSTextField!
    ///Add late departures checkbox
    @IBOutlet weak var chkAddLates: NSButton!
    ///Remove tour title checkbox
    @IBOutlet weak var chkRemoveTitle: NSButton!
    ///Data preview panel text view
    @IBOutlet var txtOutput: NSTextView!

    @IBAction func btnHelp(_ sender: Any) {
        if let url = URL(string: "http://192.168.1.100/gpg/Userguide/firstlook.html"), NSWorkspace.shared.open(url) {
        }
    }
    /**
     View controller for the about box
     
     - Returns: void
     
     */
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        updateTourCodes()
        pubTourCode_Change(self)
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
     Update the view, when the tour code changes
     
     - Returns: void
     
     */
    @IBAction func pubTourCode_Change(_ sender: Any) {
        configure(input: DataHandler(tourCode: pubTourCode.selectedItem!.title, startDate: "", endDate: "", limit: 3))
        dateSpinStart.dateValue = data.startDate
        dateSpinEnd.dateValue = data.endDate
    }
    
    /**
     Update the format for the pricegrid
     
     - Returns: void
     
     */
    @IBAction func pubFormatSelect(_ sender: Any) {
        if (pubFormat.selectedItem!.title == "GRJ") {
            gridFormat = "GRJ"
            txtSmallPrint.stringValue = "E=Eurostar Meal, B=Breakfast, L=Lunch, D=Dinner. These meals, where shown are included in the price of your holiday. Please note, an increased deposit may be required for upgrades and variations. Please read our Booking Conditions available on request or online before you book"
            chkAddFlyHome.isEnabled = true
            chkAddFlights.isEnabled = true
            chkRemoveTitle.isEnabled = true
            chkAddLates.isEnabled = true
        }
        if (pubFormat.selectedItem!.title == "RD") {
            gridFormat = "RD"
            txtSmallPrint.stringValue = "Please note, an increased deposit may be required for upgrades and variations. Please read our Booking Conditions available on request or online before you book"
            chkAddFlyHome.isEnabled = false
            chkAddFlights.isEnabled = false
            chkRemoveTitle.isEnabled = false
            chkAddLates.isEnabled = false
        }
    }
    
    
    /**
     Configure the visual elements depending on options and selections
     
     - Returns: void
     
     */
    func configure(input: DataHandler) {
        data = input
        txtOutput.string = ""
        chkAddFlights.state = .off
        txtOverrideTourCode.stringValue = data.tourCode
        txtOverrideNumDays.stringValue = data.numOfDays
        txtOverrideTourTitle.stringValue = data.tourTitle
        txtOverrideDepartureLocation.stringValue = data.departureLocation
        chkFlyHome(self)
        chkAddLates(self)
        chkRemoveTitle(self)
        pubFormatSelect(self)
        
        switch data.railClass {
        case "Standard" :
            rdoRailClass2.state = .on
            
        case "First" :
            rdoRailClass1.state = .on
            
        case "International" :
            rdoRailClassI.state = .on
            chkAddFlights.state = .on
            
        case "First & Standard" :
            rdoRailClass12.state = .on
            
        default :
            break;
        }
        
        txtOutput.string = data.getPreviewOutput()
        txtOverrideDeposit.stringValue = "£" + data.deposit
        if (data.singleSupplement == "") {
            txtOverrideSingleSupp.stringValue = "NSS"
        } else {
            txtOverrideSingleSupp.stringValue = "£" + data.singleSupplement
        }
        
        if (data.hasRegionalDepartures) {
            txtRegionalDeparturesList.stringValue = data.regionalDeparturesAirports
            txtRegionalDeparturesPricing.stringValue = data.regionalDeparturesSupplements
            chkRegionalDepartures.state = .on
            chkRegionalDepartures(self)
        } else {
            txtRegionalDeparturesPricing.stringValue = ""
            txtRegionalDeparturesList.stringValue = ""
            chkRegionalDepartures.state = .off
            chkRegionalDepartures(self)
        }
        if (data.requiresVisa != "") {
            switch (data.requiresVisa)
            {
            case "0" :
                rdoRequiresVisaNo.state = .on
                break;
                
            case "1" :
                rdoRequiresVisaYes.state = .on
                break;
                
            case "NA" :
                rdoRequiresVisaNA.state = .on
                break;
                
            default :
                rdoRequiresVisaNA.state = .on
                break;
            }
        }
    }

    
    /**
     Check for regional departures and configure the view to reflect this.
     
     - Returns: void
     
     */
    @IBAction func chkRegionalDepartures(_ sender: Any) {
        if (chkRegionalDepartures.state == .on) {
            txtRegionalDeparturesList.isEnabled = true
            txtRegionalDeparturesPricing.isEnabled = true
        } else {
            txtRegionalDeparturesList.isEnabled = false
            txtRegionalDeparturesPricing.isEnabled = false
        }
    }
    
    /**
     Enable or disable override controls in the view. Log the attempt in the system log
     
     - Returns: void
     
     */
    @IBAction func chkOverrideDefaultValues(_ sender: Any) {
        if (chkOverrideDefaults.state == .on) {
            txtOverrideTourCode.isEnabled = true
            txtOverrideTourTitle.isEnabled = true
            txtOverrideNumDays.isEnabled = true
            rdoRailClass1.isEnabled = true
            rdoRailClass2.isEnabled = true
            rdoRailClass12.isEnabled = true
            rdoRailClassI.isEnabled = true
            txtOverrideSingleSupp.isEnabled = true
            txtOverrideDeposit.isEnabled = true
            NSLog("GPG Overrides enabled for \(pubTourCode.selectedItem?.title ?? "")")
        } else {
            txtOverrideTourCode.isEnabled = false
            txtOverrideTourTitle.isEnabled = false
            txtOverrideNumDays.isEnabled = false
            rdoRailClass1.isEnabled = false
            rdoRailClass2.isEnabled = false
            rdoRailClass12.isEnabled = false
            rdoRailClassI.isEnabled = false
            txtOverrideSingleSupp.isEnabled = false
            txtOverrideDeposit.isEnabled = false
        }
    }
    
    /**
     Exit the app
     
     - Returns: void
     
     */
    @IBAction func btnQuit_Click(_ sender: Any) {
        exit(0);
    }
    
    /**
     Update the database using a CSV file
     
     - Returns: void
     
     */
    @IBAction func btnDBUpdate_Click(_ sender: Any) {
        let openData = csvHandler()
        openData.convertCSV()
        updateTourCodes()
        pubTourCode_Change(self)
    }
    
    /**
     update the dataset and view when the start date is changed
     
     - Returns: void
     
     */
    @IBAction func dateStart_Change(_ sender: Any) {
        if (dateSpinStart.dateValue > dateSpinEnd.dateValue) {
            dateSpinStart.dateValue = data.startDate
        } else {
            configure(input: DataHandler(tourCode: pubTourCode.selectedItem!.title, startDate: cleanDate(input: dateSpinStart.dateValue), endDate: cleanDate(input: dateSpinEnd.dateValue), limit: 3))
        }
    }
    
    /**
     Update the dataset and view when the end date is changed
     
     - Returns: void
     
     */
    @IBAction func dateEnd_Change(_ sender: Any) {
        if (dateSpinEnd.dateValue < dateSpinStart.dateValue) {
            dateSpinEnd.dateValue = data.endDate
        } else {
            configure(input: DataHandler(tourCode: pubTourCode.selectedItem!.title, startDate: cleanDate(input: dateSpinStart.dateValue), endDate: cleanDate(input: dateSpinEnd.dateValue), limit: 3))
        }
    }
    
    /**
     Reformat a Date and return as a string
     
     - Parameter: **Date**, The Date object
     - Returns: **String**, The Date as a String
     
     */
    func cleanDate(input: Date) -> String {
        let newDate: String
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd"
        newDate = dateformatter.string(from: input)
        return newDate
    }
    
    /**
     Check the status of the Rail Class radio buttons and update the override value
     
     - Returns: void
     
     */
    @IBAction func rdoRailSelect_Click(_ sender: Any) {
        if (rdoRailClass1.state == .on)  { self.railClassOverrideValue = "First Class Rail" }
        if (rdoRailClass2.state == .on)  { self.railClassOverrideValue = "Standard Class Rail" }
        if (rdoRailClass12.state == .on) { self.railClassOverrideValue = "First & Standard Class Rail" }
        if (rdoRailClassI.state == .on)  { self.railClassOverrideValue = "" }
    }
    
    /**
     Check the status of the Visa radio buttons and update the override value
     
     - Returns: void
     
     */
    @IBAction func rdoRequiresVisa_Click(_ sender: Any) {
        if (rdoRequiresVisaYes.state == .on) { self.visaOverrideValue = "British Citizens require a visa, Please call for details." }
        if (rdoRequiresVisaNo.state == .on ) { self.visaOverrideValue = "British Citizens do not require a visa, but restrictions do apply. Please call for details." }
        if (rdoRequiresVisaNA.state == .on ) { self.visaOverrideValue = ""}
    }
    
    /**
     Update the pop-up button with a complete list of tour codes from the database
     
     - Returns: void
     
     */
    func updateTourCodes() {
        pubTourCode.removeAllItems()
        for item in DBManager.shared.returnAllTourCodes() {
            pubTourCode.addItem(withTitle: item)
        }
    }
    
    /**
     Check the status of the Fly:Home checkbox and update the override value
     
     - Returns: void
     
     */
    @IBAction func chkFlyHome(_ sender: Any) {
        if (chkAddFlyHome.state == .on ) {
            data.hasFlyHome = true
        }
        else {
            data.hasFlyHome = false
        }
    }
    
    /**
     Check the status of the Late Departures checkbox and update the override value
     
     - Returns: void
     
     */
    @IBAction func chkAddLates(_ sender: Any) {
        if (chkAddLates.state == .on ) {
            data.hasLatesBanner = true
        }
        else {
            data.hasLatesBanner = false
        }
    }
    
    /**
     Check the status of the remove tour title checkbox and update the override value
     
     - Returns: void
     
     */
    @IBAction func chkRemoveTitle(_ sender: Any) {
        if (chkRemoveTitle.state == .on ) {
            data.removeTourTitle = true
        }
        else {
            data.removeTourTitle = false
        }
    }
    
    
    /**
     Collect all options, overrides & data. Anaylize the dataset and run the process of building the grid.
     
     - Returns: void
     
     */
    @IBAction func btnExecute(_ sender: Any) {
        IDML = idmlGenerator()
        var firstClassText = ""
        if (data.hasRailClass1) { firstClassText = "First Class Rail" }
        if (data.hasRailClass12) { firstClassText = "First & Standard Class Rail" }
        
         print ("tourTitle: \(txtOverrideTourTitle.stringValue)")
         print ("duration: \(txtOverrideNumDays.stringValue)")
         print ("departureLocation: \(txtOverrideDepartureLocation.stringValue)")
         print ("tourCode: \(txtOverrideTourCode.stringValue)")
         print ("railClass: \(data.railClass)")
         print ("rdl: \(txtRegionalDeparturesList.stringValue)")
         print ("rdp: \(txtRegionalDeparturesPricing.stringValue)")
         print ("smallPrint: \(txtSmallPrint.stringValue)")
         print ("deposit: \(txtOverrideDeposit.stringValue)")
         print ("singlesupp: \(txtOverrideSingleSupp.stringValue)")
         print ("LatesPanel: \(data.hasLatesBanner)")
         print ("HasFlights: \(data.hasFlights)")
         print ("RegDeps:    \(data.hasRegionalDepartures)")
         print ("FlyHome:    \(data.hasFlyHome)")
         print ("DoubleYearMode: \(data.doubleYearMode)")
         print ("DiscardTourTitle: \(data.removeTourTitle)")
         print ("YearOne: \(data.yearOne)")
         print ("YearTwo: \(data.yearTwo)")
         print ("data: \(data.tours)")
         print ("HasStandardClassDepartures: \(data.getStandardOptionStatus())")
         print ("firstClassValue: \(firstClassText)")
         print ("format: \(gridFormat)")
        
        IDML.buldGrid(
                tourTitle: txtOverrideTourTitle.stringValue,
                duration: txtOverrideNumDays.stringValue,
                departureLocation: txtOverrideDepartureLocation.stringValue,
                tourCode: txtOverrideTourCode.stringValue,
                railClass: data.railClass,
                rdl: txtRegionalDeparturesList.stringValue,
                rdp: txtRegionalDeparturesPricing.stringValue,
                smallPrint: txtSmallPrint.stringValue,
                deposit: txtOverrideDeposit.stringValue,
                singlesupp: txtOverrideSingleSupp.stringValue,
                LatesPanel: data.hasLatesBanner,
                HasFlights: data.hasFlights,
                RegDeps:    data.hasRegionalDepartures,
                FlyHome:    data.hasFlyHome,
                DoubleYearMode: data.doubleYearMode,
                DiscardTourTitle: data.removeTourTitle,
                YearOne: data.yearOne,
                YearTwo: data.yearTwo,
                data: data.tours,
                HasStandardClassDepartures: data.getStandardOptionStatus(),
                firstClassValue: firstClassText,
                format: gridFormat
            
        )
        NSLog("PriceGrid Built for \(txtOverrideTourCode.stringValue) - \(txtOverrideTourTitle.stringValue) with range: \(dateSpinStart.dateValue.description)-\(dateSpinEnd.dateValue.description)")
    }
}
