//
//  ViewController.swift
//  Emoer
//
//  Created by zz on 24/03/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import UIKit
import EmojiSwiperKit

class ViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //View
    @IBOutlet weak var emojiGroupsView: UICollectionView!
    @IBAction func newGroup(_ sender: UIButton) {
        let index = emojiGroups.count
        emojisDataModel.addGroup(orderNumber: Int16(index))
        selectedGroupOrderNumber = Int16(index)
        performSegue(withIdentifier: "pickPhoto", sender: sender)
    }
    @IBOutlet var swipLeft: UISwipeGestureRecognizer!
    @IBOutlet var panGestRecog: UIPanGestureRecognizer!
    @IBAction func moveGroup(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in:emojiGroupsView)
        switch sender.state {
        case .began: if let location = emojiGroupsView.indexPathForItem(at:location) {
            emojiGroupsView.beginInteractiveMovementForItem(at: location)
            }
        case .changed: emojiGroupsView.updateInteractiveMovementTargetPosition(location)
        case .ended: emojiGroupsView.endInteractiveMovement()
        default: break
        }
    }
    @IBAction func deleteGroup(_ sender: UISwipeGestureRecognizer) {
        if let index = emojiGroupsView.indexPathForItem(at: sender.location(in: emojiGroupsView)) {
            let groupAmount = emojiGroups.count
            emojisDataModel.deleteGroup(orderNumber: index.row)
            if index.row+1 < groupAmount {
                for i in index.row+1..<groupAmount {
                    emojiGroups[i-1].orderNumber -= 1
                }
            }
            emojiGroupsView.reloadData()
        }
    }
    func swipe(_ sender: UISwipeGestureRecognizer) {
        let cell = sender.view as! ImageCollectionViewCell
        let groupOrderNumber = emojiGroupsView.indexPath(for: cell)!.row
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "emojisGroupView") as! EmojisGroupViewController
        vc.emojisGroup = emojiGroups[groupOrderNumber]
        self.present(vc, animated: true, completion: nil)
    }
    
    //Model
    let emojisDataModel = EmojisDataModel(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    var emojiGroups: [EmojiGroupMO] {
        return emojisDataModel.getAllGroups()
    }
    
    //View -> Vontroller -> Model Information Flow
    var selectedGroupOrderNumber: Int16?
    
    // View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emojiGroupsView.register(UINib(nibName: "ImageCollectionViewCell", bundle: Bundle(for: ImageCollectionViewCell.self)), forCellWithReuseIdentifier: "emojiGroupCell")
        emojiGroupsView.delegate = self
        emojiGroupsView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emojiGroupsView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emojisDataModel.saveContext()
    }
    
    //
    internal func addEmoji(imageData: Data) {
        emojisDataModel.addEmojiToGroup(imageData: imageData, orderNumber:selectedGroupOrderNumber!)
    }
    
    // <UICollectionView>
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let groupCount = emojiGroups.count
        return groupCount
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiGroupCell", for: indexPath) as! ImageCollectionViewCell
        let group = emojiGroups[indexPath.row]
        if let groupName = group.tag {
            cell.setLabelText(text: groupName)
        }
        else {
            let representativeEmoji = emojiGroups[indexPath.row].emojis?.lastObject as? EmojiMO
            if let imageData = representativeEmoji?.image {
                let image = UIImage(data: imageData as Data)
                cell.setImage(image!)
            }
            else {
                cell.setImage(nil)
            }
        }
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(_:)))
        panGestRecog.require(toFail: swipeGestureRecognizer)
        panGestRecog.require(toFail: swipLeft)
        cell.addGestureRecognizer(swipeGestureRecognizer)
            
        return cell
    }

    /*
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiGroupCell", for: indexPath) as! EmojiGroupCell
        let representativeEmoji = emojiGroups[indexPath.row].emojis?.lastObject as? EmojiMO
        if let imageData = representativeEmoji?.image {
            let image = UIImage(data: imageData as Data)
            cell.setImage(image!)
        }
        else {
            cell.setImage(nil)
        }
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(_:)))
        panGestRecog.require(toFail: swipeGestureRecognizer)
        panGestRecog.require(toFail: swipLeft)
        cell.addGestureRecognizer(swipeGestureRecognizer)
        return cell
    }
 */
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGroupOrderNumber = Int16(indexPath.row)
        /*
         let photoPicker = UIImagePickerController()
         photoPicker.sourceType = .savedPhotosAlbum
         photoPicker.delegate = self
         self.present(photoPicker, animated: true)
         */
    }
    
    internal func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = (kind==UICollectionElementKindSectionHeader) ? "header" : "footer"
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:identifier, for: indexPath)
        return view
    }
    
    internal func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.row > destinationIndexPath.row {
            emojiGroups[sourceIndexPath.row].orderNumber = Int16(-1)
            for i in (destinationIndexPath.row + 1 ... sourceIndexPath.row).reversed() {
                emojiGroups[i-1].orderNumber = Int16(i)
            }
            emojiGroups[sourceIndexPath.row].orderNumber = Int16(destinationIndexPath.row)
        }
        else {
            emojiGroups[sourceIndexPath.row].orderNumber = Int16(-1)
            for i in sourceIndexPath.row ..< destinationIndexPath.row {
                emojiGroups[i+1].orderNumber = Int16(i)
            }
            emojiGroups[sourceIndexPath.row].orderNumber = Int16(destinationIndexPath.row)
        }
    }
    
    
    //<UIImagePickerControllerDelegate>
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let imageData = UIImageJPEGRepresentation(image, 1) {
                emojisDataModel.addEmojiToGroup(imageData: imageData, orderNumber:selectedGroupOrderNumber!)
            }
        }
        emojiGroupsView.reloadItems(at: [IndexPath(row: Int(selectedGroupOrderNumber!), section: 0)] )
        emojiGroupsView.reloadData()
        selectedGroupOrderNumber = nil
    }
    
    //Segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
