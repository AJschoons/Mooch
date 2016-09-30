//
//  PhotoAddingView.swift
//  Mooch
//
//  Created by adam on 9/27/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol PhotoAddingViewDelegate: class {
    func photoAddingViewReceivedAddPhotoAction(_ photoAddingView: PhotoAddingView)
    func photoAddingViewReceivedDeletePhotoAction(_ photoAddingView: PhotoAddingView)
}

//View for adding, changing, and displaying a photo
//Intended to be a square
//http://stackoverflow.com/questions/9251202/how-do-i-create-a-custom-ios-view-class-and-instantiate-multiple-copies-of-it-i
class PhotoAddingView: UIView {
    
    private enum State {
        case noPhoto
        case hasPhoto
    }
    
    @IBOutlet var view: UIView!
    
    weak var delegate: PhotoAddingViewDelegate!
    
    var photo: UIImage? {
        didSet {
            photoImageView.image = photo
            state = photo == nil ? .noPhoto : .hasPhoto
        }
    }
    
    @IBAction func onAddPhotoButton() {
        delegate.photoAddingViewReceivedAddPhotoAction(self)
    }
    
    @IBAction func onDeletePhotoButton() {
        photo = nil
        delegate.photoAddingViewReceivedDeletePhotoAction(self)
    }
    
    @IBOutlet private weak var photoImageView: RoundedImageView!
    @IBOutlet private weak var addPhotoButton: RoundedButton!
    @IBOutlet private weak var deletePhotoButton: UIButton!
    
    private var state: State {
        didSet {
            updateUI(forState: state)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        state = .noPhoto
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("PhotoAddingView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
        
        updateUI(forState: .noPhoto)
    }
    
    private func updateUI(forState state: State) {
        switch state {
        case .noPhoto:
            photoImageView.isHidden = true
            addPhotoButton.isHidden = false
            deletePhotoButton.isHidden = true
        case  .hasPhoto:
            photoImageView.isHidden = false
            addPhotoButton.isHidden = true
            deletePhotoButton.isHidden = false
        }
    }
}
