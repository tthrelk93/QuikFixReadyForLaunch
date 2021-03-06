//
//  JobPostDateAndTimeViewController.swift
//  QuikFix
//
//  Created by Thomas Threlkeld on 9/9/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import CoreLocation



class JobPostDateAndTimeViewController: UIViewController {
    
    @IBAction func specificDatePressed(_ sender: Any) {
        singleOrRangeView.isHidden = true
    }
    @IBAction func rangeOfDatesPressed(_ sender: Any) {
        performSegue(withIdentifier: "ToRangeOfDates", sender: self)
    }
    
    @IBOutlet weak var singleOrRangeView: UIView!
    var jobPost = JobPost()
    var edit = Bool()
    var jobPostEdit = JobPost()
    var toolCount = Int()
    var jobCoord = CLLocation()
    @IBAction func continuePressed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM-dd-yyyy"
        var dateStamp = dateFormatter.string(from: timeAndDatePicker.date)
        jobPost.date = [dateStamp]
        jobPostEdit.date  = [dateStamp]
        /*if edit == true{
            performSegue(withIdentifier: "EditDateToPostJob", sender: self)
        }*/
        performSegue(withIdentifier: "JPStepTwoToStepThree", sender: self)
    }

    @IBOutlet weak var timeAndDatePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //let calendar = Calendar.current
        //let year = calendar.component(.year, from: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        var yearString = dateFormatter.string(from: Date())
        
        var tempDateString = "12-31-\(yearString)"
        dateFormatter.dateFormat = "MMMM-dd-yyyy"
        var tempDate = dateFormatter.date(from: tempDateString)
        
        
        //timeAndDatePicker.maximumDate = tempDate
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        //components.year = -18
        //let minDate: NSDate = gregorian.dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
        
        //components.year = -0
       // let maxDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        //self.datePicker.minimumDate = maxDate
        let todaysDate = Date()
        
        timeAndDatePicker.minimumDate = todaysDate
        //timeAndDatePicker.maximumDate = //Calendar.current.date(byAdding: .year, value: -1, to: Date())
        //self.timeAndDatePicker.maximumDate = tempDate

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("jobPost: \(self.jobPost)")
        if segue.identifier == "ToRangeOfDates"{
            if let vc = segue.destination as? JobPostStep3RangeOfDates{
                vc.jobPost = self.jobPost
            }
        }
        if segue.identifier == "JPStepTwoToStepThree"{
            if let vc = segue.destination as? JobPostTimeViewController{
                vc.jobPost = self.jobPost
            }
            
        }
        if segue.identifier == "EditDateToPostJob"{
            if let vc = segue.destination as? ActualFinalizeViewController{
                vc.jobCoord = self.jobCoord
                vc.jobPost = self.jobPostEdit
                //vc.timeDifference = Int(jobPostEdit.jobDuration!)!
                vc.toolCount = self.toolCount
            }
        }
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
