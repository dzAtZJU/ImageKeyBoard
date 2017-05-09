//
//  CameraRollPhotosViewController.swift
//  Emoer
//
//  Created by zz on 13/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation
import UIKit
import Photos

class CameraRollPhotosViewController: UIViewController, UICollectionViewDelegate, PhotosDataModelDelegate {
    
    //View
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func swipeBack(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true)
        let vc = self.presentingViewController as! ViewController
        for ( indexPath, _ ) in selectedImageIndex {
            let phasset = photosDataModel.assets[indexPath.row]
            PHImageManager.default().requestImageData(for: phasset, options: nil, resultHandler: { (data, dataUTI, _, _) in
                print("image: \(dataUTI ?? "")")
                vc.addEmoji(imageData: data!)
                let uiImage = UIImage(data: data!)!
                print("width: \(uiImage.size.width) height: \(uiImage.size.height)")
            })
            /*
            let imageCollectionViewCell = collectionView!.cellForItem(at: indexPath) as!ImageCollectionViewCell
            let image = imageCollectionViewCell.imageView.image
            let imageData = UIImageJPEGRepresentation(image!, 1)
            vc.addEmoji(imageData: imageData!)
             */
        }
        if let characters = unicodeEmojiTextField.text?.characters {
            for emoji in characters {
                vc.addEmoji(name: String(emoji))
            }
        }
    }
    
    @IBOutlet weak var unicodeEmojiTextField: UITextField!
    
    @IBAction func inputDone() {
        unicodeEmojiTextField.resignFirstResponder()
    }
    
    //Model
    lazy var photosDataModel = { () -> PhotosDataModel in 
        let model = PhotosDataModel()
        model.delegate = self
        return model
    }()
    
    public var selectedImageIndex = [IndexPath: UInt8]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = photosDataModel
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: Bundle(for: ImageCollectionViewCell.self)), forCellWithReuseIdentifier: "photoCell")
    }
    
    // <PhotosDataModelDelegate>
    func fetchedPhotosDidChanged() {
        self.collectionView.reloadData()
    }
    
    func selectOrderFor(indexPath: IndexPath) -> UInt8? {
        return selectedImageIndex[indexPath]
    }

    
    // <UICollectionViewDelegate>
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let _ = selectedImageIndex[indexPath] {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            cell.setSelected(false)
        }
        else {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
            cell.selectionOrder = UInt8(selectedImageIndex.count)
            cell.setSelected(true)
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = selectedImageIndex[indexPath] {
            selectedImageIndex.removeValue(forKey: indexPath)
        }
        else {
            selectedImageIndex[indexPath] = UInt8(selectedImageIndex.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
    }
}
