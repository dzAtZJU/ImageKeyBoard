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

class CameraRollPhotosViewController: UIViewController, UICollectionViewDelegate, PhotosDataModelDelegate, UITextFieldDelegate {
    
    //View
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func swipeBack(_ sender: UISwipeGestureRecognizer) {
        /*
        print(isNewGroup)
        print(selectedImageIndex.isEmpty)
        print(unicodeEmojiTextField.text!)
        */
        if selectedImageIndex.isEmpty && unicodeEmojiTextField.text == "" {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            if isNewGroup {
                vc.addGroup()
            }
            
            for ( indexPath, _ ) in selectedImageIndex {
                let phasset = photosDataModel.assets![indexPath.row]
                PHImageManager.default().requestImageData(for: phasset, options: nil, resultHandler: { (data, dataUTI, _, _) in
                    print("image: \(dataUTI ?? "")")
                    self.vc.addEmoji(imageData: data!, self.isNewGroup)
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
            if let emojis = unicodeEmojiTextField.text?.components(separatedBy: " ") {
                let es = emojis.dropFirst()
                for emoji in es {
                    print(emoji)
                    vc.addEmoji(name: String(emoji), isNewGroup)
                }
            }
            if isNewGroup {
                let alert = self.inputGroupNameAlert
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    var inputGroupNameAlert: UIAlertController
    {
        get {
            let alert = UIAlertController(title: "New Group", message: "Enter a name for this goup", preferredStyle: .alert)
            
            let actionSave = UIAlertAction(title: "Save", style: .default, handler: { (_) in
                self.vc.setNameOfNewGroup(name: alert.textFields![0].text!)
                self.dismiss(animated: true, completion: nil)
            })
            actionSave.isEnabled = false
            alert.addAction(actionSave)
            
            alert.addTextField(configurationHandler: { textField in
                textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
            })
            
            return alert
        }
    }
    
    func textChanged( _ sender: UITextField) {
        let str = sender.text
        var resp : UIResponder! = sender
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[0].isEnabled = vc.validateGroupName(str)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == unicodeEmojiTextField {
            if range.length == 0 {
                if var _ = textField.text {
                    textField.text!.append(" ")
                }
            }
        }
        return true
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
    
    var isNewGroup: Bool = false
    
    public var selectedImageIndex = [IndexPath: UInt8]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = photosDataModel
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: Bundle(for: ImageCollectionViewCell.self)), forCellWithReuseIdentifier: "photoCell")
        unicodeEmojiTextField.delegate = self
    }
    
    var vc: ViewController {
        return self.presentingViewController as! ViewController
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
