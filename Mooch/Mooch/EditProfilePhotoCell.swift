//
//  EditProfilePhotoCell.swift
//  Mooch
//
//  Created by adam on 10/10/16.
//  Copyright © 2016 cse498. All rights reserved.
//

import UIKit

protocol EditProfilePhotoCellDelegate: class {
    
    func editProfilePhotoCellDidReceiveEditAction(_ editProfilePhotoCell: EditProfilePhotoCell)
}

class EditProfilePhotoCell: UITableViewCell, EditProfileField {
    
    enum State {
        case hasPhoto
        case noPhoto
    }
    
    static let Identifier = "EditProfilePhotoCell"
    static let EstimatedHeight: CGFloat = 220
    
    @IBOutlet private weak var photoAddingView: PhotoAddingView!
    @IBOutlet private weak var editPhotoButton: UIButton!
    @IBOutlet private weak var bottomSeperator: UIView!
    
    private var state: State = .noPhoto {
        didSet {
            updateUI(forState: state)
        }
    }
    
    var fieldType: EditProfileConfiguration.FieldType!
    weak var delegate: EditProfilePhotoCellDelegate!
    
    @IBAction func onEditPhotoButton() {
        delegate.editProfilePhotoCellDidReceiveEditAction(self)
    }
    
    func set(photo: UIImage?) {
        let newState: State = (photo == nil) ? .noPhoto : .hasPhoto
        state = newState
        
        photoAddingView.photo = photo
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        photoAddingView.delegate = self
        
        bottomSeperator.backgroundColor = ThemeColors.formSeperator.color()
        
        editPhotoButton.setImage(#imageLiteral(resourceName: "editFile").imageWithColor(color: ThemeColors.moochRed.color()), for: .normal)
        
        updateUI(forState: .noPhoto)
    }
    
    
    private func updateUI(forState state: State) {
        switch state {
        case .noPhoto:
            editPhotoButton.isHidden = true
            
        case .hasPhoto:
            editPhotoButton.isHidden = false
        }
    }
}

extension EditProfilePhotoCell: PhotoAddingViewDelegate {
    
    func photoAddingViewReceivedAddPhotoAction(_ photoAddingView: PhotoAddingView) {
        delegate.editProfilePhotoCellDidReceiveEditAction(self)
    }
}
