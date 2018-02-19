//
//  JobPostTimeViewController.swift
//  QuikFix
//
//  Created by Thomas Threlkeld on 9/25/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import CoreLocation

class JobPostTimeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var currentDateLabel: UILabel!
    
    
    var edit = Bool()
    var jobPostEdit = JobPost()
    var toolCount = Int()
    var jobCoord = CLLocation()
    
    @IBOutlet weak var selectTimeButton: UIButton!
    let qfGreen = UIColor(colorLiteralRed: 49/255, green: 74/255, blue: 82/255, alpha: 1.0)
    @IBAction func selectTimePressed(_ sender: Any) {
       let jobTime = "\(hourData[hourPicker.selectedRow(inComponent: 0)]):\(minuteData[minutePicker.selectedRow(inComponent: 0)]) \(amPMData[amPMPicker.selectedRow(inComponent: 0)])"
        if timesArray.contains(jobTime){
            timesArray.remove(at: timesArray.index(of: jobTime)!)
            selectTimeButton.backgroundColor = qfGreen
            selectTimeButton.setTitle("Select", for: .normal)
            if timesArray.count == 1{
                //numSelectedDatesLabel.text = "1 Date Selected"
            } else if timesArray.count == 0{
               //numSelectedDatesLabel.text = "0 Date Selected"
            } else {
               // numSelectedDatesLabel.text = "\(datesArray.count) Dates Selected"
            }
        } else {
            
           
            
            timesArray.append(jobTime)
            
            selectTimeButton.backgroundColor = UIColor.red
            selectTimeButton.setTitle("Remove", for: .normal)
        }
    }
    @IBOutlet weak var selectTimeTypeView: UIView!
    
    @IBOutlet weak var selectSpecificTime: UIButton!
    
    @IBAction func specificTimePressed(_ sender: Any) {
        self.selectType = "single"
        selectTimeTypeView.isHidden = true
    }
    @IBOutlet weak var rangeOfTimesButton: UIButton!
    
    @IBAction func rangeOfTimesPressed(_ sender: Any) {
        self.selectType = "range"
        selectTimeTypeView.isHidden = true
        /*selectSpecificTime.isHidden = true
        orButton.isHidden = true
        rangeOfTimesButton.isHidden = true*/
    }
    
    @IBOutlet weak var orButton: UILabel!
    
    @IBOutlet weak var amPMPicker: UIPickerView!
    @IBOutlet weak var minutePicker: UIPickerView!
    @IBOutlet weak var hourPicker: UIPickerView!
    func timeFormatter(time: Date) -> String{
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.dateFormat = "HH:mm a"
        timeFormatter.timeStyle = .short
        
        let timeStamp = timeFormatter.string(from: time)
        return timeStamp
    }
    var timesArray = [String]()
    var finalTimesArray = [[String]]()
    var selectType = String()
    var curIndex = 1
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        if continueButton.titleLabel?.text == "Next Date"{
            hourPicker.selectRow(0, inComponent: 0, animated: true)
            minutePicker.selectRow(0, inComponent: 0, animated: true)
            amPMPicker.selectRow(0, inComponent: 0, animated: true)
            
            currentDateLabel.text = jobPost.date![curIndex] as! String
            if selectType == "single"{
                let jobTime = "\(hourData[hourPicker.selectedRow(inComponent: 0)]):\(minuteData[minutePicker.selectedRow(inComponent: 0)]) \(amPMData[amPMPicker.selectedRow(inComponent: 0)])"
                if timesArray.count == 0{
                    //alert that you must select date
                    return
                } else {
                    finalTimesArray.append(timesArray)
                    //timesArray.removeAll()
                }
                
            } else {
                if timesArray.count == 0{
                    //alert that you must select date
                    return
                } else {
                    finalTimesArray.append(timesArray)
                    timesArray.removeAll()
                }
            }
            
            if curIndex == (jobPost.date?.count)! - 1 {
                continueButton.setTitle("Continue", for: .normal)
            }
            curIndex = curIndex + 1
            
            
        } else {
           
            
        var hourData = [String]()
       
            hourData = self.hourData
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM-dd-yyyy hh:mm a"
        //formatter.timeStyle = .short
        //formatter.dateStyle = .none
        let tempDate = formatter.string(from: date)
        
        
        print("actualDateTime: \(tempDate)")
        
        let jobTimeLast = "\(hourData[hourPicker.selectedRow(inComponent: 0)]):\(minuteData[minutePicker.selectedRow(inComponent: 0)]) \(amPMData[amPMPicker.selectedRow(inComponent: 0)])"
            
            
            
                var tempString = String()
                if selectType == "single"{
                if edit == true {
                 tempString = "\(self.jobPostEdit.date![curIndex]) \(hourData[hourPicker.selectedRow(inComponent: 0)]):\(minuteData[minutePicker.selectedRow(inComponent: 0)]) \(amPMData[amPMPicker.selectedRow(inComponent: 0)])"
                 } else {
                 tempString = "\(self.jobPost.date![curIndex]) \(hourData[hourPicker.selectedRow(inComponent: 0)]):\(minuteData[minutePicker.selectedRow(inComponent: 0)]) \(amPMData[amPMPicker.selectedRow(inComponent: 0)])"
                 }
                
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "MMMM-dd-yyyy h:mm a"
                
                let dateObj = dateFormatter2.date(from: tempString)
                let dateObj2 = formatter.date(from: tempDate)
                print("jobTime: \(String(describing: dateObj)), realTime: \(String(describing: dateObj2))")
                if (dateObj as! Date) <= (dateObj2 as! Date){
                    let alert = UIAlertController(title: "Date has Passed", message: "Job start time must be atleast thirty minutes from right now.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                    //print("selectedTime: \(tempString)")
                    timesArray.append(jobTimeLast)
                    finalTimesArray.append(timesArray)
                    jobPost.startTime = finalTimesArray
                    
                    jobPostEdit.startTime = finalTimesArray
                    
                    if edit == true {
                        performSegue(withIdentifier: "EditTimeToPostJob", sender: self)
                    } else {
                        if finalTimesArray.count == 0{
                            //alert
                            return
                        } else {
                        if jobPost.category1 == "Moving(Home-To-Home)"{
                            performSegue(withIdentifier: "SkipLocationSegue", sender: self)
                        } else {
                            performSegue(withIdentifier: "JPStep4ToStep5", sender: self)
                        }
                        }
                    }
                }
                } else {
                    timesArray.append(jobTimeLast)
                    finalTimesArray.append(timesArray)
                    jobPost.startTime = finalTimesArray
                    
                    jobPostEdit.startTime = finalTimesArray
                    
                    if edit == true {
                        performSegue(withIdentifier: "EditTimeToPostJob", sender: self)
                    } else {
                        
                        if jobPost.category1 == "Moving(Home-To-Home)"{
                            performSegue(withIdentifier: "SkipLocationSegue", sender: self)
                        } else {
                            performSegue(withIdentifier: "JPStep4ToStep5", sender: self)
                        }
                    }
                }
            }
        
        
            
            
        
    }
    
   // @IBOutlet weak var durationPicker: UIPickerView!
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == hourPicker {
            if row >= 4 {
                amPMPicker.selectRow(1, inComponent: 0, animated: true)
            amPMPicker.reloadAllComponents()
            } else {
                amPMPicker.selectRow(0, inComponent: 0, animated: true)
                amPMPicker.reloadAllComponents()
            }
        }
        var tempString = "\(hourData[hourPicker.selectedRow(inComponent: 0)]):\(minuteData[minutePicker.selectedRow(inComponent: 0)]) \(amPMData[amPMPicker.selectedRow(inComponent: 0)])"
        if timesArray.contains(tempString){
            
            selectTimeButton.backgroundColor = UIColor.red
            selectTimeButton.setTitle("Remove", for: .normal)
        } else {
            
            selectTimeButton.backgroundColor = qfGreen
            selectTimeButton.setTitle("Select", for: .normal)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == amPMPicker{
            return amPMData.count
        } else if pickerView == hourPicker{
            return hourData.count
        } else {
            return minuteData.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == amPMPicker{
            return amPMData[row]
        } else if pickerView == hourPicker{
            
                return hourData[row]
            
            
        } else {
            return minuteData[row]
        }
        
    }
    var hourData = ["8","9","10","11","12","1","2","3","4","5","6","7","8"]
   // var hourDataAM = ["8","9","10","11"]
    var minuteData = ["00","15","30","45"]
    var amPMData = ["AM", "PM"]
    
    
    

    @IBOutlet weak var continueButton: UIButton!
    
    
    //@IBOutlet weak var endTimePicker: UIDatePicker!
   // @IBOutlet weak var startTimePicker: UIDatePicker!
    var jobPost = JobPost()
    override func viewDidLoad() {
        super.viewDidLoad()
        if (jobPost.date?.count as! Int) > 1 {
            continueButton.setTitle("Next Date", for: .normal)
        }
        currentDateLabel.text = jobPost.date!.first
        amPMPicker.delegate = self
        amPMPicker.dataSource = self
        amPMPicker.isUserInteractionEnabled = false
        hourPicker.delegate = self
        hourPicker.dataSource = self
        minutePicker.delegate = self
        minutePicker.dataSource = self
        
        
        //startTimePicker.layer.cornerRadius = 7
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JPStep4ToStep5"{
            if let vc = segue.destination as? JobPostLocationPickerViewController{
                vc.jobPost = self.jobPost
            }
            
        } else if segue.identifier == "EditTimeToPostJob" {
            if let vc = segue.destination as? ActualFinalizeViewController{
                vc.jobCoord = self.jobCoord
                vc.jobPost = self.jobPostEdit
                //vc.timeDifference = Int(jobPostEdit.jobDuration!)!
                vc.toolCount = self.toolCount
            }
            
        } else {
            if let vc = segue.destination as? Finalize{
                vc.jobPost = self.jobPost
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
