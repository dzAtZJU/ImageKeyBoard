//
//  KeyboardViewController.swift
//  MyBoard
//
//  Created by zz on 28/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import UIKit
import EmojiSwiperKit

class KeyboardViewController: UIInputViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // View
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var emojisShower: UICollectionView!
    @IBOutlet weak var groupsShower: UICollectionView!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    // Model
    let emojisDataModel = EmojisDataModel.readEmojisDataModel()
     /*
    var emojiGroups: [EmojiGroupMO] {
        get {
            return emojisDataModel.getAllGroups()
        }
    }
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        emojisShower.dataSource = self
        groupsShower.dataSource = self
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
                return 1
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView==emojisShower {
            return 3
        }
        else {
            return 3
            //return emojiGroups.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView==emojisShower {
            let cell = emojisShower.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! CollectionViewImageCell
            return cell
        }
        else {
            let cell = groupsShower.dequeueReusableCell(withReuseIdentifier: "groupCell", for: indexPath) as! CollectionViewLabelCell
            //let groupName = emojiGroups[indexPath.row].tag
            //cell.setText(groupName)
            return cell
        }
    }
}
