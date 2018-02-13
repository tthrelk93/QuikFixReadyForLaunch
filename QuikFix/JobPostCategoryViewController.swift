//
//  JobPostCategoryViewController.swift
//  QuikFix
//
//  Created by Thomas Threlkeld on 9/9/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import CoreLocation

class JobPostCategoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate{
    
    var jobPost = JobPost()
    var toolsArray = [String]()
    
    @IBOutlet weak var hedgeClippers: UIButton!
    @IBOutlet weak var leafBlower: UIButton!
    @IBOutlet weak var weedWacker: UIButton!
    var edit = Bool()
    var jobPostEdit = JobPost()
    @IBAction func wackerPressed(_ sender: Any) {
        var button = (sender as! UIButton)
        
    
        
        
        
        if button.isSelected == true{
            button.isSelected = false
            toolsArray.remove(at: toolsArray.index(of: (button.titleLabel?.text)!)!)
        } else {
            button.isSelected = true
            toolsArray.append((button.titleLabel?.text)!)
        }

    }
    
    @IBAction func leafBlowerPressed(_ sender: Any) {
        var button = (sender as! UIButton)
        
        
        
        if button.isSelected == true{
            button.isSelected = false
            toolsArray.remove(at: toolsArray.index(of: (button.titleLabel?.text)!)!)
        } else {
            button.isSelected = true
            toolsArray.append((button.titleLabel?.text)!)
        }

    }
    
    @IBAction func hedgeClippersPressed(_ sender: Any) {
        var button = (sender as! UIButton)
        
        
        
        if button.isSelected == true{
            button.isSelected = false
            toolsArray.remove(at: toolsArray.index(of: (button.titleLabel?.text)!)!)
        } else {
            button.isSelected = true
            toolsArray.append((button.titleLabel?.text)!)
        }

    }
    
    @IBAction func toolPressed(_ sender: Any) {
        var button = (sender as! UIButton)
        
        
        
        if button.isSelected == true{
            button.isSelected = false
            toolsArray.remove(at: toolsArray.index(of: (button.titleLabel?.text)!)!)
        } else {
            button.isSelected = true
            toolsArray.append((button.titleLabel?.text)!)
        }
    }
    
    @IBOutlet weak var chargeAmountLabel: UILabel!
    
