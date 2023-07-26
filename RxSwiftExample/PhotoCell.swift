//
//  PhotoCell.swift
//  RxSwiftExample
//
//  Created by mac on 2023/7/24.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    var representedAssetIdentifier: String?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    func flash() {
        photoImageView.alpha = 0
        setNeedsDisplay()
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.photoImageView.alpha = 1
        }
    }
}
