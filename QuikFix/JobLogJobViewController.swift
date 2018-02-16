//
//  JobLogJobViewController.swift
//  QuikFix
//
//  Created by Thomas Threlkeld on 10/17/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Stripe
import CoreLocation

class JobLogStudentCell: UICollectionViewCell{
    @IBOutlet weak var studentPic: UIImageView!
    @IBOutlet weak var studentLabel: UILabel!
    
}

class JobLogJobViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, STPAddCardViewControllerDelegate, STPShippingAddressViewControllerDelegate, STPPaymentCardTextFieldDelegate, STPPaymentMethodsViewControllerDelegate, STPPaymentContextDelegate {
    
    @IBOutlet weak var studentPosterCollectSizeView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var jobHasStartedView: UIView!
    
    func studentConfirmsArrivalDatabaseUpload(){
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM-dd-yyyy h:mm a"
        let now = dateFormatter.string(from: Date())
        Database.database().reference().child("jobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).updateChildValues(["studentConfirmsArrival": now])
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).updateChildValues(["studentConfirmsArrival": now])
        
        Database.database().reference().child("jobPosters").child(job.posterID!).child("upcomingJobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).updateChildValues(["studentConfirmsArrival": now])
    }
    var counter = 0.0
    var timer = Timer()
    func UpdateTimer() {
        counter = counter + 0.1
        timerLabel.text = String(format: "%.1f", counter)
    }
    func studentStartsJobDatabaseUpload(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM-dd-yyyy h:mm a"
        let now = dateFormatter.string(from: Date())
       self.startTimerTime = Date()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        
        jobHasStartedView.isHidden = false
        Database.database().reference().child("jobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).updateChildValues(["studentPressesStart": now])
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).updateChildValues(["studentPressesStart": now])
        
        Database.database().reference().child("jobPosters").child(job.posterID!).child("upcomingJobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).updateChildValues(["studentPressesStart": now])
        
        
       
    }
    func finish(){
        timer.invalidate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM-dd-yyyy h:mm a"
        let now = dateFormatter.string(from: Date())
        print("startTimerTime: \(startTimerTime)")
        let elapsed = Date().timeIntervalSince(startTimerTime)
        print("timeElapsed: \(elapsed)")
        //var temp = (elapsed/10) * 60
        let min = elapsed/60
        let hours = min/60
        let payoutAmountPennies = ((hours * 15) * 100)
        print("payoutAmountPennies: \(payoutAmountPennies)")
        var sendJob = [String:Any]()
        sendJob["posterID"] = self.job.posterID
        sendJob["jobID"] = self.job.jobID!
        
        print("localSendJob: \(sendJob), selfSendJob: \(self.sendJob), self.job: \(self.job)")
        
        
        Database.database().reference().child("jobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).updateChildValues(["studentPressesFinish": now])
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).child("upcomingJobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).updateChildValues(["studentPressesFinish": now])
        
        Database.database().reference().child("jobPosters").child(job.posterID!).child("upcomingJobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).updateChildValues(["studentPressesFinish": now])
        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                var accountID = String()
                for snap in snapshots{
                    if snap.key == "stripeToken"{
                        accountID = snap.value as! String
                        break
                    }
                }
                print("acountID: \(accountID)")
                MyAPIClient.sharedClient.completeCharge(amount: Int(payoutAmountPennies), poster: self.job.posterID!, job: sendJob, senderScreen: "normCharge", jobDict: self.sendJob)
                //----charge poster****
                MyAPIClient.sharedClient.callPayoutStudent(accountID: accountID, amount: Int(payoutAmountPennies)){ responseObject, error in
                    // use responseObject and error here
                    print("responseObject = \(responseObject!); error = \(String(describing: error))")
                    
                    
                }
            }
        })
    }
    func studentFinishesJobDatabaseUpload(){
        
        let alert = UIAlertController(title: "Confirm Finish Job", message: "Are you ready to end this job?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: { action in
            self.finish()
        }))
        self.present(alert, animated: true, completion: nil)
        
       
    }
    
    @IBOutlet weak var inProgressView: UIView!
    var startTimerTime = Date()
    @IBOutlet weak var ArrivalOrCompletionButton: UIButton!
    @IBAction func confirmArrivalOrCompletionButtonPressed(_ sender: Any) {
        if self.senderScreen == "student"{
            if ArrivalOrCompletionButton.titleLabel!.text == "Finish Job" {
                if studentOnsite == true {
                    ArrivalOrCompletionButton.isEnabled = false
                    ArrivalOrCompletionButton.isUserInteractionEnabled = false
                    studentFinishesJobDatabaseUpload()
                } else {
                    let alert = UIAlertController(title: "Not on Location", message: "You must be at the job location to Finish the job.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else if ArrivalOrCompletionButton.titleLabel!.text == "Start Job"{
                if studentOnsite == true {
                    if studentConfirmLocation == true {
                      if posterConfirmLocation == true {
                       
                        //startButton.isEnabled = false
                        studentPressedStart = true
                        studentStartsJobDatabaseUpload()
                        ArrivalOrCompletionButton.setTitle("Finish Job", for: .normal)
                        ArrivalOrCompletionButton.isEnabled = true
                      } else {
                            let alert = UIAlertController(title: "Poster has not confirmed Arrival", message: "Awaiting the job poster to press button confirming your arrival at the job location. Do not start working until the poster confirms your arrival and you press start.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "You are off location.", message: "Return to job location to start job", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else if ArrivalOrCompletionButton.titleLabel!.text == "Confirm Arrival at Job Site" {
                if studentOnsite == true {
                    studentConfirmsArrivalDatabaseUpload()
                    ArrivalOrCompletionButton.setTitle("Start Job", for: .normal)
                    self.step2ImageView.image = UIImage(named: self.checkImage)
                    ArrivalOrCompletionButton.isEnabled = true
                } else {
                    let alert = UIAlertController(title: "Not on Location", message: "You must be at the job location to confirm your arrival and start the job.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            //Poster
            if ArrivalOrCompletionButton.titleLabel!.text == "Confirm Students Arrival" && studentOnsite == true {
                ArrivalOrCompletionButton.setTitle("Job in Progress", for: .normal)
                ArrivalOrCompletionButton.isEnabled = false
                
            } else if ArrivalOrCompletionButton.titleLabel!.text == "Confirm Students Arrival" && studentOnsite == false {
                let alert = UIAlertController(title: "Student Not on Location", message: "The student must be at the job location to confirm arrival and start the job.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func handleAddPaymentMethodButtonTapped() {
        // Setup add card view controller
        print("handleAddPayment")
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: STPAddCardViewControllerDelegate
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    
    func submitTokenToBackend(token: STPToken, completion: @escaping STPErrorBlock, completionHandler: (Error) -> ()){
        print("submitTokenToBackEnd")
        var tempDict = [String:Any]()
        tempDict["stripeToken"] = token.tokenId
        Database.database().reference().child("jobPosters").child((Auth.auth().currentUser?.uid)!).updateChildValues(tempDict)
        self.poster.email = "tthrelk@gmail.com"
        self.poster.name = "Thomas"
        
       // MyAPIClient.sharedClient.saveCard(token, email: self.poster.email!, name: self.poster.name!)
         dismiss(animated: true)
        //return
        //tempDict["paymentAmount"] = job.payment
        //tempDict["description"] = job.description
        
    }
    
    var poster = JobPoster()
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        print("begin save card")
        submitTokenToBackend(token: token, completion: completion, completionHandler: { (error: Error?) in
            if let error = error {
                // Show error in add card view controller
                print("error: \(error.localizedDescription)")
                completion(error)
            }
            else {
                print("Sup")
                completion(nil)
                
                
                // Dismiss add card view controller
                dismiss(animated: true)
            }
        })
    }
    var buyButton = UIButton()
    let paymentCardTextField = STPPaymentCardTextField()
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        // Toggle buy button state
        buyButton.isEnabled = textField.isValid
        buyButton.isHidden = false
    }
    
    func handlePaymentMethodsButtonTapped() {
        // Setup customer context
        print("handlemethodstouched")
        let customerContext = STPCustomerContext(keyProvider: STPAPIClient.shared as! STPEphemeralKeyProvider)
        
        
        
        
        // Setup payment methods view controller
        let paymentMethodsViewController = STPPaymentMethodsViewController(configuration: STPPaymentConfiguration.shared(), theme: STPTheme.default(), customerContext: customerContext, delegate: self)
        
        // Present payment methods view controller
        let navigationController = UINavigationController(rootViewController: paymentMethodsViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: STPPaymentMethodsViewControllerDelegate
    
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentMethodsViewController, didFailToLoadWithError error: Error) {
        // Dismiss payment methods view controller
        dismiss(animated: true)
        
        // Present error to user...
    }
    
    func paymentMethodsViewControllerDidCancel(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        // Dismiss payment methods view controller
        dismiss(animated: true)
    }
    
    func paymentMethodsViewControllerDidFinish(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        // Dismiss payment methods view controller
        dismiss(animated: true)
    }
    
    var selectedPaymentMethod: STPPaymentMethod?
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentMethodsViewController, didSelect paymentMethod: STPPaymentMethod) {
        // Save selected payment method
        selectedPaymentMethod = paymentMethod
    }
    
    func handleShippingButtonTapped() {
        // Setup shipping address view controller
        /*let shippingAddressViewController = STPShippingAddressViewController()
        shippingAddressViewController.delegate = self
        
        // Present shipping address view controller
        let navigationController = UINavigationController(rootViewController: shippingAddressViewController)
        present(navigationController, animated: true)*/
    }
    
    // MARK: STPShippingAddressViewControllerDelegate
    
    func shippingAddressViewControllerDidCancel(_ addressViewController: STPShippingAddressViewController) {
        // Dismiss shipping address view controller
        dismiss(animated: true)
    }
    
    func shippingAddressViewController(_ addressViewController: STPShippingAddressViewController, didEnter address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        let upsGroundShippingMethod = PKShippingMethod()
        upsGroundShippingMethod.amount = 0.00
        upsGroundShippingMethod.label = "UPS Ground"
        upsGroundShippingMethod.detail = "Arrives in 3-5 days"
        upsGroundShippingMethod.identifier = "ups_ground"
        
        let fedExShippingMethod = PKShippingMethod()
        fedExShippingMethod.amount = 5.99
        fedExShippingMethod.label = "FedEx"
        fedExShippingMethod.detail = "Arrives tomorrow"
        fedExShippingMethod.identifier = "fedex"
        
        if address.country == "US" {
            let availableShippingMethods = [upsGroundShippingMethod, fedExShippingMethod]
            let selectedShippingMethod = upsGroundShippingMethod
            
            completion(.valid, nil, availableShippingMethods, selectedShippingMethod)
        }
        else {
            completion(.invalid, nil, nil, nil)
        }
    }
    var selectedAddress = STPAddress()
    var selectedShippingMethod = PKShippingMethod()
    
    func shippingAddressViewController(_ addressViewController: STPShippingAddressViewController, didFinishWith address: STPAddress, shippingMethod method: PKShippingMethod?) {
        // Save selected address and shipping method
        selectedAddress = address
        selectedShippingMethod = method!
        
        // Dismiss shipping address view controller
        dismiss(animated: true)
    }
    
    @IBAction func addSubtractTimePressed(_ sender: Any) {
    }
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var detailsButton: UIButton!
    
    let qfGreen = UIColor(colorLiteralRed: 49/255, green: 74/255, blue: 82/255, alpha: 1.0)
    
    var inProgress = Bool()
    @IBAction func detailsButtonPressed(_ sender: Any) {
        if detailsButton.backgroundColor == UIColor.white {
            detailsButton.backgroundColor = UIColor.clear
            detailsButton.setTitleColor(qfGreen, for: .normal)
            groupChatButton.setTitleColor(qfGreen, for: .normal)
            groupChatButton.backgroundColor = UIColor.white
            if inProgress == true {
                inProgressView.isHidden = false
                inProgressUpperLine.isHidden = false
            } else {
                inProgressView.isHidden = true
                inProgressUpperLine.isHidden = true
            }
            messageContainer.isHidden = true
            
        } else {
            /*detailsButton.setTitleColor(UIColor.lightGray, for: .normal)*/
        }
        
        
    }
    
    @IBOutlet weak var lowerButtonSep3: UIView!
    @IBOutlet weak var lowerButtonSep2: UIView!
    @IBOutlet weak var lowerButtonSep1: UIView!
    @IBAction func showDirectionsPressed(_ sender: Any) {
        performSegue(withIdentifier: "ShowMap", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "JobLogJobToJobLog", sender: self)
    }
    @IBOutlet weak var jobCompletedButton: UIButton!
    
    @IBOutlet weak var workersCollect: UICollectionView!
    @IBOutlet weak var jobCatLabel: UILabel!
    @IBOutlet weak var studentWorkersCollect: UICollectionView!
    @IBOutlet weak var numberOfStudentsLabel: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageContainer: UIView!
    
    @IBAction func groupChatPressed(_ sender: Any) {
       // performSegue(withIdentifier: "JobLogJobToChat", sender: self)
        if groupChatButton.backgroundColor == UIColor.white {
            groupChatButton.backgroundColor = UIColor.clear
            groupChatButton.setTitleColor(.lightGray, for: .normal)
            detailsButton.setTitleColor(UIColor.lightGray, for: .normal)
            detailsButton.backgroundColor = UIColor.white
            //performSegue(withIdentifier: "", sender: <#T##Any?#>)
            inProgressView.isHidden = true
            inProgressUpperLine.isHidden = true
            messageContainer.isHidden = false
            
            
            
            
        } else {
            /*detailsButton.setTitleColor(UIColor.lightGray, for: .normal)*/
        }
        
        
        
    }
    var stripeToken = String()
    let settingsVC = SettingsViewController()
    @IBOutlet weak var groupChatButton: UIButton!
    @IBOutlet weak var homeToHomeView: UIView!
    @IBOutlet weak var pickupLabel: UILabel!
    @IBOutlet weak var dropoffLabel: UILabel!
    
    func confirmCancel(){
        var sendJob = [String:Any]()
        sendJob["posterID"] = Auth.auth().currentUser!.uid
        sendJob["jobID"] = self.job.jobID!
        
        print("charge the poster for cancel")
        let tempCharge = 25 * 100
        print("charge in cents: \(tempCharge)")
        MyAPIClient.sharedClient.completeCharge(amount: Int(tempCharge), poster: Auth.auth().currentUser!.uid, job: sendJob, senderScreen: "cancelJob", jobDict: self.sendJob)
        DispatchQueue.main.async{
            self.performSegue(withIdentifier: "cancelJobToPosterProfile", sender: self)
        }
    }
    
    @IBAction func dropoffPressed(_ sender: Any) {
        
    }
    @IBOutlet weak var dropoffButton: UIButton!
    
    @IBOutlet weak var pickupButton: UIButton!
    @IBAction func pickupPressed(_ sender: Any) {
    }
    @IBOutlet weak var locNameLabel: UILabel!
    
    
    var removeAcceptedCount = Int()
    var workers2 = [String]()
    func confirmCancel2(){
        var sendJob = [String:Any]()
        sendJob["jobID"] = self.job.jobID!
        sendJob["posterID"] = self.job.posterID!
        var now = Date()
        
        let date = self.job.date!
        
        var timeComp = ((self.job.startTime! as! [String]).first!.components(separatedBy: ":"))// .componentsSeparatedByString(":")
        let timeHours = timeComp[0]
        print("timeHours: \(timeHours)")
        let timeHoursInt = (timeHours as NSString).integerValue
        let trigger1Time = timeHoursInt
        var triggerTime = Int()
        if trigger1Time > 12{
            triggerTime = trigger1Time % 12
        } else {
            triggerTime = trigger1Time
        }
        print("modTime:\(triggerTime)")
        let triggerTimeString = "\(String(describing: triggerTime)):\(timeComp[1])"
        print("triggerTime: \(triggerTimeString)")
        let dateToFormat = "\(date) \(triggerTimeString)"
        print("dataToFormat: \(dateToFormat)")
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM-dd-yyyy h:mm a"
        let triggerDate = dateFormatter.date(from: dateToFormat)
        
        var nowString = dateFormatter.string(from: now)
        var nowDate = dateFormatter.date(from: nowString)
        var minutesUntil = nowDate?.minutes(from: triggerDate!)
        print("minutesUntilJob: \(minutesUntil)")
        
        
        
        if minutesUntil! <= 90 {
            print("charge the student for cancel")
            let tempCharge = 5 * 100
            print("charge in cents: \(tempCharge)")
            Database.database().reference().child("students").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        var snapDict = snap.value as! [String:Any]
                        let studentLat = (snapDict["location"] as! [String:Any])["lat"] as! CLLocationDegrees
                        let studentLong = (snapDict["location"] as! [String:Any])["long"] as! CLLocationDegrees
                        let studentLoc = CLLocation(latitude: studentLat, longitude: studentLong)
                        
                        let exp = snapDict["experience"] as! [String]
                        print("studentEXp: \(exp)")
                        if exp.contains(self.job.category1!){
                            print(snap.key)
                           // print("studLoc: \(studentLoc)")
                            //print("jobLoc: \(self.jobCoord)")
                            var coords = CLLocation(latitude: Double(self.job.jobLat!)!, longitude: Double(self.job.jobLong!)!)
                            if studentLoc.distance(from: coords) <= 90000{
                                print("inRange")
                                if snapDict["nearbyJobs"] == nil {
                                    
                                    print("it was nil")
                                    Database.database().reference().child("students").child(snapDict["studentID"] as! String).updateChildValues(["nearbyJobs": [self.job.jobID]])
                                } else {
                                    var tempArray = snapDict["nearbyJobs"] as! [String]
                                    tempArray.append(self.job.jobID!)
                                    Database.database().reference().child("students").child(snapDict["studentID"] as! String).updateChildValues(["nearbyJobs": tempArray])
                                }
                                
                                
                            }
                        }
                    }
                   
            DispatchQueue.main.async{
                MyAPIClient.sharedClient.completeCharge(amount: Int(tempCharge), poster: (Auth.auth().currentUser?.uid)!, job: sendJob, senderScreen: "cancelJobStudent", jobDict: self.sendJob)
                self.performSegue(withIdentifier: "cancelJobToStudentProfile", sender: self)
            }
                }
            })
        } else {
            Database.database().reference().child("students").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        var snapDict = snap.value as! [String:Any]
                        let studentLat = (snapDict["location"] as! [String:Any])["lat"] as! CLLocationDegrees
                        let studentLong = (snapDict["location"] as! [String:Any])["long"] as! CLLocationDegrees
                        let studentLoc = CLLocation(latitude: studentLat, longitude: studentLong)
                        
                        let exp = snapDict["experience"] as! [String]
                        print("studentEXp: \(exp)")
                        if exp.contains(self.job.category1!){
                            print(snap.key)
                            // print("studLoc: \(studentLoc)")
                            //print("jobLoc: \(self.jobCoord)")
                            var coords = CLLocation(latitude: Double(self.job.jobLat!)!, longitude: Double(self.job.jobLong!)!)
                            if studentLoc.distance(from: coords) <= 90000{
                                print("inRange")
                                if snapDict["nearbyJobs"] == nil {
                                    
                                    print("it was nil")
                                    Database.database().reference().child("students").child(snapDict["studentID"] as! String).updateChildValues(["nearbyJobs": [self.job.jobID]])
                                } else {
                                    var tempArray = snapDict["nearbyJobs"] as! [String]
                                    tempArray.append(self.job.jobID!)
                                    Database.database().reference().child("students").child(snapDict["studentID"] as! String).updateChildValues(["nearbyJobs": tempArray])
                                }
                                
                                
                            }
                        }
                    }
                    Database.database().reference().child("jobs").child(self.job.jobID as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            for snap in snapshots {
                                if snap.key == "workers"{
                                    self.workers2 = snap.value as! [String]
                                }
                                if snap.key == "acceptedCount"{
                                    self.removeAcceptedCount = (snap.value as! Int) - 1
                                    
                                }
                            }
                            
                            self.workers.remove(at: self.workers2.index(of: Auth.auth().currentUser!.uid)!)
                            Database.database().reference().child("jobs").child(self.job.jobID!).updateChildValues(["acceptedCount": self.removeAcceptedCount, "workers": self.workers])
                        }
                        Database.database().reference().child("jobPosters").child(self.job.posterID!).updateChildValues(["studentCancelled": true])
                        Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            var uploadDataStudent = [String]()
                            
                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                
                                for snap in snapshots {
                                    if snap.key == "upcomingJobs"{
                                        
                                        uploadDataStudent = snap.value as! [String]
                                        uploadDataStudent.remove(at: uploadDataStudent.index(of: self.job.jobID!)!)
                                    }
                                }
                                Database.database().reference().child("students").child(Auth.auth().currentUser!.uid).updateChildValues(["upcomingJobs": uploadDataStudent])
                                DispatchQueue.main.async{
                                    self.performSegue(withIdentifier: "cancelJobToStudentProfile", sender: self)
                                }
                            }
                        })
                        
                    })
                    
                }
                
            })
            
        }
    }
    var sendJob = [String:Any]()
    
    //This is now the cancel job button
    @IBAction func jobCompletedPressed(_ sender: Any) {
        if self.senderScreen == "student"{
            print("cancelByStudent")
            let alert = UIAlertController(title: "Confirm Cancel", message: "You will be charged a cancellation fee of $5.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Confirm Cancel", style: UIAlertActionStyle.default, handler: { action in
                self.confirmCancel2()
            }))
            self.present(alert, animated: true, completion: nil)
            //
            
            
        } else {
            //cancel by poster charges poster $25 and credits the student $10
            let alert = UIAlertController(title: "Confirm Cancel", message: "You will be charged a cancellation fee of $25.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Confirm Cancel", style: UIAlertActionStyle.default, handler: { action in
                self.confirmCancel()
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    
    
    var senderScreen = String()
    var job = JobPost()
    var workers = [[String:Any]]()
    
    @IBOutlet weak var step3ImageView: UIImageView!
    @IBOutlet weak var step2ImageView: UIImageView!
    @IBOutlet weak var step1ImageView: UIImageView!
    // 1) To get started with this demo, first head to https://dashboard.stripe.com/account/apikeys
    // and copy your "Test Publishable Key" (it looks like pk_test_abcdef) into the line below.
    let stripePublishableKey = "pk_live_F3qPhd7gnfCP6HP2gi1LTX41"
    
    // 2) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend , click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    let backendBaseURL = "https://quikfixfinal.herokuapp.com"
    var studentOnsite = Bool()
    var studentConfirmLocation = Bool()
    var posterConfirmLocation = Bool()
    var studentPressedStart = Bool()
    
    func monitorStudentOnLocation(){
        Database.database().reference().child("jobs").child(job.jobID!).child("timeLogs").child(Auth.auth().currentUser!.uid).observe(.childChanged, with: { (snapshot) in
            let timeLogsTemp = snapshot.value
            //self.timeLogs = timeLogsTemp
        
            print("timeLogsChanged: \(timeLogsTemp), \(snapshot.value as! String)")
            if snapshot.key == "studentOnLocation"{
                if snapshot.value as! String != "false"{
                    self.step1ImageView.image = UIImage(named: self.checkImage)
                    
                    
                    self.ArrivalOrCompletionButton.isEnabled = true
                    self.studentOnsite = true
                } else {
                    self.studentOnsite = false
                    self.step1ImageView.image = UIImage(named: self.circleImage)
                }
            } else if snapshot.key == "studentConfirmsArrival"{
                print("scl")
                if snapshot.value as! String != "false"{
                self.studentConfirmLocation = true
                } else {
                    self.studentConfirmLocation = false
                }
            } else if snapshot.key == "posterConfirmsArrival"{
                print("pcl")
                if snapshot.value as! String != "false"{
                    self.posterConfirmLocation = true
                    self.step3ImageView.image = UIImage(named: self.checkImage)
                } else {
                    self.step3ImageView.image = UIImage(named: self.circleImage)
                    self.posterConfirmLocation = false
                }
            } else if snapshot.key == "studentPressesStart"{
                print("sps")
                if snapshot.value as! String != "false"{
                    self.studentPressedStart = true
                } else {
                    self.studentPressedStart = false
                }
            } else if snapshot.key == "studentPressesFinish"{
                print("sps")
                if snapshot.value as! String != "false"{
                    self.studentPressedFinish = true
                } else {
                    self.studentPressedFinish = false
                }
            }
                
            //do if statements to update button and progreess info
            //Determine if coordinate has changed
        })
    }
    var studentPressedFinish = Bool()
    @IBOutlet weak var addSubtractButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    let checkImage = "Tick_Mark-128"
    let circleImage = "017314-black-ink-grunge-stamp-textures-icon-symbols-shapes-shapes-circle-clear"
    var timeLogs = [String:Any]()
    @IBOutlet weak var posterLabel: UILabel!
    var sender = String()
    
    @IBOutlet weak var step3: UILabel!
    @IBOutlet weak var step2: UILabel!
    @IBOutlet weak var step1: UILabel!
    @IBOutlet weak var inProgressUpperLine: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        step1ImageView.image = UIImage(named: circleImage)
        step2ImageView.image = UIImage(named: circleImage)
        step3ImageView.image = UIImage(named: circleImage)
        if self.jobType == "jc" || self.jobType == "cl"{
            self.jobCompletedButton.isHidden = true
            self.addSubtractButton.isHidden = true
            lowerButtonSep1.isHidden = true
            lowerButtonSep2.isHidden = true
            lowerButtonSep3.isHidden = true
        } else {
            let today = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM-dd-yyyy"
            let dateString = dateFormatter.string(from: today)
            let formattedDate = dateFormatter.date(from: dateString)
            let triggerDate = dateFormatter.date(from: job.date?.first! as! String)
            print("fuqYeahhhhh")
            if formattedDate == triggerDate {
                print("fuqYeah")
                if self.senderScreen == "student"{
                    step1.text = "1: Arrive at Location"
                    step2.text = "2: Press Confirm Arrival"
                    step3.text = "3: Wait for Poster Confirmation"
                    ArrivalOrCompletionButton.setTitle("Confirm Arrival at Job Site", for: .normal)
                   
                        ArrivalOrCompletionButton.isEnabled = true
                } else {
                
                        ArrivalOrCompletionButton.isEnabled = true
                    ArrivalOrCompletionButton.isEnabled = true
                    step1.text = "1: Wait for Student to Arrive"
                    step2.text = "2: Press Confirm Arrival"
                    step3.text = "3: Job Complete"
                    ArrivalOrCompletionButton.setTitle("Confirm Students Arrival", for: .normal)
                }
                monitorStudentOnLocation()
                inProgress = true
                inProgressView.isHidden = false
                inProgressUpperLine.isHidden = false
                }
            //monitorStudentOnLocation()
            
        }
        if job.workers == nil {
            groupChatButton.isEnabled = false
        } else {
            groupChatButton.isEnabled = true
        }
        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL
        paymentCardTextField.delegate = self
        
        groupChatButton.layer.borderColor = UIColor.lightGray.cgColor
        groupChatButton.layer.borderWidth = 1
        
        detailsButton.layer.borderColor = UIColor.lightGray.cgColor
        detailsButton.layer.borderWidth = 1
        
        var attributedString = NSMutableAttributedString(string: "Job Poster: ")
        let attrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 20.0)]
        var tempString = NSMutableAttributedString(string: job.posterName!, attributes:attrs)
        attributedString.append(tempString)
        posterLabel.attributedText = attributedString
        
        
        if job.category1! == "Moving(Home-To-Home)"{
            self.homeToHomeView.isHidden = false
            pickupButton.setTitle(job.pickupLocation!, for: .normal)
            dropoffButton.setTitle(job.dropOffLocation!, for: .normal)
        } else {
            self.homeToHomeView.isHidden = true
           mapButton.setTitle(job.location!, for: .normal)
        }
        //locNameLabel.text = job.location!
        jobCatLabel.text = job.category1
        
        attributedString = NSMutableAttributedString(string: "Job Start Date: ")
        tempString = NSMutableAttributedString(string: job.date!.first!, attributes:attrs)
        attributedString.append(tempString)
        dateLabel.attributedText = attributedString
        
        attributedString = NSMutableAttributedString(string: "Job Start Time: ")
        tempString = NSMutableAttributedString(string: (self.job.startTime! as! [String]).first!, attributes:attrs)
        attributedString.append(tempString)
        timeLabel.attributedText = attributedString
        
        cellSelectedPic.layer.cornerRadius = cellSelectedPic.frame.width/2
        
        attributedString = NSMutableAttributedString(string: "Estimated Completion Time: ")
        //tempString = NSMutableAttributedString(string: "\(job.jobDuration!) hours", attributes:attrs)
        attributedString.append(tempString)
        durationLabel.attributedText = attributedString
        
        if job.additInfo == nil {
            
        } else {
        attributedString = NSMutableAttributedString(string: "Details: ")
        tempString = NSMutableAttributedString(string: job.additInfo!, attributes:attrs)
        attributedString.append(tempString)
        detailsLabel.attributedText = attributedString
        }
        
        
        if senderScreen == "student"{
            
            if job.tools?.count == 0{
                var tempPayString = job.payment!
                let chargeAmount = tempPayString.substring(from: 1)
                tempPayString = tempPayString.replacingOccurrences(of: "$", with: "")
                let tempPayDouble = ((Double(tempPayString)! * 0.6) / (job.workerCount as! Double))
                tempPayString = "$\(tempPayDouble)/hour"
                
                attributedString = NSMutableAttributedString(string: "Rate: ")
                tempString = NSMutableAttributedString(string: tempPayString, attributes:attrs)
                attributedString.append(tempString)
                totalCostLabel.attributedText = attributedString
                
                
            } else {
                var tempPayString = job.payment!
                let chargeAmount = tempPayString.substring(from: 1)
                tempPayString = tempPayString.replacingOccurrences(of: "$", with: "")
                let postToolFeeRemovalDouble = (Double(tempPayString)! - 5.0)
                let tempPayDouble = ((postToolFeeRemovalDouble * 0.6) / (Double((job.workers?.count)!)))
                tempPayString = "$15/hour"
                attributedString = NSMutableAttributedString(string: "Rate: ")
                tempString = NSMutableAttributedString(string: tempPayString, attributes:attrs)
                attributedString.append(tempString)
                totalCostLabel.attributedText = attributedString
               
                //totalCostLabel.text = "Total Cost: \(tempPayString)"
                
            }
        } else {
            studentWorkersCollect.frame = studentPosterCollectSizeView.frame
            studentWorkersCollect.frame.origin = studentPosterCollectSizeView.frame.origin
            attributedString = NSMutableAttributedString(string: "Rate: ")
            tempString = NSMutableAttributedString(string: job.payment!, attributes:attrs)
            attributedString.append(tempString)
            totalCostLabel.attributedText = attributedString
            //totalCostLabel.text = "Total Cost \(job.payment!)"
        }
       
        if job.workers != nil {
            if self.senderScreen != "student" {
                print("notNilPoster")
                /* numberOfStudentsLabel.text = "Job Poster"*/
                if job.workers?.count as! Int > 1 {
                    print("greaterthanone")
                    numberOfStudentsLabel.text = "\(job.workers!.count) QuikFix students"
                } else {
                    print("notGreater")
                    numberOfStudentsLabel.text = "\(job.workers!.count) QuikFix student"
                }
            }
            else {
                
            }
        } else {
            if self.senderScreen == "student" {
                print("workersNilStudent")
            }
            else {
                print("workersNilPoster")
            numberOfStudentsLabel.text = "0 QuikFix Students"
            }
        }
        
        
        if self.senderScreen == "student"{
            Database.database().reference().child("students").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    for snap in snapshots {
                    /*    if snap.key == Auth.auth().currentUser!.uid{
                            let tempDict = snap.value as! [String:Any]
                            if tempDict
                            
                        }*/
                        if self.job.workers != nil && self.job.workers!.contains(snap.key) && Auth.auth().currentUser!.uid != snap.key{
                            var tempDict = [String:Any]()
                            tempDict[snap.key] = ["name": (snap.value as! [String:Any])["name"] as! String, "pic": (snap.value as! [String:Any])["pic"] as! String, "studentID": (snap.value as! [String:Any])["studentID"] as! String]
                            self.workers.append(tempDict)
                        }
                    }
                    
                }
                
                    Database.database().reference().child("jobPosters").child(self.job.posterID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            var tempDict2 = [String:Any]()
                            var tempDict = [String:Any]()
                            var jobs = [String:Any]()
                            for snap in snapshots {
                                if snap.key == "upcomingJobs"{
                                    jobs = snap.value as! [String:Any]
                                        
                                    
                                    
                                }
                                if snap.key == "name"{
                                    tempDict["name"] = snap.value as! String
                                    
                                }
                                if snap.key == "pic"{
                                    tempDict["pic"] = snap.value as! String
                                    
                                }
                                if snap.key == "posterID"{
                                    tempDict["posterID"] = snap.value as! String
                                    
                                }
                                
                            }
                            if jobs.count != 0 {
                                
                                for (key, val) in jobs {
                                    if key == self.job.jobID{
                                        var thisJob = val as! [String:Any]
                                        let timeLogsTemp = thisJob["timeLogs"] as! [String:Any]
                                        self.vdlTimeLogs = timeLogsTemp.values.first as! [String:Any]
                                        
                                    }
                                }
                                if self.vdlTimeLogs["studentOnLocation"] as! String != "false"{
                                    self.studentOnsite = true
                                   self.step1ImageView.image = UIImage(named: self.checkImage)
                                    
                                    if self.vdlTimeLogs["studentConfirmsArrival"] as! String != "false"{
                                        self.studentConfirmLocation = true
                                        self.step2ImageView.image = UIImage(named: self.checkImage)
                                        if self.vdlTimeLogs["posterConfirmsArrival"] as! String != "false"{
                                            self.posterConfirmLocation = true
                                            self.step3ImageView.image = UIImage(named: self.checkImage)
                                            if self.vdlTimeLogs["studentPressesStart"] as! String != "false"{
                                                self.studentPressedStart = true
                                                
                                                if self.vdlTimeLogs["studentPressesFinish"] as! String != "false"{
                                                    self.studentPressedFinish = true
                                                    self.ArrivalOrCompletionButton.setTitle("Job Completed", for: .normal)
                                                    self.ArrivalOrCompletionButton.isEnabled = false
                                                    self.ArrivalOrCompletionButton.isUserInteractionEnabled = false
                                                    //---show in progress view that covers details with job start time and whether they are on location or not AND shows how much they earned that job...
                                                   
                                                    
                                                } else {
                                                    var startTimerTimeString = self.vdlTimeLogs["studentPressesStart"] as! String
                                                    //job in progress
                                                    if self.timer.isValid == true{
                                                        self.timer.fire()
                                                    }
                                                     self.jobHasStartedView.isHidden = false
                                                    self.studentPressedFinish = false
                                                    self.ArrivalOrCompletionButton.setTitle("Finish Job", for: .normal)
                                                    //---show in progress view that covers details with job start time and whether they are on location or not etc...
                                                }
                                            } else {
                                                self.studentPressedStart = false
                                                //student and poster have confirmed arrival but student hasn't pressed start
                                            }
                                        } else {
                                            //student on location and poster and student confirm arrival
                                            self.step2ImageView.image = UIImage(named: self.checkImage)
                                            self.step3ImageView.image = UIImage(named: self.checkImage)
                                            self.studentConfirmLocation = true
                                            self.posterConfirmLocation = true
                                            self.ArrivalOrCompletionButton.setTitle("Start Job", for: .normal)
                                            self.ArrivalOrCompletionButton.isEnabled = false
                                            self.ArrivalOrCompletionButton.isUserInteractionEnabled = false
                                        }
                                    } else {
                                        self.studentConfirmLocation = false
                                        //student on location but has yet to confirm arrival and poster confirmation is unkown
                                        self.step2ImageView.image = UIImage(named: self.circleImage)
                                        if self.vdlTimeLogs["posterConfirmsArrival"] as! String != "false"{
                                            self.posterConfirmLocation = true
                                            self.step3ImageView.image = UIImage(named: self.checkImage)
                                             self.ArrivalOrCompletionButton.setTitle("Confirm Arrival at Job Site", for: .normal)
                                        } else {
                                            self.posterConfirmLocation = false
                                            self.step3ImageView.image = UIImage(named: self.checkImage)
                                            self.ArrivalOrCompletionButton.setTitle("Confirm Arrival at Job Site", for: .normal)
                                        }
                                    }
                                   
                                } else {
                                    self.studentOnsite = false
                                    self.step1ImageView.image = UIImage(named: self.circleImage)
                                    
                                    if self.vdlTimeLogs["studentConfirmsArrival"] as! String != "false"{
                                        self.step2ImageView.image = UIImage(named: self.checkImage)
                                        if self.vdlTimeLogs["posterConfirmsArrival"] as! String != "false"{
                                            self.step3ImageView.image = UIImage(named: self.checkImage)
                                            if self.vdlTimeLogs["studentPressesStart"] as! String != "false"{
                                                
                                                if self.vdlTimeLogs["studentPressesFinish"] as! String != "false"{
                                                    self.ArrivalOrCompletionButton.setTitle("Job Completed", for: .normal)
                                                    self.ArrivalOrCompletionButton.isEnabled = false
                                                    self.ArrivalOrCompletionButton.isUserInteractionEnabled = false
                                                    //---show in progress view that covers details with job start time and whether they are on location or not AND shows how much they earned that job...
                                                    
                                                    
                                                } else {
                                                    //---job in progress
                                                    let dateFormatter = DateFormatter()
                                                    dateFormatter.dateFormat = "MMMM-dd-yyyy h:mm a"
                                                    let tempTimeString = self.vdlTimeLogs["studentPressesStart"] as! String
                                                    self.startTimerTime = dateFormatter.date(from: tempTimeString)!
                                                    
                                                    self.ArrivalOrCompletionButton.setTitle("Finish Job", for: .normal)
                                                    self.ArrivalOrCompletionButton.isEnabled = true
                                                    self.ArrivalOrCompletionButton.isUserInteractionEnabled = true
                                                    //---show in progress view that covers details with job start time and whether they are on location or not etc...
                                                }
                                            } else {
                                                //student and poster have confirmed arrival but student hasn't pressed start
                                                self.step2ImageView.image = UIImage(named: self.circleImage)
                                                
                                            }
                                        } else {
                                            
                                            self.step2ImageView.image = UIImage(named: self.checkImage)
                                            self.step3ImageView.image = UIImage(named: self.checkImage)
                                            self.ArrivalOrCompletionButton.setTitle("Start Job", for: .normal)
                                            self.ArrivalOrCompletionButton.isEnabled = false
                                            self.ArrivalOrCompletionButton.isUserInteractionEnabled = false
                                            
                                        }
                                        
                                    } else {
                                        //student on location but has yet to confirm arrival and poster confirmation is unkown
                                        self.step2ImageView.image = UIImage(named: self.circleImage)
                                        self.step3ImageView.image = UIImage(named: self.circleImage)
                                        if self.vdlTimeLogs["posterConfirmsArrival"] as! String != "false"{
                                            self.step3ImageView.image = UIImage(named: self.checkImage)
                                            self.ArrivalOrCompletionButton.setTitle("Confirm Arrival at Job Site", for: .normal)
                                        } else {
                                            self.step3ImageView.image = UIImage(named: self.circleImage)
                                            self.ArrivalOrCompletionButton.setTitle("Confirm Arrival at Job Site", for: .normal)
                                        }
                                    }
                                }
                                    
                            }
                            tempDict2[(tempDict["posterID"] as! String)] = tempDict
                            self.workers.append(tempDict2)
                            self.workersCollect.delegate = self
                            self.workersCollect.dataSource = self
                            
                        }
                        
                    })
                    
                
                
                
            })
        } else {
            Database.database().reference().child("students").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    for snap in snapshots {
                        if self.job.workers != nil && self.job.workers!.contains(snap.key) && Auth.auth().currentUser!.uid != snap.key{
                            var tempDict = [String:Any]()
                            tempDict[snap.key] = ["name": (snap.value as! [String:Any])["name"] as! String, "pic": (snap.value as! [String:Any])["pic"] as! String, "studentID": (snap.value as! [String:Any])["studentID"] as! String]
                            self.workers.append(tempDict)
                        }
                    }
                    
                }
            if self.job.workers == nil{
                
            } else {
                self.workersCollect.delegate = self
                self.workersCollect.dataSource = self
                }
            
            })
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var vdlTimeLogs = [String:Any]()
    @IBAction func viewProfilePressed(_ sender: Any) {
       // self.studentIDFromResponse =
        performSegue(withIdentifier: "JobLogViewJobToStudentProfile", sender: self)
        
    }
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var totalCostLabel: UILabel!
    
    
    
    @IBAction func closeSelectedViewPressed(_ sender: Any) {
        cellSelectedView.isHidden = true
    }
    @IBOutlet weak var cellSelectedPic: UIImageView!
    @IBAction func sendDMPressed(_ sender: Any) {
        cellSelectedView.isHidden = true
    }
    @IBOutlet weak var cellSelectedView: UIView!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.sender == "poster"{
            return workers.count
        } else {
            return workers.count
        }
    }
    var jobID = String()
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JobLogStudentCell", for: indexPath) as! JobLogStudentCell
        
        cell.layer.cornerRadius = cell.frame.width/2
        //print((workers[indexPath.row].values.first as! [String:Any])["name"] as! String)
        
        cell.studentLabel.text = (workers[indexPath.row].values.first as! [String:Any])["name"] as! String
        
        if let messageImageUrl = URL(string: (workers[indexPath.row].values.first as! [String:Any])["pic"] as! String) {
            
            if let imageData: NSData = NSData(contentsOf: messageImageUrl) {
                cell.studentPic.image = UIImage(data: imageData as Data)
            cellSelectedPic.image = UIImage(data: imageData as Data)
            } }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.sender == "student"{
            cellSelectedView.isHidden = false
            self.studentIDFromResponse = (workers[indexPath.row].values.first as! [String:Any])["studentID"] as! String
        } else {
            
        }
    }

    

    var jobType = String()
    // MARK: - Navigation
    var name = String()
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var studentIDFromResponse = String()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMap"{
            if let vc = segue.destination as? MapViewController {
                vc.address = self.job.location!
                vc.senderScreen = self.senderScreen
                vc.job = self.job
                vc.jobType = self.jobType
                vc.sendJob = self.sendJob
            }
        }
        if (segue.identifier! as String) == "EmbeddedChat"{
            if let vc = segue.destination as? ChatViewController{
                
                vc.senderDisplayName = self.name
                vc.thisSessionID = String()
                vc.senderId = (Auth.auth().currentUser?.uid)!
                vc.senderName = (Auth.auth().currentUser?.uid)!
                vc.senderView = self.senderScreen
                vc.jobID = self.job.jobID!
                vc.job = self.job
                vc.jobType = self.jobType
                
                
            }
        } else if segue.identifier == "JobLogJobToChat"{
            if let vc = segue.destination as? ChatContainer{
                self.jobID = self.job.jobID!
                //vc.jobType = self.jobType
                
                if self.sender == "student"{
                    Database.database().reference().child("students").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            
                            for snap in snapshots {
                                if snap.key == "name"{
                                    self.name = snap.value as! String
                                }
                            }
                        }
                        
                    })
                } else {
                    Database.database().reference().child("jobPosters").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            
                            for snap in snapshots {
                                if snap.key == "name"{
                                    self.name = snap.value as! String
                                }
                            }
                        }
                        
                    })
                    
                }
                vc.name = self.name
                vc.jobID = self.job.jobID!
                vc.userID = (Auth.auth().currentUser?.uid)!
                //vc.bandType = "onb"
                //vc.sender = self.sender
                vc.senderScreen = self.senderScreen
                vc.job = self.job
                vc.jobType = self.jobType

                
            }
        } else if segue.identifier == "JobLogViewJobToStudentProfile"{
            if let vc = segue.destination as? studentProfile{
                vc.sender = "JobLogSingleJobPoster"
                vc.notUsersProfile = true
                vc.job = self.job
                vc.studentIDFromResponse = self.studentIDFromResponse
            }
            
        } else {
            
        
        if let vc = segue.destination as? JobHistoryViewController{
            vc.senderScreen = self.senderScreen
            vc.jobType = self.jobType
        }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        print("didCreatePaymentResult: \(self.job.posterID)")
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
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var numberFormatter: NumberFormatter?
    //let shippingString: String
    var product = ""
    
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
            message = ""
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
    
    var paymentContext: STPPaymentContext?
    
    var theme: STPTheme?
    
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

    
    

}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
