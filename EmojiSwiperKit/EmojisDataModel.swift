//
//  EmojisDataModel.swift
//  Emoer
//
//  Created by zz on 02/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class EmojisDataModel {
    private static let groupIdentifier = "group.ind.weiran3120102776.EmojiSwiper2"
    
    public let persistentContainer: NSPersistentContainer?
    private let managedObjectContext: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        managedObjectContext = context
        persistentContainer = nil
    }
    
    public init(container: NSPersistentContainer) {
        persistentContainer = container
        managedObjectContext = persistentContainer!.viewContext
    }
    
    public class func myEmojisDataModel() -> EmojisDataModel {
        var applicationDocumentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
        applicationDocumentsDirectory.appendPathComponent("EmojiSwiper2")
        let storeDescription = NSPersistentStoreDescription(url: applicationDocumentsDirectory)
        storeDescription.isReadOnly = false
        let defaultContainer = NSPersistentContainer(name: "Model")
        defaultContainer.persistentStoreDescriptions = [storeDescription]
        defaultContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        /*
        let myDefaults = UserDefaults(suiteName: groupIdentifier)!
        myDefaults.set(applicationDocumentsDirectory, forKey: "emojisDatabasePath")
        myDefaults.synchronize()
        */
        
        return EmojisDataModel(container: defaultContainer)
    }
    
    public class func readEmojisDataModel() -> EmojisDataModel {
        var applicationDocumentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)!
        applicationDocumentsDirectory.appendPathComponent("EmojiSwiper2")
        let storeDescription = NSPersistentStoreDescription(url: applicationDocumentsDirectory)
        let defaultContainer = NSPersistentContainer(name: "Model")
        defaultContainer.persistentStoreDescriptions = [storeDescription]
        defaultContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return EmojisDataModel(container: defaultContainer)
    }
    
    public func addDefaultEmojiGroups() {
        if let path = Bundle(for: CollectionViewImageCell.self).path(forResource: "Emojis", ofType: "plist") {
            if let emojiGroups = NSDictionary(contentsOfFile: path) {
                var orderNumber: Int16 = 0
                for group in emojiGroups {
                    let groupName = group.key as! String
                    let unicodeEmojis = group.value as! [String]
                    addGroup(orderNumber: orderNumber, tag: groupName)
                    for emoji in unicodeEmojis {
                        addEmojiToGroup(name: emoji, orderNumber: orderNumber)
                    }
                    orderNumber += 1
                }
            }
        }
    }
    
    public var emojiGroups: [EmojiGroupMO] {
        return fetchAllGroups()
    }
    
    public func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        print("save: \(emojiGroups.count)")
    }
    
    public func refresh() {
        managedObjectContext.refreshAllObjects()
        print("group count: \(emojiGroups.count)")
    }
    
    public func addGroup(orderNumber: Int16, tag: String = "") {
        let group = NSEntityDescription.insertNewObject(forEntityName: "EmojiGroup", into: managedObjectContext) as! EmojiGroupMO
        group.orderNumber = orderNumber
        if tag != "" {
            group.tag = tag
        }
    }
    
    public func addEmojiToGroup(imageData: Data, orderNumber: Int16) {
        let emoji = NSEntityDescription.insertNewObject(forEntityName: "Emoji", into: managedObjectContext) as! EmojiMO
        emoji.image = imageData as NSData
        let group = fetchGroupObject(orderNumber: orderNumber)
        emoji.group = group
    }
    
    public func addEmojiToGroup(name: String, orderNumber: Int16) {
        let emoji = NSEntityDescription.insertNewObject(forEntityName: "Emoji", into: managedObjectContext) as! EmojiMO
        emoji.name = name
        let group = fetchGroupObject(orderNumber: orderNumber)
        emoji.group = group
    }
    
    /*
    public func addEmoji(image: UIImage, name: String?){
        let emoji = NSEntityDescription.insertNewObject(forEntityName: "Emoji", into: managedObjectContext) as! EmojiMO
        emoji.image = UIImageJPEGRepresentation(UIImage(contentsOfFile: "Huge Sorrow.jpg")!, 1.0) as! NSData
        emoji.name = name ?? EmojiNameGenerator.nextName()
    }
    */
    
    public func modifyEmojiName(originalName: String, to newName: String) {
        let emojiObject = fetchEmojiObject(originalName)
        emojiObject.name = newName
    }
    
    public func moveEmojiToGroup(emojiName: String, orderNumber : Int16) {
        let emojiObject = fetchEmojiObject(emojiName)
        let group = fetchGroupObject(orderNumber: orderNumber)
        emojiObject.group = group
    }
    
    public func getAllGroups() -> [EmojiGroupMO] {
        return fetchAllGroups()
    }
    
    public func deleteEmoji(emoji: EmojiMO) {
        managedObjectContext.delete(emoji)
    }
    
    public func deleteGroup(group: EmojiGroupMO) {
        managedObjectContext.delete(group)
    }
    
    public func deleteGroup(orderNumber: Int) {
        print("Before delete group: \(emojiGroups.count)")
        let group = fetchGroupObject(orderNumber: Int16(orderNumber))
        if let hasGroup = group {
            managedObjectContext.delete(hasGroup)
        }
        print("After delete group: \(emojiGroups.count)")
    }
    
    public func getEmojisInGroup(orderNumber: Int) -> NSOrderedSet? {
        let group = emojiGroups[orderNumber]
        return group.emojis
    }
    
    // [TODO]: load index from persistent; save index to persistent; Better data structure
    private class EmojiNameGenerator {
        static let maximum = 256
        static var index = 0
        fileprivate class func nextName() -> String {
            index = (index + 1) % maximum
            return "_anomoji\(index)"
        }
    }
    
    private func fetchEmojiObject(_ name: String) -> EmojiMO {
        let fectchRequest = NSFetchRequest<EmojiMO>(entityName: "Emoji")
        fectchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let fetchedEmoji = try self.managedObjectContext.fetch(fectchRequest)
            return fetchedEmoji[0]
        }
        catch {
            fatalError("Failed to fetch emojis: \(error)")
        }
    }
    
    private func fetchGroupObject(orderNumber: Int16) -> EmojiGroupMO? {
        let fectchRequest = NSFetchRequest<EmojiGroupMO>(entityName: "EmojiGroup")
        fectchRequest.predicate = NSPredicate(format: "orderNumber = %@", argumentArray:[orderNumber])
        do {
            let fetchedGroup = try self.managedObjectContext.fetch(fectchRequest)
            guard !fetchedGroup.isEmpty else {
                let allGriups = fetchAllGroups()
                print(allGriups.count)
                return nil
            }
            return fetchedGroup[0]
        }
        catch {
            fatalError("Failed to fetch emojis: \(error)")
        }
    }
    
    private func fetchGroupObject(tag: String) -> EmojiGroupMO? {
        let fectchRequest = NSFetchRequest<EmojiGroupMO>(entityName: "EmojiGroup")
        fectchRequest.predicate = NSPredicate(format: "orderNumber == %@", tag)
        do {
            let fetchedGroup = try self.managedObjectContext.fetch(fectchRequest)
            return fetchedGroup.first
        }
        catch {
            fatalError("Failed to fetch emojis: \(error)")
        }
    }
    
    private func fetchAllGroups() -> [EmojiGroupMO] {
        let fectchRequest = NSFetchRequest<EmojiGroupMO>(entityName: "EmojiGroup")
        fectchRequest.sortDescriptors = [NSSortDescriptor(key: "orderNumber", ascending: true)]
        do {
            let fetchedGroups = try self.managedObjectContext.fetch(fectchRequest)
            return fetchedGroups
        }
        catch {
            fatalError("Failed to fetch emojis: \(error)")
        }
    }
}
