//
//  CameraViewController.swift
//  Mooch
//
//  Created by adam on 9/30/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

//Class for using the camera to take a picture
class CameraViewController: UIImagePickerController {
    
    enum Mode {
        case camera
        case photoLibrary
    }
    
    var mode: Mode = .camera
    
    func setStatusBar(hidden: Bool) {
        let animation: UIStatusBarAnimation = hidden ? .slide : .none
        UIApplication.shared.setStatusBarHidden(hidden, with: animation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .camera:
            sourceType = .camera
            cameraCaptureMode = .photo
            
        case .photoLibrary:
            sourceType = .photoLibrary
        }
        
        allowsEditing = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setStatusBar(hidden: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        setStatusBar(hidden: false)
    }
}
