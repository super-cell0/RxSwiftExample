//
//  PhotoWriter.swift
//  RxSwiftExample
//
//  Created by mac on 2023/7/25.
//

import UIKit
import Photos
import RxSwift


class PhotoWriter {
    enum MyError: Error {
        case notSavePhoto
    }
    
    ///把拼接的图片保存到本地相册
    static func save(image: UIImage) -> Single<String> {
        return Single.create { observer in
            
            var savedAssetID: String?
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                savedAssetID = request.placeholderForCreatedAsset?.localIdentifier
                
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success, let id = savedAssetID {
                        observer(.success(id))
                    } else {
                        observer(.failure(error ?? MyError.notSavePhoto))
                    }
                }
            }

            return Disposables.create()
        }
    }
    
//    static func save(_ image: UIImage) -> Observable<String> {
//      return Observable.create({ observer in
//        var savedAssetId: String?
//        PHPhotoLibrary.shared().performChanges({
//          let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
//          savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
//        }, completionHandler: { success, error in
//          DispatchQueue.main.async {
//            if success, let id = savedAssetId {
//              observer.onNext(id)
//              observer.onCompleted()
//            } else {
//                observer.onError(error ?? MyError.notSavePhoto)
//            }
//          }
//        })
//        return Disposables.create()
//      })
//    }

    
    
}
