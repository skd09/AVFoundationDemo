//
//  CameraController.swift
//  AvFoundationDemo
//
//  Created by Work on 2021-01-15.
//

import Foundation
import AVFoundation
import UIKit


class CameraController : NSObject{
    
    var captureSession : AVCaptureSession?
    var currentCameraPosition : CameraPosition?
    
    var frontCamera : AVCaptureDevice?
    var frontCameraInput : AVCaptureDeviceInput?
    
    var rearCamera : AVCaptureDevice?
    var rearCameraInput : AVCaptureDeviceInput?
    
    var photoOutput : AVCapturePhotoOutput?
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var previewLayer : AVCaptureVideoPreviewLayer?
    var photoCaptureCompletionBlock : ((UIImage?, Error?) -> Void)?
    
}

extension CameraController{
    enum CameraPosition {
        case front
        case rear
    }
    
    enum CameraControllerError : Swift.Error{
        case unknown
        case noCameraAvailable
        case captureSessionIsMissing
        case captureSesssionAlreadyRunning
    }
}

extension CameraController{
    
    func prepare(completionHandler: @escaping(Error?) -> Void){
        
        func createCaptureSession(){
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws{
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            
            let cameras = session.devices.compactMap{$0}
            
            for camera in cameras{
                print(camera)
                if camera.position == .front{
                    self.frontCamera = camera
                }
                
                if camera.position == .back{
                    self.rearCamera = camera
                }
                
                try camera.lockForConfiguration()
                //camera.focusMode = .autoFocus
                camera.unlockForConfiguration()
                
            }
        }
        
        func configureDeviceInputs() throws{
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            if let rearCamera = self.rearCamera{
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!){
                   captureSession.addInput(self.rearCameraInput!)
                }
                
                self.currentCameraPosition = .rear
            }
            
            else{
                throw CameraControllerError.noCameraAvailable
            }
        }
        
        func configurePhotoOutput() throws{
            
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])],completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!){
                captureSession.startRunning()
            }
            
            if captureSession.canAddOutput(self.photoOutput!){
                captureSession.addOutput(self.photoOutput!)
            }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do{
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }catch{
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
        
    }
    
    func displayPreview(on view: UIView) throws{
        guard let captureSession = self.captureSession, captureSession.isRunning else{
            throw CameraControllerError.captureSessionIsMissing
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        
        self.previewLayer?.frame = view.frame
    }
    
    func captureImage(completion: @escaping(UIImage?, Error?) -> Void){
        
        guard let captureSession = self.captureSession, captureSession.isRunning else{
            completion(nil, CameraControllerError.captureSessionIsMissing);
            return
        }
        
        let settings = AVCapturePhotoSettings()
//        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
        
    }
    
}

extension CameraController : AVCapturePhotoCaptureDelegate{
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let photoData = photo.fileDataRepresentation(){
            if let error = error {
                self.photoCaptureCompletionBlock?(nil, error)
            }else if let photoImage = UIImage(data: photoData){
                self.photoCaptureCompletionBlock?(photoImage, nil)
            }
        }
    }
}
