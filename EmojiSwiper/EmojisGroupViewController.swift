//
//  EmojisGroupViewController.swift
//  Emoer
//
//  Created by zz on 15/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation
import UIKit
import EmojiSwiperKit

class EmojisGroupViewController: UIViewController, UICollectionViewDataSource, UITextFieldDelegate{
    
    //View
    @IBOutlet var swipeLeft: UISwipeGestureRecognizer!
    @IBOutlet var panGestRecog: UIPanGestureRecognizer!
    @IBOutlet var swipeGestRecog: UISwipeGestureRecognizer!
    @IBAction func moveEmoji(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in:emojisGroupView)
        switch sender.state {
        case .began: if let location = emojisGroupView.indexPathForItem(at:location) {
            emojisGroupView.beginInteractiveMovementForItem(at: location)
            }
        case .changed: emojisGroupView.updateInteractiveMovementTargetPosition(location)
        case .ended: emojisGroupView.endInteractiveMovement()
        default: break
        }
    }
    @IBAction func swipeBack(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var emojisGroupView: UICollectionView!
        
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
        if let index = emojisGroupView.indexPathForItem(at: sender.location(in: emojisGroupView)) {
            let vc = self.presentingViewController as! ViewController
            vc.emojisDataModel.deleteEmoji(emoji: emojis[index.row])
            emojisGroupView.reloadData()
        }
    }
    @IBAction func deleteEmoji(_ sender: UISwipeGestureRecognizer) {
        if let index = emojisGroupView.indexPathForItem(at: sender.location(in: emojisGroupView)) {
                let vc = self.presentingViewController as! ViewController
                vc.emojisDataModel.deleteEmoji(emoji: emojis[index.row])
                emojisGroupView.reloadData()
        }
    }
    
    
    //Model
    var emojisGroup: EmojiGroupMO!
    var emojis: [EmojiMO] {
        get {
            if let emojis = emojisGroup.emojis {
                return Array(emojis) as! [EmojiMO]
            }
            return [EmojiMO]()
        }
    }
    
    //View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emojisGroupView.dataSource = self
        emojisGroupView.register(UINib(nibName: "ImageCollectionViewCell", bundle: Bundle(for: ImageCollectionViewCell.self)), forCellWithReuseIdentifier: "emojiCell")
        groupNameField.delegate = self
        groupNameField.text = emojisGroup.tag
        panGestRecog.require(toFail: swipeGestRecog)
        panGestRecog.require(toFail: swipeLeft)
    }
    
    //<UICollectionViewDataSource>
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! ImageCollectionViewCell
        let emojiModel = emojis[indexPath.row]
        if let imageData = emojiModel.image {
            cell.setImage(imageData: imageData as Data)
        }
        else {
            cell.setUnicodeEmoji(emoji: emojiModel.name!)
        }
        return cell
    }

    //<UITextFieldDelegate>
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        emojisGroup.tag = groupNameField.text
    }
    
    //<UITextFieldDelegate>
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }


}
