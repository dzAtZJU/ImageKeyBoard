//
//  PhotosDataModel.swift
//  Emoer
//
//  Created by zz on 14/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation
import Photos

class PhotosDataModel: NSObject, UICollectionViewDataSource{
    
    var assets: [PHAsset] = {
        var _assets = [PHAsset]()
        _assets += PhotosDataModel.fetchQQPhotos() + PhotosDataModel.fetchRecentlyAddedPhotos()
        _assets = Array(Set(_assets))
        return _assets
    }()
    
    // <CollectionViewDataSource>
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! ImageCollectionViewCell
        cell.setImage(asset: assets[indexPath.row])
        return cell
    }
    
    private class func fetchQQPhotos() -> [PHAsset]{
        var qqAssets = [PHAsset]()
        let phFetchOptions = PHFetchOptions()
        phFetchOptions.predicate = NSPredicate(format: "localizedTitle == %@", "QQ")
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: phFetchOptions)
        assetCollections.enumerateObjects(
            {assetCollection, index, stop in
                let phFetchOptions = PHFetchOptions()
                phFetchOptions.fetchLimit = 5
                phFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fecthedAssets = PHAsset.fetchAssets(in: assetCollection, options: phFetchOptions)
                fecthedAssets.enumerateObjects(
                    { asset, index, stop in
                        qqAssets.append(asset)
                    }
                )
            }
        )
        return qqAssets
    }
    
    private class func fetchRecentlyAddedPhotos() -> [PHAsset] {
        var recentlyAddedAssets = [PHAsset]()
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumRecentlyAdded, options: nil)
        assetCollections.enumerateObjects(
            {assetCollection, index, stop in
                let phFetchOptions = PHFetchOptions()
                phFetchOptions.fetchLimit = 10
                phFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fecthedAssets = PHAsset.fetchAssets(in: assetCollection, options: phFetchOptions)
                fecthedAssets.enumerateObjects(
                    { asset, index, stop in
                        recentlyAddedAssets.append(asset)
                    }
                )
            }
        )
        return recentlyAddedAssets
    }
}
