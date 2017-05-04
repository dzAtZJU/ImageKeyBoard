//
//  KeyboardViewController.swift
//  MyBoard
//
//  Created by zz on 28/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import UIKit
import EmojiSwiperKit

class KeyboardViewController: UIInputViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

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
    
    // System
    let pasteBoard = UIPasteboard.general
    
    // View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emojisShower.dataSource = self
        emojisShower.delegate = self
        groupsShower.dataSource = self
        groupsShower.delegate = self

        emojisShower.register(UINib(nibName: "CollectionViewImageCell", bundle: Bundle(for: CollectionViewImageCell.self)), forCellWithReuseIdentifier: "emojiCell")
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
            let n = emojisDataModel.emojiGroups.count
                return n
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView==emojisShower {
            if let emos = emojisDataModel.emojiGroups[section].emojis {
                let n = emos.count
                return n
            }
            return 0
        }
        else {
            let n = emojisDataModel.emojiGroups.count
            return n
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView==emojisShower {
            let cell = emojisShower.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! CollectionViewImageCell
            let emojis = emojisDataModel.getEmojisInGroup(orderNumber: indexPath.section)
            let emoji = emojis?[indexPath.row] as? EmojiMO
            cell.setImage(imageData: emoji?.image as Data?)
            return cell
        }
        else {
            let cell = groupsShower.dequeueReusableCell(withReuseIdentifier: "groupTagCell", for: indexPath) as! CollectionViewLabelCell
            let group = emojisDataModel.emojiGroups[indexPath.row]
            cell.setText(group.tag)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var cell = UICollectionReusableView()
        if collectionView==emojisShower {
            if kind==UICollectionElementKindSectionFooter {
                cell = emojisShower.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "groupFooter", for: indexPath)
            }
        }
        return cell
    }
    
    // <UICollectionViewDelegate>
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView==emojisShower {
            let cell = emojisShower.cellForItem(at: indexPath) as! CollectionViewImageCell
            let image = cell.image
            pasteBoard.image = image
        }
        else {
            // Scroll
            let indexPathForFirstEmoji = IndexPath(row: 0, section: indexPath.row)
            emojisShower.scrollToItem(at: indexPathForFirstEmoji, at: UICollectionViewScrollPosition.left, animated: true)
            groupsShower.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
            
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
            let groupCell = groupsShower.cellForItem(at: indexPath) as! CollectionViewLabelCell
            groupCell.animate(selected: false)
            
            // Unhighlight
            animateFooterInEmojisShower(groupOrderNumber: indexPath.row, animate: false)
            animateFooterInEmojisShower(groupOrderNumber: indexPath.row-1, animate: false)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if collectionView==emojisShower {
            let emojiCell = emojisShower.cellForItem(at: indexPath) as! CollectionViewImageCell
            emojiCell.animate(selected: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView==emojisShower {
            let emojiCell = emojisShower.cellForItem(at: indexPath) as! CollectionViewImageCell
            emojiCell.animate(selected: false)
        }
    }
    
    /*
    // <UICollectionViewDelegateFlowLayout>
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        if collectionView == groupsShower {
            
        }
        return flowLayout.itemSize
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
        let footer = emojisShower.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: IndexPath(row: 0, section: groupOrderNumber))
        if animate {
            footer?.backgroundColor = footer?.backgroundColor?.withAlphaComponent(1)
        }
        else {
            footer?.backgroundColor = footer?.backgroundColor?.withAlphaComponent(0)
        }
    }

}
