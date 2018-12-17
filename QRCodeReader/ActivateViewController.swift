//
//  ActivateViewController.swift
//  QRCodeReader
//
//  Created by Nestor Qin on 1/13/18.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import SwiftHTTP

class ActivateViewController: UIViewController{

    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var serialLabel: UILabel!
    var serial:String?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if (serial != nil) {
            serialLabel.text = "序列号： \(serial!)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ActivateViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // send activate to server
    @IBAction func active(_ sender: Any) {
        let loadingAlert = UIAlertController(title: nil, message: "激活中，请稍等...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        self.present(loadingAlert, animated: true, completion: nil)
        let url = "https://vote.cssauw.org/scanapp/activate"
        print("\(url)")
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        let urlForFile = URL(fileURLWithPath: paths.appending("/secret.txt"))
        var secret: String?
        do {
            secret = try String(contentsOf: urlForFile, encoding: .utf8)
        } catch let err {
            print(err)
        }
        if (secret != nil) {
            let params = ["secret": "\(secret!)", "serial_number": "\(self.serial!)", "comment": "\(self.textField.text!)"]
            print(secret!)
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
}
