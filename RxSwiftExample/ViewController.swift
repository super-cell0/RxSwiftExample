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
    
    ///此数组中存储每个图像的长度
    private var imageCache = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        images
            .throttle(.microseconds(500), scheduler: MainScheduler.instance)
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
        
//        vc.selectedPhotos
//            .subscribe { [weak self] newImage in
//                guard let self = self else { return }
//                self.images.accept(self.images.value + [newImage])
//
//            } onDisposed: {
//                print("完成照片选择")
//            }
//            .disposed(by: bag)
        
        //上面注释的代码替换
        //share()返回一个可观察序列，该序列共享对底层序列的单个订阅，并在订阅后立即重播缓冲区中的元素。
        let newPhotos = vc.selectedPhotos
            .share()
        
        newPhotos
            .take(while: { [weak self] newImage in
                let count = self?.images.value.count ?? 0
                return count < 6
            })
            .filter { newImage in
                //纵向照片不太适合中的这个app拼图 所以过滤掉
                return newImage.size.width > newImage.size.height
            }
            .filter { [weak self] newImage in
                //imageCache 根据数组中存储每个图像的长度 过滤相同的 也就是用户选择的两张一样的图片
                //一样的图片没有意思
                let len = newImage.pngData()?.count ?? 0
                guard self?.imageCache.contains(len) == false else { return false }
                
                self?.imageCache.append(len)
                return true
            }
            .subscribe { [weak self] newImage in
                guard let images = self?.images else { return }
                images.accept(images.value + [newImage])
            } onDisposed: {
                print("完成照片选择")
            }
            .disposed(by: bag)

        
        //ignoreElements()是允许您这样做的运算符：它丢弃源序列的所有元素，并仅通过.completed或.error。
        newPhotos
            .ignoreElements()
            .subscribe(onDisposed:  { [weak self] in
                self?.updateNavigationIcon()
            })
            .disposed(by: bag)
  
        
    }
    
    @IBAction func clearAction(_ sender: Any) {
        images.accept([])
        imageCache = []
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
    
    private func updateNavigationIcon() {
      let icon = preViewImageView.image?
            .scaled(newSize: CGSize(width: 22, height: 22))
            .withRenderingMode(.alwaysOriginal)

      navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon,
        style: .done, target: nil, action: nil)
    }

    
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

