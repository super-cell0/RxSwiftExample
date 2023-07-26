//
//  ViewController.swift
//  RxSwiftExample
//
//  Created by mac on 2023/7/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class ViewController: UIViewController {

    @IBOutlet weak var preViewImageView: UIImageView! {
        didSet {
            preViewImageView.layer.borderColor = UIColor.opaqueSeparator.cgColor
            preViewImageView.layer.borderWidth = 1
            preViewImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    private let bag = DisposeBag()
    private let images = BehaviorRelay<[UIImage]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        images
            .subscribe { [weak preViewImageView] photos in
                guard let preViewImageView = preViewImageView else { return }
                
                preViewImageView.image = photos.collage(size: preViewImageView.frame.size)
                
            }
            .disposed(by: bag)
        
        images
            .subscribe { [weak self] photos in
                guard let self = self else { return }
                self.updateUI(photos: photos)
            }
            .disposed(by: bag)
        
    }

    @IBAction func addAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoCollectionViewControllerID") as! PhotoCollectionViewController
        
        navigationController?.pushViewController(vc, animated: true)
        
        vc.selectedPhotos
            .subscribe { [weak self] newImage in
                guard let self = self else { return }
                self.images.accept(self.images.value + [newImage])
                
            } onDisposed: {
                print("完成照片选择")
            }
            .disposed(by: bag)

        
    }
    
    @IBAction func clearAction(_ sender: Any) {
        images.accept([])
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        guard let preViewImageViewImages = preViewImageView.image else { return }
        
        PhotoWriter.save(image: preViewImageViewImages)
            .subscribe { [weak self] id in
                guard let self = self else { return }
                self.showMessage(title: "saved with id: \(id)")
                images.accept([])
                
            } onFailure: { [weak self] error in
                guard let self = self else { return }
                self.showMessage(title: "Error", description: error.localizedDescription)
                
            }
            .disposed(by: bag)
    }
    
}

extension ViewController {
    
    func updateUI(photos: [UIImage]) {
        saveButton.isEnabled = photos.count > 0 && photos.count % 2 == 0
        clearButton.isEnabled = photos.count > 0
        addBarButton.isEnabled = photos.count < 6
        
        title = photos.count > 0 ? "\(photos.count) 张照片" : "Collage"
    }
    
    func showMessage(title: String, description: String? = nil ) {
        alert(title: title, message: description)
            .subscribe()
            .disposed(by: bag)
    }
}

