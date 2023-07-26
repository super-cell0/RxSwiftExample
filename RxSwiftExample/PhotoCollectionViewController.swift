//
//  PhotoCollectionViewController.swift
//  RxSwiftExample
//
//  Created by mac on 2023/7/24.
//

import UIKit
import RxSwift
import Photos



class PhotoCollectionViewController: UICollectionViewController {
    
    ///显示所选照片
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    ///事件
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    
    private lazy var photos = PhotoCollectionViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    
    private lazy var thumbnailSize: CGSize = {
      let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
      return CGSize(width: cellSize.width * UIScreen.main.scale,
                    height: cellSize.height * UIScreen.main.scale)
    }()
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        selectedPhotosSubject.onCompleted()
    }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset =  photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellID", for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize , contentMode: .aspectFill, options: nil) { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.photoImageView.image = image
            }
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell { cell.flash() }
        //使用info字典来检查图像是缩略图还是资产的完整版本。
        //imageManager.requestImage(...)将为每个大小调用该闭包一次。
        //如果收到全尺寸图像，您]可以调用onNext(_)，并向其提供完整照片
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { [weak self] image, info in
            guard let image = image,
                  let info = info else { return }

            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as?
              Bool, !isThumbnail {
              self?.selectedPhotosSubject.onNext(image)
            }

        }
    }


}

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.bounds.width - 20 - 8) / 3
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
