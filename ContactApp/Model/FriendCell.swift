/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Contacts

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!{
        didSet{
            bgView.layer.cornerRadius = 5
        }
    }
    @IBOutlet private weak var contactNameLabel: UILabel!
    @IBOutlet private weak var contactEmailLabel: UILabel!
    @IBOutlet private weak var contactImageView: UIImageView! {
        didSet {
            contactImageView.layer.masksToBounds = true
            contactImageView.layer.cornerRadius = 22.0
        }
    }
    
    var contactDetail: ContactDetail?{
        didSet{
            configureCell()
        }
    }
    
    var lblNameInitialize: UILabel?{
        didSet{
            
        }
    }
    
    private func configureCell() {
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        guard let detail = contactDetail else { return }
        contactNameLabel.text = (detail.details?.givenName ?? "") + " " + (detail.details?.familyName ?? "")
        contactEmailLabel.text = (detail.details?.emailAddresses.first?.value ?? "") as String
        bgView.addShadow()
        if let data = detail.details?.imageData{
            contactImageView.image = UIImage(data: data)
        }else{
            //contactImageView.image = UIImage(named: "user")
            contactImageView.setImageWith("\(String(describing: detail.details?.givenName.first ?? "\0")) \(String(describing: detail.details?.familyName.first ?? "\0"))", color: .lightGray, circular: true)
        }
        //contactImageView.image = friend.profilePicture ?? UIImage(named: "PlaceholderProfilePic")
    }
}
