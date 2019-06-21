//
//  ViewController.swift
//  QRReaderDemo
//
//  Created by Simon Ng on 23/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class GetTableIdVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var noPlace = false  // there are 2 ways for this VC to appear. True if this VC appeared without choosing the place, false if firstly user picked up the place
    var idValidationCheck = SingletonStore.sharedInstance.placeIdValidation // check if user is in the right place
    
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        
        navigationController?.isNavigationBarHidden = false
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Detect all the supported bar code
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession?.startRunning()
            
            // Move the message label to the top view
            view.bringSubview(toFront: messageLabel)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch let error as NSError {
            print(error)
        }
        
    navigationController?.navigationBar.layer.insertSublayer(CALayer().setGradient(navigationController: navigationController!), at: 1)
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "Put the camera on QR code"
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.contains(metadataObj.type) {
            //        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            
            guard let stringInQrCode = metadataObj.stringValue else { return } // string, encoded in QR code
            let delimiter = "_"
            let arrayInQrCode = stringInQrCode.components(separatedBy: delimiter) // array from 2 parts - place Id and table Id
            guard arrayInQrCode.count == 2 else { return } // check that array contains both parts
            let placeIdInQrCodeString = arrayInQrCode[0] // place Id
            let tableIdInQrCodeString = arrayInQrCode[1] // table Id
            guard let placeIdInQrCode = Int(placeIdInQrCodeString),
                let tableIdInQrCode = Int(tableIdInQrCodeString) else { return } // check both values are numbers
            
            switch noPlace {
            case false :
                guard idValidationCheck == placeIdInQrCode else { return }  // compare place Id from QR code with our place Id
                SingletonStore.sharedInstance.tableID = tableIdInQrCode
                _ = self.navigationController?.popViewController(animated: true)
                break
            case true :
                SingletonStore.sharedInstance.makePlace(placeIdInQrCode)
                SingletonStore.sharedInstance.tableID = tableIdInQrCode
                self.noPlace = false
                SingletonStore.sharedInstance.qrCodeDetected = true
                _ =  self.navigationController?.popViewController(animated: true)
                break
            }
        }
    }
    
    
    @IBAction func gest(_ sender: AnyObject) {
        _ =  self.navigationController?.popViewController(animated: true)
    }
    
    
}

