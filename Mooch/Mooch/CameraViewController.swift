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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceType = .camera
        cameraCaptureMode = .photo
        allowsEditing = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.slide)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.slide)
    }
}
