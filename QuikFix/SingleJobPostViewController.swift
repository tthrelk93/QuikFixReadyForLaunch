//
//  SingleJobPostViewController.swift
//  QuikFix
//
//  Created by Thomas Threlkeld on 9/25/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import Stripe
import SwiftOverlays
import CoreLocation
class TimeCell: UICollectionViewCell{
    @IBOutlet weak var timeLabel: UILabel!
    
}
class DateCell: UICollectionViewCell{
    @IBOutlet weak var dateLabel: UILabel!
    
}

class SingleJobPostViewController: UIViewController, MessagingDelegate, STPPaymentContextDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("hereeee")
    }
    @IBAction func backToJobButtonPressed(_ sender: Any) {
        selectTimeAndDateView.isHidden = true
        acceptJob.setTitle("Accept Job", for: .normal)
    }
    
    @IBOutlet weak var selectTimeAndDateView: UIView!
    
    @IBOutlet weak var availDatesToPick: UILabel!
    
    @IBOutlet weak var availDatesPicker: UIPickerView!
    
    @IBOutlet weak var availTimesToPickLabel: UILabel!
    
    @IBOutlet weak var availTimesPicker: UIPickerView!
    
    @IBOutlet weak var dateCollect: UICollectionView!
    
    @IBOutlet weak var timeCollect: UICollectionView!
    
    @IBOutlet weak var availTimesMainJob: UILabel!
    
    var datesArray = [String]()
    var timesArray = [[String]]()
    var timesForCurDateArray = [String]()
    var geotifications = [Geotification]()
    // 1) To get started with this demo, first head to https://dashboard.stripe.com/account/apikeys
    // and copy your "Test Publishable Key" (it looks like pk_test_abcdef) into the line below.
    let stripePublishableKey = "pk_live_F3qPhd7gnfCP6HP2gi1LTX41"
    
    // 2) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend , click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    let backendBaseURL = "https://quikfixfinal.herokuapp.com"
    
    // 3) Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
   // let appleMerchantID: String? = nil
    
    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = "QuikFix"
    let paymentCurrency = "usd"
    var times = ["1","2","3","4","5","6","7","8","9","10","11","12"]
    var paymentContext: STPPaymentContext?
    
    var theme: STPTheme?
    //var paymentRow: CheckoutRowView?
    //let shippingRow: CheckoutRowView
    //var totalRow: CheckoutRowView?
    //var buyButton: BuyButton?
    //let rowHeight: CGFloat = 44
    //let productImage = UILabel()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var numberFormatter: NumberFormatter?
    //let shippingString: String
    var product = ""
    /*@IBOutlet weak var posterImage: UIImageView!
    
   @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryText: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var posterCity: UILabel!
    @IBOutlet weak var posterName: UILabel!*/
    
    
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var detailsTextView: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    var job1 = JobPost()
    @IBAction func backPressed(_ sender: Any) {
        performSegue(withIdentifier: "SingleJobToJobPosts", sender: self)
    }
    @IBOutlet weak var applySuccessView: UIView!
   
    @IBOutlet weak var acceptJob: UIButton!
    //@IBOutlet weak var shadowView: UIView!
    let locationManager = CLLocationManager()
    @IBAction func applytoJobPressed(_ sender: Any) {
        if selectTimeAndDateView.isHidden == false {
        print("apply pressed")
        self.acceptJob.isEnabled = false
        workerInJob()
        } else {
            selectTimeAndDateView.isHidden = false
            acceptJob.setTitle("Finalize", for: .normal)
        }
        
        

        
    
    }
    var uploadJob = [String:Any]()
    func countDownDuration(){
        print("hey : \(self.jobID)")
        Database.database().reference().child("jobs").child(self.jobID).updateChildValues(["inProgress": true])
    }
    //var sendJob = [String:Any]()
    func chargePoster(){
       
        Database.database().reference().child("jobs").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    if snap.key == self.jobID{
                        var sendJob = snap.value as! [String:Any]
                        sendJob["jobID"] = snap.key
                       // sendJob["senderScreen"] = "normCharge"
                        sendJob["posterID"] = self.posterID
                        print("charge the poster")
                        var tempPayString = sendJob["payment"] as! String
                        var chargeString = tempPayString.substring(from: 1)
                        let tempCharge = ((chargeString as NSString).intValue * 100)
                        print("charge in cents: \(tempCharge)")
                        MyAPIClient.sharedClient.completeCharge(amount: Int(tempCharge), poster: self.posterID, job: sendJob, senderScreen: "normCharge", jobDict: self.uploadJob)
                        Database.database().reference().child("jobs").child(self.jobID).updateChildValues(["inProgress": false])
                    }
                }
            }
        
        
        })
    }
    
    //var product = String()
    var price = Int()
    let settingsVC = SettingsViewController()

    var containsWorkers = false
    var readyToCharge = Bool()
    func workerInJob(){
        //self.workerInJobAlready = false
         SwiftOverlays.showBlockingWaitOverlayWithText("Success! Job added to Upcoming Jobs.")
        
        print("wIJ: \(jobID)")
        Database.database().reference().child("jobs").child(jobID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                //let tempDict = snapshot.value as! [String:Any]
               
                for snap in snapshots{
                    if snap.key == "workers"{
                        self.containsWorkers = true
                        let tempArray = snap.value as! [String]
                        if tempArray.contains((Auth.auth().currentUser!.uid)){
                            
                            //self.workerInJobAlready = true
                            print("already in job")
                            SwiftOverlays.removeAllBlockingOverlays()
                        } else {
                            
                            print("sup, not in job")
                                ////self.applySuccessView.isHidden = false
                                print("posterID: \(self.posterID)")
                            Database.database().reference().child("jobPosters").child(self.posterID).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                        var containsCurrentListings = false
                                        var containsUpcomingJobs = false
                                        var incrementAcceptedCount = false
                                        for snap in snapshots{
                                            if snap.key == "currentListings"{
                                                containsCurrentListings = true
                                                var tempJobArray = snap.value as! [String: [String:Any]]
                                                
                                                
                                                var tempWorkers = self.uploadJob["workers"] as! [String]
                                                tempWorkers.append(Auth.auth().currentUser!.uid)
                                                self.uploadJob["workers"] = tempWorkers
                                                self.uploadJob["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                                self.uploadJob["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                                var acceptCount = self.uploadJob["acceptedCount"] as! Int
                                                acceptCount = acceptCount + 1
                                                self.uploadJob["acceptedCount"] = acceptCount
                                                //tempJobArray[self.jobID] = self.uploadJob
                                                tempJobArray.removeValue(forKey: self.jobID)
                                                //var keyInDictBool = false
                                                //tempJobDict[self.jobID] = self.job
                                                //var tempIDArray = [String]()
                                                var uploadDict = [String:Any]()
                                                uploadDict["currentListings"] = tempJobArray
                                                Database.database().reference().child("jobPosters").child(self.posterID).updateChildValues(uploadDict)
                                                
                                                
                                            } else if snap.key == "upcomingJobs"{
                                                containsUpcomingJobs = true
                                                var tempJobArray = snap.value as! [String: [String:Any]]
                                                
                                                var tempWorkers = self.uploadJob["workers"] as! [String]
                                                self.uploadJob["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                                self.uploadJob["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                                tempWorkers.append(Auth.auth().currentUser!.uid)
                                                self.uploadJob["workers"] = tempWorkers
                                                if incrementAcceptedCount == false {
                                                    var acceptCount = self.uploadJob["acceptedCount"] as! Int
                                                    acceptCount = acceptCount + 1
                                                    self.uploadJob["acceptedCount"] = acceptCount
                                                    incrementAcceptedCount = true
                                                }
                                                
                                                tempJobArray[self.jobID] = self.uploadJob
                                                //var keyInDictBool = false
                                                //tempJobDict[self.jobID] = self.job
                                                //var tempIDArray = [String]()
                                                var uploadDict = [String:Any]()
                                                uploadDict["upcomingJobs"] = tempJobArray
                                                Database.database().reference().child("jobPosters").child(self.posterID).updateChildValues(uploadDict)
                                                
                                                var timeLogDict = [String:Any]()
                                                timeLogDict[Auth.auth().currentUser!.uid] = ["studentOnLocation":"false","studentConfirmsArrival":"false","posterConfirmsArrival":"false","studentPressesStart":"false","studentPressesFinish":"false","posterRecievesBill":"false","posterConfirmsBill":"false","posterIsCharged":"false","studentIsPayed":"false"] as! [String:Any]
                                                Database.database().reference().child("jobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                                Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                                
                                                Database.database().reference().child("jobPosters").child(self.job1.posterID!).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                                
                                            
                                            }
                                        }
                                            
                                        
                                        if containsUpcomingJobs == false{
                                            var uploadData = [String:Any]()
                                            uploadData[self.jobID] = self.job
                                            var uploadDict = [String:Any]()
                                           
                                            uploadDict["upcomingJobs"] = uploadData
                                            Database.database().reference().child("jobPosters").child(self.posterID).updateChildValues(uploadDict)
                                            var timeLogDict = [String:Any]()
                                            timeLogDict[Auth.auth().currentUser!.uid] = ["studentOnLocation":"false","studentConfirmsArrival":"false","posterConfirmsArrival":"false","studentPressesStart":"false","studentPressesFinish":"false","posterRecievesBill":"false","posterConfirmsBill":"false","posterIsCharged":"false","studentIsPayed":"false"] as! [String:Any]
                                            Database.database().reference().child("jobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                            Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                            
                                            Database.database().reference().child("jobPosters").child(self.self.job1.posterID!).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                        
                                        
                                }
                                        if containsCurrentListings == false{
                                            var uploadData = [String:[String:Any]]()
                                            var tempJobArray = snap.value as! [String: [String:Any]]
                                            var tempWorkers = self.uploadJob["workers"] as! [String]
                                            tempWorkers.append(Auth.auth().currentUser!.uid)
                                            self.uploadJob["workers"] = tempWorkers
                                            self.uploadJob["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                            self.uploadJob["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                            var acceptCount = self.uploadJob["acceptedCount"] as! Int
                                            acceptCount = acceptCount + 1
                                            self.uploadJob["acceptedCount"] = acceptCount
                                            uploadData[self.jobID] = self.uploadJob
                                            var uploadDict = [String:Any]()
                                            uploadDict["currentListings"] = uploadData
                                            
                                            Database.database().reference().child("jobPosters").child(self.posterID).updateChildValues(uploadDict)
                                            var timeLogDict = [String:Any]()
                                            timeLogDict[Auth.auth().currentUser!.uid] = ["studentOnLocation":"false","studentConfirmsArrival":"false","posterConfirmsArrival":"false","studentPressesStart":"false","studentPressesFinish":"false","posterRecievesBill":"false","posterConfirmsBill":"false","posterIsCharged":"false","studentIsPayed":"false"] as! [String:Any]
                                            Database.database().reference().child("jobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                            Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                            
                                            Database.database().reference().child("jobPosters").child(self.self.job1.posterID!).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                        
                            }
                                        
                                        Database.database().reference().child("students").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                                var containsJobs = false
                                                var upcomingArray = [String: [String:Any]]()
                                                var incrementAcceptedCount = false
                                                for snap in snapshots {
                                                    
                                                    if snap.key == "upcomingJobs"{
                                                        upcomingArray = snap.value as! [String: [String: Any]]
                                                        
                                                        var tempWorkers = self.uploadJob["workers"] as! [String]
                                                        tempWorkers.append(Auth.auth().currentUser!.uid)
                                                        self.uploadJob["workers"] = tempWorkers
                                                        upcomingArray[self.jobID] = self.uploadJob
                                                        containsJobs = true
                                                    }
                                                    var uploadDict2 = [String:Any]()
                                                    if containsJobs == false{
                                                        
                                                        var tempWorkers = self.uploadJob["workers"] as! [String]
                                                
                                                        tempWorkers.append(Auth.auth().currentUser!.uid)
                                                        self.uploadJob["workers"] = tempWorkers
                                                        if incrementAcceptedCount == false {
                                                            var acceptCount = self.uploadJob["acceptedCount"] as! Int
                                                            acceptCount = acceptCount + 1
                                                            self.uploadJob["acceptedCount"] = acceptCount
                                                            incrementAcceptedCount = true
                                                        }
                                                        self.uploadJob["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                                        self.uploadJob["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                                        //self.uploadJob["acceptedCount"] = acceptCount
                                                         upcomingArray[self.jobID] = self.uploadJob
                                                        uploadDict2["upcomingJobs"] = upcomingArray
                                                    } else {
                                                        uploadDict2["upcomingJobs"] = upcomingArray
                                                    }
                                                    Database.database().reference().child("students").child((Auth.auth().currentUser?.uid)!).updateChildValues(uploadDict2)
                                                }
                                            }
                                            var acceptedCount = Int()
                                            Database.database().reference().child("jobs").child(self.jobID).observeSingleEvent(of: .value, with: { (snapshot) in
                                                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                                    var containsWorkers = false
                                                    var workersArray = [String]()
                                                    var incrementAcceptedCount = false
                                                     var uploadDict2 = [String:Any]()
                                                    
                                                    for snap in snapshots {
                                                        
                                                        if snap.key == "workers"{
                                                            containsWorkers = true
                                                            workersArray = snap.value as! [String]
                                                            workersArray.append((Auth.auth().currentUser!.uid))
                                                            var uploadDict = [String:Any]()
                                                            uploadDict["workers"] = workersArray
                                                            Database.database().reference().child("jobs").child(self.jobID).updateChildValues(uploadDict)
                                                        } else if snap.key == "acceptedCount" {
                                                            if incrementAcceptedCount == false {
                                                                acceptedCount = snap.value as! Int
                                                                acceptedCount = acceptedCount + 1
                                                                uploadDict2["acceptedCount"] = acceptedCount
                                                                incrementAcceptedCount = true
                                                            }
                                                        }
                                                       
                                                            uploadDict2["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                                            uploadDict2["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                                            Database.database().reference().child("jobs").child(self.jobID).updateChildValues(uploadDict2)
                                                            if acceptedCount == self.job1.workers?.count {
                                                                self.readyToCharge = true
                                                            } else {
                                                                self.readyToCharge = false
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                if self.containsWorkers == false{
                                                        var uploadDict = [String:Any]()
                                                        uploadDict["workers"] = ([(Auth.auth().currentUser!.uid)] as Any)
                                                        uploadDict["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                                        uploadDict["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                                        Database.database().reference().child("jobs").child(self.jobID).updateChildValues(uploadDict)
                                                    }
                                                
                                               //// self.applySuccessView.isHidden = true
                                                /*let date = self.job1.date!
                                                var timeComp = (self.job1.startTime!.first! as! [String]).first!.components(separatedBy: ":")// .componentsSeparatedByString(":")
                                                let timeHours = timeComp[0].first!
                                                print("timeHours: \(timeHours)")
                                                let timeHoursInt = Int(String(timeHours))
                                                let triggerTime = timeHoursInt! + (Int(self.job1.jobDuration!)!)
                                                let triggerTimeString = "\(String(describing: triggerTime)):\(timeComp[1])"
                                                print("triggerTime: \(triggerTimeString)")
                                                let dateToFormat = "\(date) \(triggerTimeString)"
                                                
                                                let trigger2TimeString = "\(self.job1.date!) \(self.job1.startTime!)"
                                                
                                                
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "MMMM-dd-yyyy hh:mm a"
                                                let triggerDate = dateFormatter.date(from: dateToFormat)
                                                let trigger2Date = dateFormatter.date(from: trigger2TimeString)
                                                
                                                if self.readyToCharge == true {
                                                let timer2 = Timer(fireAt: trigger2Date!, interval: 0, target: self, selector: #selector(self.countDownDuration), userInfo: nil, repeats: false)
                                                RunLoop.main.add(timer2, forMode: RunLoopMode.commonModes)
                                                
                                                //MyAPIClient.sharedClient.completeCharge(amount: 10,
                                                // poster: self.posterID)
                                                
                                                let timer = Timer(fireAt: triggerDate!, interval: 0, target: self, selector: #selector(self.chargePoster), userInfo: nil, repeats: false)
                                                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                                                }
                                               // let dateFormatter2 = "MMMM-dd-yyyy"
                                               // let triggerDate2 = dateFormatter.dateFrom
                                                
                                                self.selectorJob = self.job1
                                                let trigger2Time = "\(self.job1.date!) \(self.job1.startTime!)"
                                                
                                                
                                                let dateFormatter3 = DateFormatter()
                                                dateFormatter3.dateFormat = "MMMM-dd-yyyy hh:mm a"
                                                let trigger = dateFormatter3.date(from: trigger2Time)
                                                let date3 = Date(timeInterval: -12, since: trigger!)
                                                let date4 = Date(timeInterval: -3, since: trigger!)
                                                let timer3 = Timer(fireAt: date3, interval: 0, target: self, selector: #selector(self.twelveHoursOut), userInfo: nil, repeats: false)
                                                RunLoop.main.add(timer3, forMode: RunLoopMode.commonModes)
                                                
                                                let timer4 = Timer(fireAt: date4, interval: 0, target: self, selector: #selector(self.threeHoursOut), userInfo: nil, repeats: false)
                                                RunLoop.main.add(timer4, forMode: RunLoopMode.commonModes)*/

                                                self.performSegue(withIdentifier: "JobAcceptedBackToProfile", sender: self)
                                                
                                            })
                                            
                                            
                                        })
                                    }
                                })
                            }
                        
                    }
                }
                if self.containsWorkers == false{
                   //// self.applySuccessView.isHidden = false
                    print("posterID: \(self.posterID)")
                    var incrementAcceptedCount = false
                    Database.database().reference().child("jobPosters").child(self.posterID).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            var containsCurrentListings = false
                            var containsUpcomingJobs = false
                            
                            for snap in snapshots{
                                if snap.key == "currentListings"{
                                    containsCurrentListings = true
                                    var tempJobArray = snap.value as! [String: [String:Any]]
                                    tempJobArray.removeValue(forKey: self.job1.jobID!)
                                    
                                    //var keyInDictBool = false
                                    //var tempIDArray = [String]()
                                    var uploadDict = [String:Any]()
                                    uploadDict["currentListings"] = tempJobArray
                                    Database.database().reference().child("jobPosters").child(self.posterID).updateChildValues(uploadDict)
                                    
                                } else if snap.key == "upcomingJobs"{
                                    containsUpcomingJobs = true
                                    var tempJobArray = snap.value as! [String: [String:Any]]
                                    var tempWorkers = [String]()
                                    
                                    if self.uploadJob["workers"] == nil{
                                        tempWorkers = [Auth.auth().currentUser!.uid]
                                    } else {
                                       tempWorkers = self.uploadJob["workers"] as! [String]
                                        tempWorkers.append(Auth.auth().currentUser!.uid)
                                    }
                                    
                                    self.uploadJob["workers"] = tempWorkers
                                    if incrementAcceptedCount == false {
                                        var acceptCount = self.uploadJob["acceptedCount"] as! Int
                                        acceptCount = acceptCount + 1
                                        self.uploadJob["acceptedCount"] = acceptCount
                                        incrementAcceptedCount = true
                                    }
                                    self.uploadJob["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                    self.uploadJob["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                    tempJobArray[self.jobID] = self.uploadJob
                                    //var keyInDictBool = false
                                    //tempJobDict[self.jobID] = self.job
                                    //var tempIDArray = [String]()
                                    var uploadDict = [String:Any]()
                                    uploadDict["upcomingJobs"] = tempJobArray
                                    Database.database().reference().child("jobPosters").child(self.posterID).updateChildValues(uploadDict)
                                    var timeLogDict = [String:Any]()
                                    timeLogDict[Auth.auth().currentUser!.uid] = ["studentOnLocation":"false","studentConfirmsArrival":"false","posterConfirmsArrival":"false","studentPressesStart":"false","studentPressesFinish":"false","posterRecievesBill":"false","posterConfirmsBill":"false","posterIsCharged":"false","studentIsPayed":"false"] as! [String:Any]
                                    Database.database().reference().child("jobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                    Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                    
                                    Database.database().reference().child("jobPosters").child(self.self.job1.posterID!).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                
                                    
                                
                                }
                            }
                            
                            if containsUpcomingJobs == false{
                                var uploadData = [String: [String:Any]]()
                                
                                var tempWorkers = [String]()
                                tempWorkers.append(Auth.auth().currentUser!.uid)
                                self.uploadJob["workers"] = tempWorkers
                                var acceptCount = self.uploadJob["acceptedCount"] as! Int
                                acceptCount = acceptCount + 1
                                self.uploadJob["acceptedCount"] = acceptCount
                                self.uploadJob["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                self.uploadJob["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                uploadData[self.jobID] = self.uploadJob
                                var uploadDict = [String:Any]()
                                uploadDict["upcomingJobs"] = uploadData
                                Database.database().reference().child("jobPosters").child(self.posterID).updateChildValues(uploadDict)
                                var timeLogDict = [String:Any]()
                                timeLogDict[Auth.auth().currentUser!.uid] = ["studentOnLocation":"false","studentConfirmsArrival":"false","posterConfirmsArrival":"false","studentPressesStart":"false","studentPressesFinish":"false","posterRecievesBill":"false","posterConfirmsBill":"false","posterIsCharged":"false","studentIsPayed":"false"] as! [String:Any]
                                Database.database().reference().child("jobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                
                                Database.database().reference().child("jobPosters").child(self.self.job1.posterID!).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                            
                            
                        }
                            if containsCurrentListings == false{
                                var uploadData = [String: [String:Any]]()
                                
                                var tempWorkers = [String]()
                                tempWorkers.append(Auth.auth().currentUser!.uid)
                                self.uploadJob["workers"] = tempWorkers
                                self.uploadJob["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                self.uploadJob["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                var acceptCount = self.uploadJob["acceptedCount"] as! Int
                                acceptCount = acceptCount + 1
                                self.uploadJob["acceptedCount"] = acceptCount
                                uploadData[self.jobID] = self.uploadJob
                                var uploadDict = [String:Any]()
                                uploadDict["currentListings"] = uploadData
                                
                                Database.database().reference().child("jobPosters").child(self.posterID).updateChildValues(uploadDict)
                                var timeLogDict = [String:Any]()
                                timeLogDict[Auth.auth().currentUser!.uid] = ["studentOnLocation":"false","studentConfirmsArrival":"false","posterConfirmsArrival":"false","studentPressesStart":"false","studentPressesFinish":"false","posterRecievesBill":"false","posterConfirmsBill":"false","posterIsCharged":"false","studentIsPayed":"false"] as! [String:Any]
                                Database.database().reference().child("jobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                
                                Database.database().reference().child("jobPosters").child(self.self.job1.posterID!).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                            
                            
                            }
                            
                            Database.database().reference().child("students").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                    var containsJobs = false
                                    var upcomingArray = [String: [String:Any]]()
                                    var incrementAcceptedCount = false
                                    for snap in snapshots {
                                        
                                        if snap.key == "upcomingJobs"{
                                            upcomingArray = snap.value as! [String: [String:Any]]
                                            
                                            var tempWorkers = [String]()
                                            tempWorkers.append(Auth.auth().currentUser!.uid)
                                            self.uploadJob["workers"] = tempWorkers
                                            
                                            self.uploadJob["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                            self.uploadJob["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                            if incrementAcceptedCount == false {
                                            var acceptCount = self.uploadJob["acceptedCount"] as! Int
                                            acceptCount = acceptCount + 1
                                            self.uploadJob["acceptedCount"] = acceptCount
                                                incrementAcceptedCount = true
                                            }
                                            upcomingArray[self.jobID] = self.uploadJob
                                            containsJobs = true
                                        }
                                        var uploadDict2 = [String:Any]()
                                        if containsJobs == false{
                                            
                                            
                                            var tempWorkers = [String]()
                                            tempWorkers.append(Auth.auth().currentUser!.uid)
                                            self.uploadJob["workers"] = tempWorkers
                                            var acceptCount = self.uploadJob["acceptedCount"] as! Int
                                            acceptCount = acceptCount + 1
                                            self.uploadJob["acceptedCount"] = acceptCount
                                            self.uploadJob["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                            self.uploadJob["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                            upcomingArray[self.jobID] = self.uploadJob
                                            
                                            uploadDict2["upcomingJobs"] = upcomingArray
                                        } else {
                                            uploadDict2["upcomingJobs"] = upcomingArray
                                        }
                                        Database.database().reference().child("students").child((Auth.auth().currentUser?.uid)!).updateChildValues(uploadDict2)
                                        var timeLogDict = [String:Any]()
                                        timeLogDict[Auth.auth().currentUser!.uid] = ["studentOnLocation":"false","studentConfirmsArrival":"false","posterConfirmsArrival":"false","studentPressesStart":"false","studentPressesFinish":"false","posterRecievesBill":"false","posterConfirmsBill":"false","posterIsCharged":"false","studentIsPayed":"false"] as! [String:Any]
                                        Database.database().reference().child("jobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                        
                                        Database.database().reference().child("jobPosters").child(self.self.job1.posterID!).child("upcomingJobs").child(self.job1.jobID!).child("timeLogs").updateChildValues(timeLogDict)
                                    }
                                    
                                }
                                Database.database().reference().child("jobs").child(self.jobID).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                                        var containsWorkers = false
                                        var workersArray = [String]()
                                        for snap in snapshots {
                                            
                                            if snap.key == "workers"{
                                                containsWorkers = true
                                                workersArray = snap.value as! [String]
                                                workersArray.append((Auth.auth().currentUser!.uid))
                                                var uploadDict = [String:Any]()
                                                uploadDict["workers"] = workersArray
                                                uploadDict["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                                uploadDict["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                                Database.database().reference().child("jobs").child(self.jobID).updateChildValues(uploadDict)
                                            } else if snap.key == "acceptedCount" {
                                                var tempInt = snap.value as! Int
                                                tempInt = tempInt + 1
                                                var uploadDict = [String:Any]()
                                                uploadDict["acceptedCount"] = tempInt
                                                uploadDict["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                                uploadDict["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                                if tempInt == self.job1.workers?.count {
                                                    self.readyToCharge = true
                                                } else {
                                                    self.readyToCharge = false
                                                }
                                                Database.database().reference().child("jobs").child(self.jobID).updateChildValues(uploadDict)
                                                
                                            }
                                        }
                                        
                                        if containsWorkers == false{
                                            var uploadDict = [String:Any]()
                                            
                                            uploadDict["workers"] = ([(Auth.auth().currentUser!.uid)] as Any)
                                            uploadDict["date"] = [self.datesArray[self.availDatesPicker.selectedRow(inComponent: 0)]]
                                            uploadDict["startTime"] = [[self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]]]
                                            Database.database().reference().child("jobs").child(self.jobID).updateChildValues(uploadDict)
                                        }
                                    }
                                    //self.applySuccessView.isHidden = true
                                    //let date = self.job1.date!
                                    
                                   // var timeComp = ((self.timesForCurDateArray[self.availTimesPicker.selectedRow(inComponent: 0)]) as! String).components(separatedBy: ":")
                                    // .componentsSeparatedByString(":")
                                    //let timeHours = timeComp[0].first!
                                    //print("timeHours: \(timeHours)")
                                    //let timeHoursInt = (timeHours as! NSString).integerValue
                                    /*let trigger1Time = timeHoursInt + (Int(self.job1.jobDuration!)!)
                                    var triggerTime = Int()
                                    if trigger1Time > 12{
                                        triggerTime = trigger1Time % 12
                                    } else {
                                        triggerTime = trigger1Time
                                    }
                                    print("modTime:\(triggerTime)")
                                    let triggerTimeString = "\(String(describing: triggerTime)):\(timeComp[1].first!)"
                                    print("triggerTime: \(triggerTimeString)")
                                    let dateToFormat = "\(date) \(triggerTimeString)"
                                    print("dataToFormat: \(dateToFormat)")
                                    
                                    
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "MMMM-dd-yyyy h:mm a"
                                    let triggerDate = dateFormatter.date(from: dateToFormat)
                                    print("tDate: \(triggerDate!)")
                                    
                                    let trigger2TimeString = "\(self.job1.date!) \(self.job1.startTime!)"
                                    
                                    let trigger2Date = dateFormatter.date(from: trigger2TimeString)
                                    print("t2Date: \(trigger2Date!)")
                                    
                                    if self.readyToCharge == true{
                                    let timer2 = Timer(fireAt: trigger2Date!, interval: 0, target: self, selector: #selector(self.countDownDuration), userInfo: nil, repeats: false)
                                    RunLoop.main.add(timer2, forMode: RunLoopMode.commonModes)
                                    
                                    //MyAPIClient.sharedClient.completeCharge(amount: 10,
                                    // poster: self.posterID)
                                    
                                   // let timer = Timer(fireAt: triggerDate!, interval: 0, target: self, selector: #selector(self.chargePoster), userInfo: nil, repeats: false)
                                    //RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                                    }
                                    
                                    self.selectorJob = self.job1
                                    let trigger2Time = "\(self.job1.date!) \(self.job1.startTime!)"
                                    
                                    
                                    let dateFormatter3 = DateFormatter()
                                    dateFormatter3.dateFormat = "MMMM-dd-yyyy hh:mm a"
                                    let trigger = dateFormatter3.date(from: trigger2Time)
                                    
                                    let date3 = Date(timeInterval: -12, since: trigger!)
                                    let date4 = Date(timeInterval: -3, since: trigger!)
                                    let date5 = Date(timeInterval: -0.5, since: trigger!)
                                    
                                    let timer3 = Timer(fireAt: date3, interval: 0, target: self, selector: #selector(self.twelveHoursOut), userInfo: nil, repeats: false)
                                    RunLoop.main.add(timer3, forMode: RunLoopMode.commonModes)
                                    
                                    let timer4 = Timer(fireAt: date4, interval: 0, target: self, selector: #selector(self.threeHoursOut), userInfo: nil, repeats: false)
                                    RunLoop.main.add(timer4, forMode: RunLoopMode.commonModes)
                                    let timer5 = Timer(fireAt: date5, interval: 0, target: self, selector: #selector(self.threeHoursOut), userInfo: nil, repeats: false)
                                    RunLoop.main.add(timer5, forMode: RunLoopMode.commonModes)*/
                                   
                                    // 2
                                    
                                    
                                    var testCoord = CLLocationCoordinate2D(latitude: Double(self.job1.jobLat!)!, longitude: Double(self.job1.jobLong!)!)
                               
                                    if self.job1.category1 == "Moving(Home-To-Home)"{
                                       /*self.addGeotificationViewController(didAddCoordinate: testCoord, radius: 100.0, identifier: self.job1.pickupLocation!, note: self.job1.jobID!, eventType: EventType.onEntry)*/
                                    } else {
                                        self.addGeotificationViewController(didAddCoordinate: testCoord, radius: 100.0, identifier: self.job1.posterID!, note: self.job1.jobID!, eventType: EventType.onEntry, studentID: Auth.auth().currentUser!.uid)
                                       
                                    }
                                    // 3
                                    print("geoShit: \(self.locationManager.monitoredRegions)")
                                    self.loadAllGeotifications()
                                    
                                  
                                    self.performSegue(withIdentifier: "JobAcceptedBackToProfile", sender: self)
                                    
                                })
                                
                                
                            })
                        }
                    })
                }
                
            }
        })
    }
    
    var selectorJob = JobPost()
    func thirtyMinOut(){
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).updateChildValues(["thirtyMinToStart": selectorJob.posterID as! String])
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("thirtyMinToStart").removeValue()
    }
    func threeHoursOut(){
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).updateChildValues(["threeHoursToStart": selectorJob.posterID as! String])
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("threeHoursToStart").removeValue()
    }
    
    func twelveHoursOut(){
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).updateChildValues(["twelveHoursToStart": selectorJob.posterID as! String])
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("twelveHoursToStart").removeValue()
    }
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var posterName: UILabel!
    var job = [String: Any]()
   // @IBOutlet weak var durationLabel: UILabel!
    //@IBOutlet weak var detailsTextView: UITextView!
    var jobID = String()
    var studentsWhoHaveAppliedForJobArray = [String]()
    var studentHasAlreadyApplied = false
    var categoryType = String()
    var posterID = String()
    var workerInJobAlready = false
    var chargeAmount = String()
    override func viewWillAppear(_ animated: Bool) {
        
       
        
        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL

        posterImage.layer.cornerRadius = posterImage.frame.width/2
        posterImage.clipsToBounds = true
        //shadowView.dropShadow()
 Database.database().reference().child("jobPosters").child(self.posterID).observeSingleEvent(of: .value, with : {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    var tempArray = [String]()
                    if snap.key == "address"{
                        //self.addressLabel.text = (snap.value as! [String]).first
                    } else if snap.key == "pic"{
                        if let messageImageUrl = URL(string: snap.value as! String) {
                            
                            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                                
                                self.posterImage.image = UIImage(data: imageData as Data)
                                
                            }
                        }
                        
                    } else if snap.key == "name"{
                        self.posterName.text = snap.value as? String
                    } else if snap.key == "responses"{
                        let tempDict = snap.value as! [String: Any]
                        
                        for (key, val) in tempDict{
                            if key == self.jobID{
                                tempArray = val as! [String]
                            }
                        }
                        
                    }
                    if tempArray.isEmpty{
                        self.studentHasAlreadyApplied = false
                    } else if tempArray.contains((Auth.auth().currentUser?.uid)!) == false{
                        self.studentHasAlreadyApplied = false
                    } else {
                        self.studentHasAlreadyApplied = true
                    }
                    
                }
            }
            
        })
        
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if detailsLabel.text == nil || detailsLabel.text == "" || detailsLabel.text == "Info: " || detailsLabel.text == "Info:"{
            detailsLabel.text == "Job Info"
        }
        self.locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        datesArray = self.job1.date!
        timesArray = self.job1.startTime as! [[String]]
        timesForCurDateArray = timesArray.first!
        availDatesPicker.delegate = self
        availDatesPicker.dataSource = self
        availTimesPicker.delegate = self
        availTimesPicker.dataSource = self
        availDatesToPick.text = "\(datesArray.count) Available Dates"
        dateCollect.delegate = self
        dateCollect.dataSource = self
        
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("memoryWarning")
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if let vc = segue.destination as? JobPostViewController{
                vc.categoryType = self.categoryType
            }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        print("didCreatePaymentResult: \(self.posterID)")
       /* MyAPIClient.sharedClient.completeCharge(paymentResult,
                                                amount: (self.paymentContext?.paymentAmount)!,
                                                shippingAddress: nil,
                                                shippingMethod: nil,
                                                poster: self.posterID,
                                                completion: completion)*/
    }
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    print("paymentInProgress")
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                   // self.buyButton?.alpha = 0
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                    //self.buyButton?.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print("finishedWith")
        self.paymentInProgress = false
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
            print("error")
        case .success:
            print("success")
            title = "Success"
            message = "You bought a \(self.product)!"
        case .userCancellation:
            print("cancelled")
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        //self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        //self.paymentRow.loading = paymentContext.loading
        print("paymentContextDidChange")
       /* if let paymentMethod = paymentContext.selectedPaymentMethod {
            //self.paymentRow.detail = paymentMethod.label
        }
        else {
            //self.paymentRow.detail = "Select Payment"
        }*/
        /*if let shippingMethod = paymentContext.selectedShippingMethod {
         self.shippingRow.detail = shippingMethod.label
         }
         else {
         self.shippingRow.detail = "Enter \(self.shippingString) Info"
         }*/
        //self.totalRow.detail = self.numberFormatter.string(from: NSNumber(value: Float(self.paymentContext.paymentAmount)/100))!
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("paymentContextFailedToLoad")
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext?.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"
        let upsWorldwide = PKShippingMethod()
        upsWorldwide.amount = 10.99
        upsWorldwide.label = "UPS Worldwide Express"
        upsWorldwide.detail = "Arrives in 1-3 days"
        upsWorldwide.identifier = "ups_worldwide"
        let fedEx = PKShippingMethod()
        fedEx.amount = 5.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if address.country == nil || address.country == "US" {
                completion(.valid, nil, [upsGround, fedEx], fedEx)
            }
            else if address.country == "AQ" {
                let error = NSError(domain: "ShippingError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Invalid Shipping Address",
                                                                                   NSLocalizedFailureReasonErrorKey: "We can't ship to this country."])
                completion(.invalid, error, nil, nil)
            }
            else {
                fedEx.amount = 20.99
                completion(.valid, nil, [upsWorldwide, fedEx], fedEx)
            }
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == availTimesPicker{
            return timesForCurDateArray.count
            
        } else {
            return datesArray.count
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == availTimesPicker{
            return timesArray[availDatesPicker.selectedRow(inComponent: 0)][row]
            
        } else {
            return datesArray[row]
        }
        
        
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == availDatesPicker{
            self.timesForCurDateArray = timesArray[availDatesPicker.selectedRow(inComponent: 0)]
            availTimesPicker.reloadComponent(0)
            availTimesToPickLabel.text = "\(timesForCurDateArray.count) Available Times for Date"
            availTimesPicker.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return datesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        cell.dateLabel.text = datesArray[indexPath.row]
        
        
        
        return cell
    }
    
    func region(withGeotification geotification: Geotification) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        // 2
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    func startMonitoring(geotification: Geotification) {
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        // 3
        let region = self.region(withGeotification: geotification)
        // 4
        locationManager.startMonitoring(for: region)
    }
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    func addGeotificationViewController(didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType, studentID: String) {
        // controller.dismiss(animated: true, completion: nil)
        // 1
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType, studentID: Auth.auth().currentUser!.uid)
        add(geotification: geotification)
        // 2
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
    func updateGeotificationsCount() {
        title = "Geotifications (\(geotifications.count))"
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)  // Add this line
    }
    
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        geotifications = []
        guard let savedItems =   UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) else { return }
        for savedItem in savedItems {
            guard let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? Geotification else { continue }
            add(geotification: geotification)
        }
    }
    
    func saveAllGeotifications() {
        var items: [Data] = []
        for geotification in geotifications {
            let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
            items.append(item)
        }
        UserDefaults.standard.set(items, forKey: PreferencesKeys.savedItems)
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(geotification: Geotification) {
        geotifications.append(geotification)
        //mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func remove(geotification: Geotification) {
        if let indexInArray = geotifications.index(of: geotification) {
            geotifications.remove(at: indexInArray)
        }
        // mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    
    
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification) {
        // mapView?.add(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        /*guard let overlays = mapView?.overlays else { return }
         for overlay in overlays {
         guard let circleOverlay = overlay as? MKCircle else { continue }
         let coord = circleOverlay.coordinate
         if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
         //mapView?.remove(circleOverlay)
         break
         }
         }*/
    }
    
    // MARK: Other mapview functions
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        // mapView.zoomToUserLocation()
    }


    

}

extension UIView{
    
    func dropShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: -2, height: 2)
        self.layer.shadowRadius = 325
        self.layer.cornerRadius = self.frame.width/2
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
}
extension SingleJobPostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //mapView.showsUserLocation = (status == .authorizedAlways)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}

