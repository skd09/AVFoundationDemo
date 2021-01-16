//
//  CameraViewController.swift
//  AvFoundationDemo
//
//  Created by Work on 2021-01-15.
//

import UIKit
import Photos

class CameraViewController : UIViewController {
    
    let cameraController = CameraController()
    
    @IBOutlet weak var capturePreview: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var btnCapture: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraController.prepare{(error) in
            if let error = error{
                print(error)
            }
            
            
            try? self.cameraController.displayPreview(on: self.capturePreview)
        }
    }
    
    
}
extension CameraViewController{
    @IBAction func onCaptureClicked(_ sender: Any) {
        cameraController.captureImage(completion: {(image, error) in
            
            /*Code for storing the image in Photo Gallery*/
            guard let image = image else {
                print("Image Capture Error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            /*Code for storing the image in Photo Gallery*/
            
            self.capturedImage.image = image
        })
    }
}