    @IBOutlet weak var customTechTextView: UITextView!
    @IBAction func continuePressed(_ sender: Any) {
        
        if categoryList1[categoryPicker.selectedRow(inComponent: 0)] != "Select a Category" {
            
            if categoryList1[categoryPicker.selectedRow(inComponent: 0)] == "Moving(Home-To-Home)"{
                if !pickupLocationTF.hasText || !dropoffLocationTF.hasText{
                    let alert = UIAlertController(title: "Missing Field", message: "You must designate pickup and dropoff locations when creating a moving(Home-ToHome) job.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    jobPost.pickupLocation = self.pickupLocationTF.text
                    jobPost.dropOffLocation = self.dropoffLocationTF.text
                    chargeAmountLabel.text = "There is a $10 charge per truck."
                    toolButton.setTitle("1 Truck", for: .normal)
                    toolButton.setTitle("1 Truck", for: .selected)
                    weedWacker.setTitle("2 Trucks", for: .normal)
                    weedWacker.setTitle("2 Trucks", for: .selected)
                    weedWacker.isHidden = false
                    leafBlower.isHidden = true
                    hedgeClippers.isHidden = true
                    if toolSelectView.isHidden == true{
                        customTechTextView.isHidden = true
                        toolSelectView.isHidden = false
                        return
                    } else {
                        jobPost.tools = self.toolsArray
                    }
                }
                
                
                
            } else if categoryList1[categoryPicker.selectedRow(inComponent: 0)] == "Lawn Care"{
                weedWacker.isHidden = false
                leafBlower.isHidden = false
                hedgeClippers.isHidden = false
                chargeAmountLabel.text = "There is a $5 charge if you need tools supplied."
                
                weedWacker.setTitle("Weed Wacker", for: .normal)
                weedWacker.setTitle("Weed Wacker", for: .selected)
                
                if toolSelectView.isHidden == true{
                    toolSelectView.isHidden = false
                    customTechTextView.isHidden = true
                    return
                } else {
                    jobPost.tools = self.toolsArray
                }

            
            }
            else if categoryList1[categoryPicker.selectedRow(inComponent: 0)] == "Leaf Blowing" {
                toolButton.setTitle("Leaf Blower", for: .normal)
                toolButton.setTitle("Leaf Blower", for: .selected)
                chargeAmountLabel.text = "There is a $5 charge if you need tools supplied."
                weedWacker.isHidden = true
                leafBlower.isHidden = true
                hedgeClippers.isHidden = true
                if toolSelectView.isHidden == true{
                    toolSelectView.isHidden = false
                    customTechTextView.isHidden = true
                    return
                } else {
                    jobPost.tools = self.toolsArray
                }

            
            } else if categoryList1[categoryPicker.selectedRow(inComponent: 0)] == "Custom" {
                if customTechTextView.text == "Enter custom job description here." && self.toolSelectView.isHidden == false {
                    let alert = UIAlertController(title: "Missing Field", message: "You must give a description of the job that you need done. ", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                toolButton.isHidden = true
                weedWacker.isHidden = true
                leafBlower.isHidden = true
                hedgeClippers.isHidden = true
                chargeAmountLabel.isHidden = true
                if toolSelectView.isHidden == true{
                    toolSelectView.isHidden = false
                    customTechTextView.text = "Enter custom job description here."
                    customTechTextView.delegate = self
                    customTechTextView.isHidden = false
                    return
                } else {
                    jobPost.customTechDetails = customTechTextView.text
                }
                
            } else if categoryList1[categoryPicker.selectedRow(inComponent: 0)] == "Tech Help" {
                if customTechTextView.text == "What technology problem can we help you with?"{
                    let alert = UIAlertController(title: "Missing Field", message: "You must give a description of the technology help that you need done. ", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                toolButton.isHidden = true
                weedWacker.isHidden = true
                leafBlower.isHidden = true
                hedgeClippers.isHidden = true
                chargeAmountLabel.isHidden = true
                if toolSelectView.isHidden == true{
                    toolSelectView.isHidden = false
                    customTechTextView.text = "What technology problem can we help you with?"
                    customTechTextView.delegate = self
                    customTechTextView.isHidden = false
                    return
                } else {
                    jobPost.customTechDetails = customTechTextView.text
                }
                
            } else {
                chargeAmountLabel.text = "There is a $5 charge if you need tools supplied."
                weedWacker.isHidden = true
                leafBlower.isHidden = true
                hedgeClippers.isHidden = true
                toolButton.titleLabel?.text = "Drill"
                toolButton.setTitle("Drill", for: .normal)
                toolButton.setTitle("Drill", for: .selected)
                if toolSelectView.isHidden == true{
                    toolSelectView.isHidden = false
                    customTechTextView.isHidden = true
                    return
                } else {
                    jobPost.tools = self.toolsArray
                }
                
            }
            
            

            
            
            
            jobPost.category1 = categoryList1[categoryPicker.selectedRow(inComponent: 0)]
            if edit == true{
            jobPostEdit.category1 = categoryList1[categoryPicker.selectedRow(inComponent: 0)]
                
            }
                
                
            //jobPost.category2 = categoryLists[categoryPicker.selectedRow(inComponent: 0)][category2Picker.selectedRow(inComponent: 0)]
                
            performSegue(withIdentifier: "JPStepOneToStepTwo", sender: self)
            
        } else {
            //present alert
            let alert = UIAlertController(title: "Missing Field", message: "You must select a category from the picker to continue.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var toolSelectView: UIView!
    @IBOutlet weak var category2Picker: UIPickerView!
    var categoryList1 = ["Select a Category", "Lawn Care", "Leaf Blowing", "Gardening", "Gutter Cleaning","Tech Help", "Installations(Electronics)", "Installations(Decorations)", "Furniture Assembly","Moving(In-Home)", "Moving(Home-To-Home)", "Hauling Away","Custom"]
   
    
    
    var categoryLists = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
       // category2Picker.delegate = self
        categoryPicker.dataSource = self
        self.jobPostEdit.tools = nil
       // category2Picker.dataSource = self
        pickupLocationTF.delegate = self
        dropoffLocationTF.delegate = self
        //categoryLists = [[""], LawnCareCategoryList, installationsCategoryList, assemblyCategoryList, movingCategoryList, [""]]

        // Do any additional setup after loading the view.
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return categoryList1.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return categoryList1[row]
        
    }
    
    @IBOutlet weak var pickupLocationTF: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var toolButton: UIButton!
    @IBOutlet weak var dropoffLocationTF: UITextField!
    //reload somewhere else b/c crashing when speed pick   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
       if categoryList1[row] == "Moving(Home-To-Home)"{
        locationLabel.text == "Select Pickup and Dropoff Locations. Note that there is a flat $10 Hauling Fee on Home-To-Home Moving jobs."
        pickupLocationTF.isHidden = false
        dropoffLocationTF.isHidden = false
        locationLabel.isHidden = false
        
        
       } else {
        pickupLocationTF.isHidden = true
        dropoffLocationTF.isHidden = true
        locationLabel.isHidden = true
        }
        if categoryList1[row] == "Lawn Care"{
            
            locationLabel.text = "Lawn Care includes: mowing, weed wacking, and hedge clipping"
            self.locationLabel.isHidden = false
        } else {
            self.locationLabel.isHidden = true
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        if textView.text == "What technology problem can we help you with?" || textView.text == "Enter custom job description here."{
            textView.text = ""
            
            
        }
    }
     let qfGreen = UIColor(colorLiteralRed: 49/255, green: 74/255, blue: 82/255, alpha: 1.0)
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.textColor = qfGreen
        if textView.text == "" || textView.text == nil{
            if categoryList1[categoryPicker.selectedRow(inComponent: 0)] == "Tech Help"{
            textView.text = "What technology problem can we help you with?"
            } else {
                textView.text = "Enter custom job description here."
            }
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
            view.endEditing(true)
            return false
        }
        else
        {
            return true
        }
    }
    var placeCoord = CLLocation()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JPStepOneToStepTwo"{
            if let vc = segue.destination as? SelectWorkerNumberViewController{
                if self.edit == false{
                vc.jobPost = self.jobPost
                } else {
                    vc.jobCoord = self.placeCoord
                    vc.jobPost = self.jobPostEdit
                    vc.timeDifference = Int(jobPostEdit.jobDuration!)!
                    vc.toolCount = self.toolsArray.count
                    vc.edit = self.edit
                }
            }
            
        }
        
        
    }
    
    /*public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        
        return false
    }*/
    var tfSelected = String()
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == pickupLocationTF{
            self.tfSelected = "pickup"
        } else {
            self.tfSelected = "dropoff"
        }
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        return false
        
    }
    
    var place: GMSPlace?

   


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   
}

extension JobPostCategoryViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        if self.tfSelected == "pickup"{
            self.pickupLocationTF.text = place.formattedAddress
            self.jobPost.pickupLocation = place.formattedAddress
        } else {
            self.dropoffLocationTF.text = place.formattedAddress
            self.jobPost.dropOffLocation = place.formattedAddress
        }
        self.place = place
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

