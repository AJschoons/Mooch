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
}

//View for adding, changing, and displaying a photo
//Intended to be a square
//http://stackoverflow.com/questions/9251202/how-do-i-create-a-custom-ios-view-class-and-instantiate-multiple-copies-of-it-i
class PhotoAddingView: UIView {
    
    enum State {
        case noPhoto
        case hasPhoto
    }
    
    @IBOutlet var view: UIView!
    
    weak var delegate: PhotoAddingViewDelegate!
    
    //Use this variable to update and change the state
    var photo: UIImage? {
        didSet {
            photoImageView.image = photo
            state = photo == nil ? .noPhoto : .hasPhoto
        }
    }
    
    @IBAction func onAddPhotoButton() {
        delegate.photoAddingViewReceivedAddPhotoAction(self)
    }
    
    @IBOutlet private weak var photoImageView: CircleImageView!
    @IBOutlet private weak var addPhotoButton: RoundedButton!
    
    private var state: State {
        didSet {
            updateUI(forState: state)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addPhotoButton.cornerRadius = view.bounds.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        state = .noPhoto
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("PhotoAddingView", owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
        
        setup()
        
        updateUI(forState: .noPhoto)
    }
    
    private func setup() {
        photoImageView.borderColor = ThemeColors.border.color()
        photoImageView.backgroundColor = ThemeColors.moochGray.color()
        photoImageView.borderWidth = 1.0
        
        addPhotoButton.borderColor = ThemeColors.moochGray.color()
        addPhotoButton.borderWidth = 1.0
    }
    
    private func updateUI(forState state: State) {
        switch state {
        case .noPhoto:
            addPhotoButton.backgroundColor = ThemeColors.moochGray.color()
            addPhotoButton.setImage(#imageLiteral(resourceName: "add").imageWithColor(color: ThemeColors.moochYellow.color()), for: .normal)
            
        case .hasPhoto:
            addPhotoButton.backgroundColor = UIColor.clear
            addPhotoButton.setImage(nil, for: .normal)
        }
    }
}
