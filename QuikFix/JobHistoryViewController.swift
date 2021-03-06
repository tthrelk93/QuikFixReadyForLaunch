//
//  JobHistoryViewController.swift
//  QuikFix
//
//  Created by Thomas Threlkeld on 9/30/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class JobHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PerformSegueInJobPostViewController, UITabBarDelegate {
    var calendarDict = [String:Any]()
    var categoryType = String()
    var jobsForDate = [JobPost]()
    
    
    
    @IBOutlet weak var noJobsLabel: UILabel!
    
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items?[0]{
            
            
        } else if item == tabBar.items?[1]{
            performSegue(withIdentifier: "TabBarJobLogToJobFinder", sender: self)
            
        } else if item == tabBar.items?[2]{
            performSegue(withIdentifier: "TabBarJobLogToProfile", sender: self)
            
        } else {
            performSegue(withIdentifier: "TabBarJobLogToCalendar", sender: self)
            
        }
    }

    
    @IBOutlet weak var jobHistoryTableView: UITableView!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
                performSegue(withIdentifier: "JobHistoryToPosterProf", sender: self)
        
    }
    @IBAction func segmentChanged(_ sender: Any) {
        self.tableViewData.removeAll()
        self.calendarDict.removeAll()
        jobsForDate.removeAll()
        //if self.senderScreen == "poster"{
        switch jobTypeSegment.selectedSegmentIndex
        {
        case 0:
            
            for (key, tempDict) in self.jobsCompleted{
                let tempJob = JobPost()
                self.sendJob = tempDict
                tempJob.additInfo = (tempDict["additInfo"] as! String)
                tempJob.category1 = (tempDict["category1"] as! String)
                //tempJob.category2 = (tempDict["category2"] as! String)
                tempJob.posterName = (tempDict["posterName"] as! String)
                tempJob.date = (tempDict["date"] as! [String])
                if self.senderScreen == "student"{
                    var tempPayString = tempDict["payment"] as! String
                    tempPayString = tempPayString.replacingOccurrences(of: "$", with: "")
                    let tempPayDouble = ((Double(tempPayString)! * 0.6) / (tempDict["workerCount"] as! Double))
                    tempPayString = "$\(tempPayDouble)"
                    tempJob.payment = tempPayString
                } else {
                    tempJob.payment = (tempDict["payment"] as! String)
                    tempJob.serviceFees = (tempDict["serviceFees"] as! String)
                }
                 tempJob.startTime = ((tempDict["startTime"] as! [[String]]).first as! [String])
                //tempJob.jobDuration = tempDict["jobDuration"] as! String
                tempJob.jobID = (tempDict["jobID"] as! String)
                if tempDict["category1"] as! String == "Moving(Home-To-Home)"{
                    tempJob.pickupLocation = (tempDict["pickupLocation"] as! String)
                    tempJob.dropOffLocation = (tempDict["dropOffLocation"] as! String)
                } else {
                    tempJob.location = tempDict["location"] as! String
                }
                tempJob.timeLogs = tempDict["timeLogs"] as! [String:Any]
                tempJob.workers = tempDict["workers"] as! [String]
                tempJob.jobLat = tempDict["jobLat"] as! String
                tempJob.jobLong = tempDict["jobLong"] as! String
                tempJob.posterID = (tempDict["posterID"] as! String)
                tempJob.completed = tempDict["completed"] as! Bool
                if tempDict["workers"] != nil{
                    tempJob.workers = (tempDict["workers"] as! [String])
                }

                tableViewData.append(tempJob)
                if self.calendarDict[tempJob.date!.first!] != nil {
                    var tempJobArray = self.calendarDict[tempJob.date!.first!]! as! [JobPost]
                    tempJobArray.append(tempJob)
                    self.calendarDict[tempJob.date!.first!] = tempJobArray
                } else {
                    self.calendarDict[tempJob.date!.first!] = [tempJob]
                }
                
            }
            for (key, _) in self.calendarDict{
                self.datesArray.append(key)
            }
            //var testArray = ["25 Jun, 2016", "30 Jun, 2016", "28 Jun, 2016", "2 Jul, 2016"]
            var convertedArray: [Date] = []
            
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM-dd-yyyy"
            
            for dat in self.datesArray {
                var date = dateFormatter.date(from: dat)
                convertedArray.append(date!)
            }
            
            //Approach : 1
            convertedArray.sort(){$0 < $1}
            self.datesArray.removeAll()
            for dat in convertedArray{
                let formatter = DateFormatter()
                // initially set the format based on your datepicker date
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let myString = formatter.string(from: dat)
                // convert your string to date
                let yourDate = formatter.date(from: myString)
                //then again set the date format whhich type of output you need
                formatter.dateFormat = "MMMM-dd-yyyy"
                // again convert your date to string
                let dateString = formatter.string(from: yourDate!)
                self.datesArray.append(dateString)
            }
            
            DispatchQueue.main.async{
                self.jobHistoryTableView.reloadData()
            }

            
        case 1:
            for (key, tempDict) in self.upcomingJobs{
                let tempJob = JobPost()
                self.sendJob = tempDict
                tempJob.additInfo = (tempDict["additInfo"] as! String)
                tempJob.category1 = (tempDict["category1"] as! String)
                //tempJob.category2 = (tempDict["category2"] as! String)
                tempJob.posterName = (tempDict["posterName"] as! String)
                tempJob.date = (tempDict["date"] as! [String])
                if self.senderScreen == "student"{
                    var tempPayString = tempDict["payment"] as! String
                    tempPayString = tempPayString.replacingOccurrences(of: "$", with: "")
                    let tempPayDouble = ((Double(tempPayString)! * 0.6) / (tempDict["workerCount"] as! Double))
                    tempPayString = "$\(tempPayDouble)"
                    tempJob.payment = tempPayString
                } else {
                    tempJob.payment = (tempDict["payment"] as! String)
                    tempJob.serviceFees = (tempDict["serviceFees"] as! String)
                }
                tempJob.startTime = ((tempDict["startTime"] as! [[String]]).first as! [String])
                if tempDict["category1"] as! String == "Moving(Home-To-Home)"{
                    tempJob.pickupLocation = (tempDict["pickupLocation"] as! String)
                    tempJob.dropOffLocation = (tempDict["dropOffLocation"] as! String)
                } else {
                    tempJob.location = tempDict["location"] as! String
                }
                tempJob.workers = tempDict["workers"] as? [String]
                //tempJob.jobDuration = tempDict["jobDuration"] as! String
                tempJob.jobID = (tempDict["jobID"] as! String)
                tempJob.posterID = (tempDict["posterID"] as! String)
                tempJob.jobLat = tempDict["jobLat"] as! String
                tempJob.jobLong = tempDict["jobLong"] as! String
                tempJob.completed = tempDict["completed"] as! Bool
                if tempDict["workers"] != nil{
                tempJob.workers = (tempDict["workers"] as! [String])
                }
                tableViewData.append(tempJob)
            
                if self.calendarDict[tempJob.date!.first!] != nil {
                    var tempJobArray = self.calendarDict[tempJob.date!.first!]! as! [JobPost]
                    tempJobArray.append(tempJob)
                    self.calendarDict[tempJob.date!.first!] = tempJobArray
                } else {
                    self.calendarDict[tempJob.date!.first!] = [tempJob]
                }
                
            }
            for (key, _) in self.calendarDict{
                self.datesArray.append(key)
            }
            //var testArray = ["25 Jun, 2016", "30 Jun, 2016", "28 Jun, 2016", "2 Jul, 2016"]
            var convertedArray: [Date] = []
            
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM-dd-yyyy"
            
            for dat in self.datesArray {
                var date = dateFormatter.date(from: dat)
                convertedArray.append(date!)
            }
            
            //Approach : 1
            convertedArray.sort(){$0 < $1}
            self.datesArray.removeAll()
            for dat in convertedArray{
                let formatter = DateFormatter()
                // initially set the format based on your datepicker date
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let myString = formatter.string(from: dat)
                // convert your string to date
                let yourDate = formatter.date(from: myString)
                //then again set the date format whhich type of output you need
                formatter.dateFormat = "MMMM-dd-yyyy"
                // again convert your date to string
                let dateString = formatter.string(from: yourDate!)
                self.datesArray.append(dateString)
            }
            
            DispatchQueue.main.async{
                self.jobHistoryTableView.reloadData()
            }
        default:
            break;
        }
        //} else {
            
        //}
    }
    @IBOutlet weak var tabBar: UITabBar!
    
    
    
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var jobTypeSegment: UISegmentedControl!
    var datesArray = [String]()
    var senderScreen = String()
    var currentListings = [String: [String:Any]]()
    var jobsCompleted = [String: [String:Any]]()
    var upcomingJobs = [String: [String:Any]]()
    //var currentListingsObj = [[String:Any]]()
    //var jobsCompletedObj = [[String:Any]]()
    var tableViewData = [JobPost]()
    //var upcomingJobsObj = [[String:Any]]()
    var jobType = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("senderScreen = \(self.senderScreen)")
        if self.senderScreen == "poster"{
            print("in poster")
            self.backButton.isHidden = false
            self.tabBar.isHidden = true
            self.jobTypeSegment.isHidden = true
            Database.database().reference().child("jobPosters").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    if snap.key == "jobsCompleted"{
                        self.jobsCompleted = snap.value as! [String: [String:Any]]
                    }

                    if snap.key == "currentListings"{
                        self.currentListings = snap.value  as! [String: [String:Any]]
                    }
                    if snap.key == "upcomingJobs"{
                        self.upcomingJobs = snap.value as! [String: [String:Any]]
                    }
                    }
                }
                
                
                    print("im hereeee")
                    if self.jobType == "jc"{
                    for (key, tempDict) in self.jobsCompleted{
                        let tempJob = JobPost()
                        self.sendJob = tempDict
                        tempJob.additInfo = (tempDict["additInfo"] as! String)
                        tempJob.category1 = (tempDict["category1"] as! String)
                        //tempJob.category2 = (tempDict["category2"] as! String)
                        tempJob.timeLogs = tempDict["timeLogs"] as! [String:Any]
                        tempJob.workers = tempDict["workers"] as! [String]
                        if tempDict["category1"] as! String == "Moving(Home-To-Home)"{
                            tempJob.pickupLocation = (tempDict["pickupLocation"] as! String)
                            tempJob.dropOffLocation = (tempDict["dropOffLocation"] as! String)
                        } else {
                            tempJob.location = tempDict["location"] as! String
                        }
                        tempJob.posterName = (tempDict["posterName"] as! String)
                       tempJob.date = (tempDict["date"] as! [String])
                        
                        tempJob.payment = (tempDict["payment"] as! String)
                        tempJob.serviceFees = (tempDict["serviceFees"] as! String)
                        tempJob.startTime = ((tempDict["startTime"] as! [[String]]).first as! [String])
                       // tempJob.jobDuration = tempDict["jobDuration"] as! String
                        tempJob.jobID = (tempDict["jobID"] as! String)
                        tempJob.posterID = (tempDict["posterID"] as! String)
                        tempJob.completed = tempDict["completed"] as! Bool
                        tempJob.workers = (tempDict["workers"] as! [String])
                        tempJob.jobLat = tempDict["jobLat"] as! String
                        tempJob.jobLong = tempDict["jobLong"] as! String
                        self.tableViewData.append(tempJob)
                        if self.calendarDict[tempJob.date!.first!] != nil {
                            var tempJobArray = self.calendarDict[tempJob.date!.first!]! as! [JobPost]
                            tempJobArray.append(tempJob)
                            self.calendarDict[tempJob.date!.first!] = tempJobArray
                        } else {
                            self.calendarDict[tempJob.date!.first!] = [tempJob]
                        }

                    }
                    } else if self.jobType == "cl"{
                        for (key, tempDict) in self.currentListings{
                            let tempJob = JobPost()
                            self.sendJob = tempDict
                            tempJob.additInfo = (tempDict["additInfo"] as! String)
                            tempJob.category1 = (tempDict["category1"] as! String)
                            //tempJob.category2 = (tempDict["category2"] as! String)
                            tempJob.posterName = (tempDict["posterName"] as! String)
                            tempJob.date = (tempDict["date"] as! [String])
                          //  tempJob.workers = tempDict["workers"] as! [String]
                           
                                if tempDict["category1"] as! String == "Moving(Home-To-Home)"{
                                    tempJob.pickupLocation = (tempDict["pickupLocation"] as! String)
                                    tempJob.dropOffLocation = (tempDict["dropOffLocation"] as! String)
                                } else {
                                    tempJob.location = tempDict["location"] as! String
                                }
                            
                            tempJob.payment = (tempDict["payment"] as! String)
                            tempJob.serviceFees = (tempDict["serviceFees"] as! String)
                               tempJob.startTime = ((tempDict["startTime"] as! [[String]]).first as! [String])
                            
                            //tempJob.jobDuration = tempDict["jobDuration"] as! String
                            tempJob.jobID = (tempDict["jobID"] as! String)
                            tempJob.posterID = (tempDict["posterID"] as! String)
                            tempJob.completed = tempDict["completed"] as! Bool
                            if tempDict["workers"] == nil {
                                tempJob.workers = nil
                            } else {
                            tempJob.workers = (tempDict["workers"] as! [String])
                            }
                            self.tableViewData.append(tempJob)
                            if self.calendarDict[tempJob.date!.first!] != nil {
                                var tempJobArray = self.calendarDict[tempJob.date!.first!]! as! [JobPost]
                                tempJobArray.append(tempJob)
                                self.calendarDict[tempJob.date!.first!] = tempJobArray
                            } else {
                                self.calendarDict[tempJob.date!.first!] = [tempJob]
                            }
                            
                        }
                    } else {
                            for (key, tempDict) in self.upcomingJobs{
                                let tempJob = JobPost()
                                self.sendJob = tempDict
                                tempJob.additInfo = (tempDict["additInfo"] as! String)
                                tempJob.category1 = (tempDict["category1"] as! String)
                                //tempJob.category2 = (tempDict["category2"] as! String)
                                tempJob.posterName = (tempDict["posterName"] as! String)
                               tempJob.date = (tempDict["date"] as! [String])
                                tempJob.workers = tempDict["workers"] as! [String]
                                tempJob.timeLogs = tempDict["timeLogs"] as! [String:Any]
                                if tempDict["category1"] as! String == "Moving(Home-To-Home)"{
                                    tempJob.pickupLocation = (tempDict["pickupLocation"] as! String)
                                    tempJob.dropOffLocation = (tempDict["dropOffLocation"] as! String)
                                } else {
                                    tempJob.location = tempDict["location"] as! String
                                }
                                tempJob.payment = (tempDict["payment"] as! String)
                                tempJob.serviceFees = (tempDict["serviceFees"] as! String)
                                 tempJob.startTime = ((tempDict["startTime"] as! [[String]]).first as! [String])
                                //tempJob.jobDuration = tempDict["jobDuration"] as! String
                                tempJob.jobID = (tempDict["jobID"] as! String)
                                tempJob.posterID = (tempDict["posterID"] as! String)
                                tempJob.completed = tempDict["completed"] as! Bool
                                tempJob.workers = (tempDict["workers"] as! [String])
                                self.tableViewData.append(tempJob)
                                if self.calendarDict[tempJob.date!.first!] != nil {
                                    var tempJobArray = self.calendarDict[tempJob.date!.first!]! as! [JobPost]
                                    tempJobArray.append(tempJob)
                                    self.calendarDict[tempJob.date!.first!] = tempJobArray
                                } else {
                                    self.calendarDict[tempJob.date!.first!] = [tempJob]
                                }
                                
                            }
                        }
                    
                    for (key, _) in self.calendarDict{
                        self.datesArray.append(key)
                    }
                    //var testArray = ["25 Jun, 2016", "30 Jun, 2016", "28 Jun, 2016", "2 Jul, 2016"]
                    var convertedArray: [Date] = []
                    
                    var dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM-dd-yyyy"
                    
                    for dat in self.datesArray {
                     var date = dateFormatter.date(from: dat)
                     convertedArray.append(date!)
                     }
                    
                    //Approach : 1
                    convertedArray.sort(){$0 < $1}
                    self.datesArray.removeAll()
                    for dat in convertedArray{
                        let formatter = DateFormatter()
                        // initially set the format based on your datepicker date
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        let myString = formatter.string(from: dat)
                        // convert your string to date
                        let yourDate = formatter.date(from: myString)
                        //then again set the date format whhich type of output you need
                        formatter.dateFormat = "MMMM-dd-yyyy"
                        // again convert your date to string
                        let dateString = formatter.string(from: yourDate!)
                        self.datesArray.append(dateString)
                    }

                    
                    
                    self.jobHistoryTableView.delegate = self
                    self.jobHistoryTableView.dataSource = self
                    DispatchQueue.main.async{
                        self.jobHistoryTableView.reloadData()
                    }

                })
            
        } else {
            print("in student")
            tabBar.delegate = self
            backButton.isHidden = true
            tabBar.isHidden = false
            // else if senderscreen == student
            print("jobHistViewLoad: in student")
            Database.database().reference().child("students").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    for snap in snapshots {
                        if snap.key == "upcomingJobs"{
                            self.upcomingJobs = snap.value as! [String: [String:Any]]
                        }
                        
                        if snap.key == "jobsCompleted"{
                            self.jobsCompleted = snap.value as! [String: [String:Any]]
                        }
                        
                    }
                }
                
                
                    
                    for (key, tempDict) in self.jobsCompleted{
                        let tempJob = JobPost()
                        self.sendJob = tempDict
                        tempJob.additInfo = (tempDict["additInfo"] as! String)
                        tempJob.category1 = (tempDict["category1"] as! String)
                        //tempJob.category2 = (tempDict["category2"] as! String)
                        tempJob.posterName = (tempDict["posterName"] as! String)
                        tempJob.date = (tempDict["date"] as! [String])
                        if tempDict["category1"] as! String == "Moving(Home-To-Home)"{
                            tempJob.pickupLocation = (tempDict["pickupLocation"] as! String)
                            tempJob.dropOffLocation = (tempDict["dropOffLocation"] as! String)
                        } else {
                            tempJob.location = tempDict["location"] as! String
                        }
                        tempJob.workers = tempDict["workers"] as! [String]
                        tempJob.timeLogs = tempDict["timeLogs"] as! [String:Any]
                        var tempPayString = tempDict["payment"] as! String
                        tempPayString = tempPayString.replacingOccurrences(of: "$", with: "")
                        let tempPayDouble = ((Double(tempPayString)! * 0.6) / (tempDict["workerCount"] as! Double))
                        tempPayString = "$\(tempPayDouble)"
                        tempJob.payment = tempPayString
                       
                        tempJob.startTime = ((tempDict["startTime"] as! [[String]]).first as! [String])
                        //tempJob.jobDuration = tempDict["jobDuration"] as! String
                        tempJob.jobID = (tempDict["jobID"] as! String)
                        tempJob.posterID = (tempDict["posterID"] as! String)
                        tempJob.completed = tempDict["completed"] as! Bool
                        tempJob.workers = (tempDict["workers"] as! [String])
                        tempJob.jobLat = tempDict["jobLat"] as? String
                        tempJob.jobLong = tempDict["jobLong"] as? String
                        self.tableViewData.append(tempJob)
                       
                        if self.calendarDict[tempJob.date!.first!] != nil {
                            var tempJobArray = self.calendarDict[tempJob.date!.first!]! as! [JobPost]
                            tempJobArray.append(tempJob)
                            self.calendarDict[tempJob.date!.first!]! = tempJobArray
                        } else {
                            self.calendarDict[tempJob.date!.first!] = [tempJob]
                        }
                        
                    }
                    for (key, _) in self.calendarDict{
                        self.datesArray.append(key)
                    }
                    //var testArray = ["25 Jun, 2016", "30 Jun, 2016", "28 Jun, 2016", "2 Jul, 2016"]
                    var convertedArray: [Date] = []
                    
                    var dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM-dd-yyyy"
                    
                    for dat in self.datesArray {
                        var date = dateFormatter.date(from: dat)
                        convertedArray.append(date!)
                    }
                    
                    //Approach : 1
                    convertedArray.sort(){$0 < $1}
                    self.datesArray.removeAll()
                    for dat in convertedArray{
                        let formatter = DateFormatter()
                        // initially set the format based on your datepicker date
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        let myString = formatter.string(from: dat)
                        // convert your string to date
                        let yourDate = formatter.date(from: myString)
                        //then again set the date format whhich type of output you need
                        formatter.dateFormat = "MMMM-dd-yyyy"
                        // again convert your date to string
                        let dateString = formatter.string(from: yourDate!)
                        self.datesArray.append(dateString)
                    }
                    
                    
                    
                    self.jobHistoryTableView.delegate = self
                    self.jobHistoryTableView.dataSource = self
                    DispatchQueue.main.async{
                        self.jobHistoryTableView.reloadData()
                    }
                    
                })

        }
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //***TableView DataSource functions
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if calendarDict.count == 0{
            noJobsLabel.isHidden = false
        } else {
            noJobsLabel.isHidden = true
        }
        return calendarDict.count
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateTableCell",
                                                 for: indexPath) as! DateTableViewCell
        
        configureTableViewCell(tableView: tableView, cell: cell, indexPath: indexPath)
        // (cell as! DateTableViewCell).cal.delegate = self
        //(cell as! DateTableViewCell).jobsCollect.dataSource = self
        
        return cell
    }
    var sizingCell: DateCollectionViewCell?
    func configureTableViewCell(tableView: UITableView, cell: DateTableViewCell, indexPath: IndexPath){
        var tempArray = [String]()
        for (key, _) in calendarDict{
            tempArray.append(key)
        }
        tempArray.reverse()
        cell.dateLabel?.text = tempArray[indexPath.row]
        cell.layer.borderColor = UIColor.clear.cgColor
        for (key, val) in calendarDict{
            if key == tempArray[indexPath.row]{
                
                self.jobsForDate = (val as! [JobPost])
                cell.jobsForDate = val as! [JobPost]
                cell.sender = "poster"
                cell.calCollect.dataSource = cell
                cell.calCollect.delegate = cell
                cell.calCollect.heightAnchor.constraint(equalToConstant: (145.0 * CGFloat(jobsForDate.count)) + 37).isActive = true
                cell.delegate = self
                cell.category = self.categoryType
                break
            }
        }
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        //let tempCell = DateCollectionViewCell()
        //print("TVCheight: \((tempCell.frame.height * CGFloat(jobsForDate.count)))")
        return ((200.0 * CGFloat(jobsForDate.count)))
    }
    var selectedJobID = String()
    var selectedJob = JobPost()
    
    func performSegueToSingleJob(category: String, jobID: String, job: JobPost){
        print("performSegueFunc")
        self.selectedJobID = jobID
        self.selectedJob = job
        
        performSegue(withIdentifier: "JobLogToJob", sender: self)
        
    }

    
   // var selectedJob = JobPost()
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var sendJob = [String:Any]()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JobLogToJob"{
            if let vc = segue.destination as? JobLogJobViewController{
                print("senderScreen hist To job: \(senderScreen)")
                vc.senderScreen = self.senderScreen
                vc.job = self.selectedJob
                vc.jobType = self.jobType
                vc.sendJob = self.sendJob
                
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
