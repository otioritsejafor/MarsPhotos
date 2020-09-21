//
//  MarsCell.swift
//  MarsPhotos
//
//  Created by Oti Oritsejafor on 6/23/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import UIKit
import SDWebImage

enum PhotoImageState {
  case new, failed
}


class PhotoCell: UICollectionViewCell {
    // MARK: Properties
    
    var photoData: Photo? {
        didSet {
            configure()
        }
    }
    
    var imageState = PhotoImageState.new
    
    let cellImageView: UIImageView = {
        let iv = UIImageView()
        let sv = SDAnimatedImageView()
        iv.sd_imageIndicator = SDWebImageActivityIndicator.gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.text = "Loading..."
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(cellImageView)
        cellImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 8)
        cellImageView.anchor(right: rightAnchor, paddingRight: 8)
        //cellImageView.frame.insetBy(dx: 2, dy: 0)
        
        cellImageView.setDimensions(height: 180, width: frame.width)
        cellImageView.layer.cornerRadius = 34 / 2
       // cellImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(infoLabel)
        infoLabel.anchor(top: cellImageView.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        infoLabel.topAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: 8).isActive = true
        infoLabel.leftAnchor.constraint(equalTo: leftAnchor,constant: 8 ).isActive = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helpers
    func configure() {
        guard let photoData = photoData else { return }
        infoLabel.text = "\(photoData.earthDate) on a \(photoData.camera.name)"
    }
    
    
}
