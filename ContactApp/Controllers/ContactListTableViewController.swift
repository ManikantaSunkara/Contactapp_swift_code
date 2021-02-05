//
//  ContactListTableViewController.swift
//  ContactApp
//
//  Created by Aabid Khan on 30/11/20.
//  Copyright © 2020 Aabid Khan. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
class ContactListTableViewController: UITableViewController, CNContactPickerDelegate {

    private let viewModelObj = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchContacts()
    }
    
    //MARK: - Add Contact -
    @IBAction private func addFriends(sender: UIBarButtonItem) {
        goToAddEditVC()
    }
    
    private func goToAddEditVC(_ contact: CNContact? = nil){
        guard let vc = storyboard?.instantiateViewController(identifier: "AddNewContactViewController") as? AddNewContactViewController else { return }
        if let cn = contact{
            vc.contact = cn
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Fetch Contact List
    private func fetchContacts(){
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let err = error{
                print("Failed to fetch contacts\n\(err.localizedDescription)")
                return
            }
            
            if granted{
                self.viewModelObj.dataStore.removeAll()
                var keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactImageDataKey] as [CNKeyDescriptor]
                keys.append(CNContactViewController.descriptorForRequiredKeys())
                let request = CNContactFetchRequest(keysToFetch: keys)
                do {
                    try store.enumerateContacts(with: request) { (contactObj, stopEnumarating) in
                        let obj = ContactDetail(details: contactObj)
                        self.viewModelObj.dataStore.append(obj)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                } catch let err {
                    print("Failed to enumerate contacts: \(err.localizedDescription)")
                }
                
            }else{
                
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.viewModelObj.dataStore.count
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            self.goToAddEditVC(self.viewModelObj.dataStore[indexPath.row].details ?? nil)
        }
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, handler) in
            self.popupAlert(title: self.getAppName(), message: "Are you sure to delete this contact?", actionDetails: [AlertActionDetails(title: "Yes", style: .default),AlertActionDetails(title: "Cancel", style: .destructive)], actions: [{yesAction in
                    let store = CNContactStore()
                    let saveRequest = CNSaveRequest()
                    saveRequest.delete(self.viewModelObj.dataStore[indexPath.row].details!.mutableCopy() as! CNMutableContact)
                    do{
                        try store.execute(saveRequest)
                        self.fetchContacts()
                        self.popupAlert(title: self.getAppName(), message: "Contact deleted successfully", actionDetails: [AlertActionDetails(title: "Ok", style: .default)], actions: [{action1 in
                            },{action2 in}])
                    }catch let err {
                        print("failed to create contact \(err.localizedDescription)")
                    }
                },{cancelAction in}])
        }
        
        editAction.backgroundColor = .lightGray
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
      
      if let cell = cell as? FriendCell {
        let detail = viewModelObj.dataStore[indexPath.row]
        cell.contactDetail = detail
      }
      return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        let contact = viewModelObj.dataStore[indexPath.row].details
        // 2
        let contactViewController = CNContactViewController(for: contact!)
        //(forUnknownContact: contact!)
        contactViewController.hidesBottomBarWhenPushed = true
        contactViewController.delegate = self
        contactViewController.allowsEditing = false
        contactViewController.allowsActions = false
        // 3
        navigationController?.pushViewController(contactViewController, animated: true)
    }
}
extension ContactListTableViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.navigationController?.popViewController(animated: true)
    }
}
