//
//  ExtensionAll.swift
//  RxSwiftExample
//
//  Created by mac on 2023/7/24.
//

import Foundation
import UIKit
import RxSwift

extension Array where Element == UIImage {
    
    func collage(size: CGSize) -> UIImage {
        let rows = self.count < 3 ? 1 : 2
        let columns = Int(round(Double(self.count) / Double(rows)))
        let tileSize = CGSize(width: round(size.width / CGFloat(columns)),
                               height: round(size.height) / CGFloat(rows))
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        for (index, image) in self.enumerated() {
            image.scaled(newSize: tileSize).draw(at: CGPoint(
              x: CGFloat(index % columns) * tileSize.width,
              y: CGFloat(index / columns) * tileSize.height
            ))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

extension UIImage {
    
    func scaled(newSize: CGSize) -> UIImage {
        guard size != newSize else { return self}
        
        let ratio = max(newSize.width / size.width, newSize.height / size.height)
        let width = size.width * ratio
        let height = size.height * ratio

        let scaledRect = CGRect(
          x: (newSize.width - width) / 2.0,
          y: (newSize.height - height) / 2.0,
          width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0.0);
        defer { UIGraphicsEndImageContext() }

        draw(in: scaledRect)

        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
}

extension UIViewController {
    
    func alert(title: String, message: String?) -> Completable {
        return Completable.create { [weak self] completable in
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "关闭", style: .default, handler: { _ in
                completable(.completed)
            }))
            self?.present(alertVC, animated: true)
            return Disposables.create {
                self?.dismiss(animated: true)
            }
        }
    }

    
}
