//
//  AddNewContactViewController.swift
//  ContactApp
//
//  Created by Aabid Khan on 01/12/20.
//  Copyright © 2020 Aabid Khan. All rights reserved.
//

import UIKit
import AddressBook
import Contacts

class AddNewContactViewController: UIViewController {

    //MARK: - Variables and IBOutlets -
    var contact: CNContact?{
        didSet{
            navigationItem.title = "Edit Contact"
        }
    }
    
    @IBOutlet private weak var imgProfile: UIImageView!{
        didSet{
            imgProfile.contentMode = .scaleAspectFill
            imgProfile.layer.masksToBounds = true
            imgProfile.layer.cornerRadius = 50
            imgProfile.layer.borderWidth = 0.5
            imgProfile.layer.borderColor = UIColor.lightGray.cgColor
            imgProfile.image = UIImage(named: "user")
        }
    }
    
    @IBOutlet private weak var txtFname: CustomTextField!{
        didSet{
            txtFname.placeholder = "First Name"
            txtFname.setIcon(UIImage(named: "user_icon")!)
        }
    }
    
    @IBOutlet private weak var txtLname: CustomTextField!{
        didSet{
            txtLname.placeholder = "Last Name (optional)"
            txtLname.setIcon(UIImage(named: "user_icon")!)
        }
    }
    
    @IBOutlet private weak var txtPhone: CustomTextField!{
        didSet{
            txtPhone.placeholder = "Phone Number"
            txtPhone.keyboardType = .phonePad
            txtPhone.setIcon(UIImage(named: "phone-call")!)
        }
    }
    
    @IBOutlet private weak var txtEmail: CustomTextField!{
        didSet{
            txtEmail.placeholder = "Email Address (optional)"
            txtEmail.keyboardType = .emailAddress
            txtEmail.setIcon(UIImage(named: "mail")!)
        }
    }
    
    @IBOutlet private weak var btnEditPhoto: UIButton!{
        didSet{
            btnEditPhoto.setTitle(contact == nil ? "Add Photo" : "Edit Photo", for: .normal)
        }
    }
    
    private let appName: String = {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String ?? "-"
    }()
    
    fileprivate lazy var imagePickerViewController: UIImagePickerController = {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        return imgPicker
    }()
    
    fileprivate  var selectedImage: UIImage?{
        didSet{
            self.btnEditPhoto.setTitle("Edit Photo", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cn = contact{
            preFillData(contact: cn)
        }
    }
    
    //MARK: - Functions -
    
    private func preFillData(contact: CNContact){
        txtFname.text = contact.givenName
        txtLname.text = contact.familyName
        txtEmail.text = (contact.emailAddresses.first?.value ?? "") as String
        txtPhone.text = contact.phoneNumbers.first?.value.stringValue
        if let data = contact.imageData{
            imgProfile.image = UIImage(data: data)
        }else{
            imgProfile.setImageWith("\(String(describing: contact.givenName.first ?? "\0")) \(String(describing: contact.familyName.first ?? "\0"))", color: .lightGray, circular: true)
        }
    }
    
    private func goBack(){
        navigationController?.popViewController(animated: true)
    }
    
    private func checkMandatoryFields(){
        if txtFname.text == "" {
            popupAlert(title: self.getAppName(), message: "Please enter first name", actionDetails: [AlertActionDetails(title: "Ok", style: .default)], actions: [{ action1 in
                
                }])
            return
        }
        
        if txtPhone.text == "" {
            popupAlert(title: self.getAppName(), message: "Please enter phone number", actionDetails: [AlertActionDetails(title: "Ok", style: .default)], actions: [{ action1 in
            
            }])
            return
        }
        
        addUserToAddressBook()
    }
    
    private func addUserToAddressBook(){
        let contact =  self.contact != nil ? self.contact!.mutableCopy() as! CNMutableContact : CNMutableContact()
        
        // Contact name
        contact.givenName = txtFname.text ?? ""
        contact.familyName = txtLname.text ?? ""
        if let img = self.selectedImage{
            contact.imageData = img.pngData()
        }
        // Contact Email addresses
        let workEmailAddress = CNLabeledValue(label: CNLabelWork, value: (txtEmail.text ?? "") as NSString)
        contact.emailAddresses = [workEmailAddress]
        
        // Contact Phone numbers
        contact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberiPhone,
            value:CNPhoneNumber(stringValue: txtPhone.text ?? "")), CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: txtPhone.text ?? ""))]
        
        // Saving the newly created contact
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        var actionStr: String?
        if let _ = self.contact{
            saveRequest.update(contact)
            actionStr = "updated"
        }else{
            saveRequest.add(contact, toContainerWithIdentifier:nil)
            actionStr = "saved"
        }
        do{
            try store.execute(saveRequest)
            popupAlert(title: self.getAppName(), message: "Contact \(actionStr ?? "") successfully", actionDetails: [AlertActionDetails(title: "Ok", style: .default)], actions: [{ action1 in
                self.goBack()
                }])
        }catch let err {
            print("failed to create contact \(err.localizedDescription)")
        }
        
    }
    
    fileprivate func dismissImagePickerVC(){
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Actions -
    
    @IBAction private func btnEditImageTapped(_ sender: UIButton) {
        
        popupAlert(title: "Select Image", message: "", actionDetails: [AlertActionDetails(title: "Camera", style: .default),AlertActionDetails(title: "Photo Library", style: .default),AlertActionDetails(title: "Cancel", style: .destructive)], actions: [{cameraAction in
            self.imagePickerViewController.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
            self.present(self.imagePickerViewController, animated: true, completion: nil)
            },{photoLibraryAction in
                self.imagePickerViewController.sourceType = .photoLibrary
                self.present(self.imagePickerViewController, animated: true, completion: nil)
            },{cancelAction in }],preferredStyle: .actionSheet)
    }
    
    @IBAction private func btnSaveTapped(_ sender: UIBarButtonItem){
        
        checkMandatoryFields()
    }
}

//MARK: - Imagepicker delegate methods -
extension AddNewContactViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismissImagePickerVC()
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        imgProfile.image = selectedImage
        self.selectedImage = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissImagePickerVC()
    }
}
