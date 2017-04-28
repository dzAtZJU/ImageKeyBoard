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

class CameraRollPhotosViewController: UIViewController, UICollectionViewDelegate {
    
    //View
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func swipeBack(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true)
        let vc = self.presentingViewController as! ViewController
        for indexPath in selectedImageIndex {
            let imageCollectionViewCell = collectionView!.cellForItem(at: indexPath) as!ImageCollectionViewCell
            let image = imageCollectionViewCell.imageView.image
            let imageData = UIImageJPEGRepresentation(image!, 1)
            vc.addEmoji(imageData: imageData!)
        }
    }
    
    //Model
    let photosDataModel = PhotosDataModel()
    var selectedImageIndex = Set<IndexPath>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = photosDataModel
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: Bundle(for: ImageCollectionViewCell.self)), forCellWithReuseIdentifier: "photoCell")
    }
    
    //<UICollectionViewDelegate>
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if selectedImageIndex.contains(indexPath) {
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
        if selectedImageIndex.contains(indexPath) {
            selectedImageIndex.remove(indexPath)
        }
        else {
            selectedImageIndex.insert(indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
    }
}
