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
            let orderNumber = emojiGroups[index.row].orderNumber
            emojisDataModel.deleteGroup(orderNumber: Int(orderNumber))
            if index.row+1 < groupAmount {
                for i in index.row+1..<groupAmount {
                    emojiGroupsByOrderNumber[i-1].orderNumber -= 1
                }
            }
            emojiGroupsView.reloadData()
        }
    }
    func swipe(_ sender: UISwipeGestureRecognizer) {
        let cell = sender.view as! EmojiGroupCell
        let groupOrderNumber: Int = emojiGroupsView.indexPath(for: cell)!.row
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "emojisGroupView") as! EmojisGroupViewController
        vc.emojisGroup = emojiGroups[groupOrderNumber]
        selectedGroupOrderNumber = Int16(groupOrderNumber)
        self.present(vc, animated: true, completion: nil)
    }
    
    //Model
    let emojisDataModel = EmojisDataModel(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    var emojiGroups: [EmojiGroupMO] {
        return emojisDataModel.getAllGroups(sortBy: GroupsSortingKey.tagLatin)
    }
    var emojiGroupsByOrderNumber: [EmojiGroupMO] {
        return emojisDataModel.getAllGroups(sortBy: .orderNumber)
    }
    var newGroup: EmojiGroupMO {
        return emojisDataModel.fetchGroupObject(orderNumber: selectedGroupOrderNumber!)!
    }
    
    //View -> Vontroller -> Model Information Flow
    var selectedGroupOrderNumber: Int16?
    
    // View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emojiGroupsView.delegate = self
        emojiGroupsView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emojisDataModel.refresh()
        emojiGroupsView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emojisDataModel.saveContext()
    }
    
    //
    internal func addEmoji(imageData: Data, _ isNew: Bool = false) {
        let orderNumber = isNew ? selectedGroupOrderNumber! : emojiGroups[Int(selectedGroupOrderNumber!)].orderNumber
        emojisDataModel.addEmojiToGroup(imageData: imageData, orderNumber: orderNumber)
    }
    
    internal func addEmoji(name: String, _ isNew: Bool = false) {
        let orderNumber = isNew ? selectedGroupOrderNumber! : emojiGroups[Int(selectedGroupOrderNumber!)].orderNumber
        emojisDataModel.addEmojiToGroup(name: name, orderNumber: orderNumber)
    }
    
    internal func addGroup() {
        emojisDataModel.addGroup(orderNumber: selectedGroupOrderNumber!)
    }
    
    internal func deleteGroup() {
        if let groupOrderNumber = selectedGroupOrderNumber {
            let group = emojiGroups[Int(groupOrderNumber)]
            emojisDataModel.deleteGroup(group: group)
        }
        emojisDataModel.saveContext()
    }
    
    internal func validateGroupName(_ name: String?) -> Bool {
        if name != "" {
            return true
        }
        return false
    }
    
    internal func setNameOfNewGroup(name: String) {
        emojisDataModel.modifyGroupName(orderNumber: selectedGroupOrderNumber!, newName: name)
    }
    
    internal func isEmptyGroup() {
        //let group
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiGroupCell", for: indexPath) as! EmojiGroupCell
        let group = emojiGroups[indexPath.row]
        if group.tag != "" {
            cell.setLabelText(text: group.tag!)
        }
        else {
            if let representativeEmoji = group.emojis?.lastObject as? EmojiMO {
                if let imageData = representativeEmoji.image {
                    cell.setImage(imageData: imageData as Data)
                }
                else {
                    cell.setLabelText(text: representativeEmoji.name!)
                }
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
        if let _ = sender as? UIButton {
            let dest = segue.destination as! CameraRollPhotosViewController
            dest.isNewGroup = true
        }
    }
}
