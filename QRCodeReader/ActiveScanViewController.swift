//
//  ActiveScanViewController.swift
//  QRCodeReader
//
//  Created by Nestor Qin on 1/13/18.
//  Copyright © 2018 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftHTTP

class ActiveScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Get the back-facing camera for capturing videos
        // let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)  else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the CaptureSession (I add it myself)
            if (captureSession == nil) {
                captureSession = AVCaptureSession()
            }
            
            // Set the input device on the capture session.
            captureSession!.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession!.startRunning()
            
            // Move the message label and top bar to the front
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topbar)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func manulInput(_ sender: Any) {
        let inputAlert = UIAlertController(title: "手动输入", message: "请手动输入票的票号（例如\"CSSAFORV\"）", preferredStyle: .alert)
        inputAlert.addTextField { (textField) in
            textField.text = ""
        }
        inputAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        inputAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let urlInput = inputAlert.textFields![0].text?.uppercased() // Force unwrapping because we know it exists.
            print("Text field: \(urlInput)")
            if (urlInput?.range(of: "^[A-Z]{8}$", options: .regularExpression) != nil) {
                let activeVC = self.storyboard?.instantiateViewController(withIdentifier: "activateVC") as! ActivateViewController
                activeVC.serial = urlInput
                self.present(activeVC, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "错误", message: "输入票号格式错误", preferredStyle: .alert)
                
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                    self.resetScan()
                })
                
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            }
        })
        self.present(inputAlert, animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        captureSession?.stopRunning()
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                let urlFound = metadataObj.stringValue
//                let loadingAlert = UIAlertController(title: nil, message: "读取信息中，请稍等...", preferredStyle: .alert)
//
//                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
//                loadingIndicator.hidesWhenStopped = true
//                loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//                loadingIndicator.startAnimating();
//
//                loadingAlert.view.addSubview(loadingIndicator)
//                present(loadingAlert, animated: true, completion: nil)
                if (urlFound!.hasPrefix("https://vote.cssauw.org/qr_code/")) {
//                    HTTP.GET(urlFound!) { response in
//                        loadingAlert.dismiss(animated: false, completion: nil)
//                        if let err = response.error {
//                            print("error: \(err.localizedDescription)")
//                            //1. Create the alert controller.
//                            let alert = UIAlertController(title: "错误", message: "网络连接错误，\(err.localizedDescription)", preferredStyle: .alert)
//
//                            // 3. Grab the value from the text field, and print it when the user clicks OK.
//                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//
//                            // 4. Present the alert.
//                            self.present(alert, animated: true, completion: nil)
//                            return //also notify app of failure as needed
//                        }
//                        print("opt finished: \(response.description)")
                        let activeVC = self.storyboard?.instantiateViewController(withIdentifier: "activateVC") as! ActivateViewController
                        activeVC.serial = "\(urlFound!.suffix(8))"
                        self.present(activeVC, animated: true, completion: nil)
                        //print("data is: \(response.data)") access the response of the data with response.data
//                    }
                } else {
                    //1. Create the alert controller.
                    let alert = UIAlertController(title: "错误", message: "二维码错误", preferredStyle: .alert)

                    // 3. Grab the value from the text field, and print it when the user clicks OK.
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                        self.resetScan()
                    })

                    // 4. Present the alert.
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func resetScan() {
        captureSession?.startRunning()
        qrCodeFrameView?.frame.size = CGSize(width: 0, height: 0)
    }
    
    @IBAction func unwindToActiveScan(segue: UIStoryboardSegue) {
        resetScan()
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

