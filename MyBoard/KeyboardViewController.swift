//
//  KeyboardViewController.swift
//  MyBoard
//
//  Created by zz on 28/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import UIKit
import EmojiSwiperKit
import MobileCoreServices

class KeyboardViewController: UIInputViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {

    // View
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var emojisShower: UICollectionView!
    @IBOutlet weak var groupsShower: UICollectionView!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
        
        let viewHeightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 250)
            viewHeightConstraint.priority = 999
        view.addConstraint(viewHeightConstraint)
    
    }
    
    // Model
    let emojisDataModel = EmojisDataModel.readEmojisDataModel()
    var selectedGroup: Int?
    var groupSortBy = GroupsSortingKey.tag
    var emojiGroups: [EmojiGroupMO] {
        return emojisDataModel.getAllGroups(sortBy: groupSortBy)
    }
    private func getGroup(indexPath: IndexPath) -> EmojiGroupMO {
        return emojiGroups[indexPath.section]
    }
    
    // System
    let pasteBoard = UIPasteboard.general
    
    // View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emojisShower.dataSource = self
        emojisShower.delegate = self
        groupsShower.dataSource = self
        groupsShower.delegate = self

        emojisShower.register(UINib(nibName: "CollectionViewLabelImageCell", bundle: Bundle(for: CollectionViewLabelImageCell.self)), forCellWithReuseIdentifier: "emojiCell")
        groupsShower.register(UINib(nibName: "CollectionViewLabelCell", bundle: Bundle(for: CollectionViewLabelCell.self)), forCellWithReuseIdentifier: "groupTagCell")
        
        let groupsShowerLayout = groupsShower.collectionViewLayout as! UICollectionViewFlowLayout
        groupsShowerLayout.estimatedItemSize = CGSize(width: 62, height: 40)
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emojisDataModel.refresh()
        groupsShower.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    // <UICollectionViewDataSource>
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView==emojisShower {
            let n = emojiGroups.count
                return n
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView==emojisShower {
            if let emos = emojiGroups[section].emojis {
                let n = emos.count
                return n
            }
            return 0
        }
        else {
            let n = emojiGroups.count
            print("n:\(n)")
            return n
        }
    }
    
    private func emojiAt(indexPath: IndexPath) -> EmojiMO {
        let emojiGroup = getGroup(indexPath: indexPath)
        let emoji = emojisDataModel.getEmojiInGroup(orderNumber: emojiGroup.orderNumber, emojiOrder: indexPath.row)
        return emoji
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView==emojisShower {
            let cell = emojisShower.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! CollectionViewLabelImageCell
            let emoji = emojiAt(indexPath: indexPath)
            if let imageData = emoji.image {
                cell.setImage(imageData: imageData as Data)
            }
            else {
                cell.setText(emoji.name)
            }
            
            return cell
        }
        else {
            let cell = groupsShower.dequeueReusableCell(withReuseIdentifier: "groupTagCell", for: indexPath) as! CollectionViewLabelCell
            let group = emojiGroups[indexPath.row]
            print("section\(String(describing: group.tag))")
            cell.setText(group.tag)
            print(indexPath.row)
            if selectedGroup == indexPath.row {
                cell.animate(selected: true)
            }
            else {
                cell.animate(selected: false)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var cell = UICollectionReusableView()
        if collectionView==emojisShower {
            if kind==UICollectionElementKindSectionFooter {
                cell = emojisShower.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "emojisViewFooter", for: indexPath)
                dyeFooter(group: indexPath.section, footer: cell as! CollectionViewLiquidColorFooter)
            }
        }
        return cell
    }
    
    /*
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    */
    
    // <UICollectionViewDelegate>
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView==emojisShower {
            let cell = emojisShower.cellForItem(at: indexPath) as! CollectionViewLabelImageCell
            let emoji = emojiAt(indexPath: indexPath)
            if let imageData = emoji.image {
                pasteBoard.setData(imageData as Data, forPasteboardType: kUTTypeGIF as String)
                /*
                print("Pasteboard width:\(smallImage.size.width) height:\(smallImage.size.height) scale: \(smallImage.scale) mode: \(smallImage.resizingMode.rawValue)")
                 */
            }
            else {
                self.textDocumentProxy.insertText(cell.unicodeEmoji!)
            }
        }
        else {
            // Update Model
            selectedGroup = indexPath.row
            
            // Scroll
            let indexPathForFirstEmoji = IndexPath(row: 0, section: indexPath.row)
            emojisShower.scrollToItem(at: indexPathForFirstEmoji, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
            groupsShower.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
            
            // Highlight
            animateFooterInEmojisShower(groupOrderNumber: indexPath.row, animate: true)
            animateFooterInEmojisShower(groupOrderNumber: indexPath.row-1, animate: true)
            
            let groupCell = groupsShower.cellForItem(at: indexPath) as! CollectionViewLabelCell
            groupCell.animate(selected: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView==emojisShower {

        }
        else {
            if let groupCell = groupsShower.cellForItem(at: indexPath) as? CollectionViewLabelCell {
                groupCell.animate(selected: false)
            }
            
            // Unhighlight
            animateFooterInEmojisShower(groupOrderNumber: indexPath.row, animate: false)
            animateFooterInEmojisShower(groupOrderNumber: indexPath.row-1, animate: false)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if collectionView==emojisShower {
            let emojiCell = emojisShower.cellForItem(at: indexPath) as! CollectionViewLabelImageCell
            emojiCell.animate(selected: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView==emojisShower {
            let emojiCell = emojisShower.cellForItem(at: indexPath) as! CollectionViewLabelImageCell
            //emojiCell.animate(selected: false)
        }
    }
    
    /*
    // <UICollectionViewDelegateFlowLayout>
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == emojisShower {
            let emojiGroup = getGroup(indexPath: indexPath)
            let emojis = emojiGroup.emojis
            let emoji = emojis?[indexPath.row] as? EmojiMO
            if emoji?.image == nil{
                return CGSize(width: 70, height: 70)
            }
            else {
                return CGSize(width: 105, height: 105)
            }
        }
        else {
            let flowlayout = collectionViewLayout as! UICollectionViewFlowLayout
            return flowlayout.estimatedItemSize
        }
    }
    */
    
    // <UIScrollViewDelegate>
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView==emojisShower {
            if let indexPathOfFirstCell = emojisShower.indexPathsForVisibleItems.first {
                groupsShower.scrollToItem(at: IndexPath(row: indexPathOfFirstCell.section, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
            }
        }
    }

    private func animateFooterInEmojisShower(groupOrderNumber: Int, animate: Bool) {
        let footer = emojisShower.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: IndexPath(row: 0, section: groupOrderNumber)) as? CollectionViewLiquidColorFooter
        footer?.animate(highlight: animate)
    }
    
    private func dyeFooter(group: Int, footer: CollectionViewLiquidColorFooter) {
        if (selectedGroup == group) || (selectedGroup == group + 1){
            footer.animate(highlight: true)
        }
        else {
            footer.animate(highlight: false)
        }
        
    }
}
