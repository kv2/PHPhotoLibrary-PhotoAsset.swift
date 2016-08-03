//
//  PHAsset+identifier.swift
//  
//
//  kudos tos666
//  https://forums.developer.apple.com/people/tos666
//

import Foundation
import Photos

public extension PHAsset
{
    public class func ah_fetchAssetWithLocalIdentifier(identifier: String, options: PHFetchOptions?) -> PHAsset?
    {
        if let asset = PHAsset.fetchAssetsWithLocalIdentifiers([identifier], options: options).lastObject as? PHAsset
        {
            return asset
        }
        
        var result : PHAsset?
        
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .AlbumMyPhotoStream, options: options)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format:"localIdentifier ==[cd] %@", identifier)
        
        userAlbums.enumerateObjectsUsingBlock
            {
                (objectCollection : AnyObject, _ : Int, stopCollectionEnumeration : UnsafeMutablePointer<ObjCBool>) in
                
                guard let collection = objectCollection as? PHAssetCollection else
                {
                    return
                }
                
                let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options:fetchOptions)
                
                assetsFetchResult.enumerateObjectsUsingBlock
                    {
                        (objectAsset : AnyObject, _ : Int, stopAssetEnumeration: UnsafeMutablePointer<ObjCBool>) in
                        
                        guard let asset = objectAsset as? PHAsset else
                        {
                            return
                        }
                        
                        result = asset
                        stopAssetEnumeration.initialize(true)
                        stopCollectionEnumeration.initialize(true)
                }
        }
        
        return result
    }
}