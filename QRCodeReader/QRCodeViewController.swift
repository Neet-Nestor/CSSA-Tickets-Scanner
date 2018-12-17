//
//  QRCodeViewController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {

    var fileManager: FileManager?
    
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var dog: UIImageView!
    @IBOutlet weak var activateBtn: UIButton!
    @IBOutlet weak var secretBtn: UIButton!
    @IBAction func secretBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "密匙更改", message: "请输入密匙", preferredStyle: .alert)
        var success: Bool = true
        var failureMsg: String = ""
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            do {
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
                print(paths)
                let destinationURLForFile = URL(fileURLWithPath: paths.appending("/secret.txt"))
                try textField.text!.write(to: destinationURLForFile, atomically: false, encoding: .utf8)
                success = true
            } catch let error {
                failureMsg = "\(error)"
                success = false
                print(error)
            }
            if (success) {
                let alert = UIAlertController(title: "更改完成", message: "密匙更改成功！", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "更改未完成", message: "更改过程中出现错误！错误信息：\(failureMsg)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let fileManager = FileManager.default
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.label.numberOfLines = 0
        self.label.minimumScaleFactor = 0.1
        self.label.baselineAdjustment = .alignCenters
        self.label.textAlignment  = .center
    }
    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

}
