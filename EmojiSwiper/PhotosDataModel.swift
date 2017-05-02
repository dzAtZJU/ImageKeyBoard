//
//  PhotosDataModel.swift
//  Emoer
//
//  Created by zz on 14/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation
import Photos

protocol PhotosDataModelDelegate {
    func fetchedPhotosDidChanged()
}

class PhotosDataModel: NSObject, UICollectionViewDataSource, PHPhotoLibraryChangeObserver{
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    private var qqPhotosFetchResult = { () -> PHFetchResult<PHAssetCollection> in
        let phFetchOptions = PHFetchOptions()
        phFetchOptions.predicate = NSPredicate(format: "localizedTitle == %@", "QQ")
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: phFetchOptions)
        return assetCollections
    }()
    
    private var recentPhotosFetchResult = {
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumRecentlyAdded, options: nil)
    }()
    
    var delegate: PhotosDataModelDelegate!
    
    var assets: [PHAsset] {
        get {
            var _assets = [PHAsset]()
            _assets += fetchQQPhotos() + fetchRecentlyAddedPhotos()
            _assets = Array(Set(_assets))
            return _assets
        }
    }
    
    // <PHPhotoLibraryChangeObserver>
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changes = changeInstance.changeDetails(for: qqPhotosFetchResult) {
                qqPhotosFetchResult = changes.fetchResultAfterChanges
            }
            if let changes = changeInstance.changeDetails(for: recentPhotosFetchResult) {
                recentPhotosFetchResult = changes.fetchResultAfterChanges
            }
            delegate.fetchedPhotosDidChanged()
        }
    }
    
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
    
    private func fetchQQPhotos() -> [PHAsset]{
        var qqAssets = [PHAsset]()
        qqPhotosFetchResult.enumerateObjects(
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
    
    private func fetchRecentlyAddedPhotos() -> [PHAsset] {
        var recentlyAddedAssets = [PHAsset]()
        recentPhotosFetchResult.enumerateObjects(
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
