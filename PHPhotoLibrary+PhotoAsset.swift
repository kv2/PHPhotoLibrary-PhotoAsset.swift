//
//  PHPhotoLibrary+PhotoAsset.swift
//  
//
//  kudos to ricardopereira
//  https://gist.github.com/ricardopereira
//

import Foundation
import Photos

public extension PHPhotoLibrary {
    
    
    typealias PhotoAsset = PHAsset
    typealias PhotoAlbum = PHAssetCollection
    
    static func saveImage(image: UIImage, albumName: String, completion: (PHAsset?)->()) {
        if let album = self.findAlbum(albumName) {
            saveImage(image, album: album, completion: completion)
            return
        }
        createAlbum(albumName) { album in
            if let album = album {
                self.saveImage(image, album: album, completion: completion)
            }
            else {
                assert(false, "Album is nil")
            }
        }
    }
    
    static func saveVideo(videoUrl: NSURL, albumName: String, completion: (PHAsset?)->()) {
        if let album = self.findAlbum(albumName) {
            saveVideo(videoUrl, album: album, completion: completion)
            return
        }
        createAlbum(albumName) { album in
            if let album = album {
                self.saveVideo(videoUrl, album: album, completion: completion)
            }
            else {
                assert(false, "Album is nil")
            }
        }
    }
    
    static private func saveImage(image: UIImage, album: PhotoAlbum, completion: (PHAsset?)->()) {
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            // Request creating an asset from the image
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: album) else {
                assert(false, "Album change request failed")
                return
            }
            // Get a placeholder for the new asset and add it to the album editing request
            guard let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else {
                assert(false, "Placeholder is nil")
                return
            }
            placeholder = photoPlaceholder
            albumChangeRequest.addAssets([photoPlaceholder])
            }, completionHandler: { success, error in
                guard let placeholder = placeholder else {
                    assert(false, "Placeholder is nil")
                    completion(nil)
                    return
                }
                
                if success {
                    completion(PHAsset.ah_fetchAssetWithLocalIdentifier(placeholder.localIdentifier, options:nil))
                }
                else {
                    print(error)
                    completion(nil)
                }
        })
    }
     
    static private func saveVideo(videoUrl: NSURL, album: PhotoAlbum, completion: (PHAsset?)->()) {
    
        var placeholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            
            // Request creating an asset from the image
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(videoUrl)
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: album) else {
                assert(false, "Album change request failed")
                return
            }
            
            // Get a placeholder for the new asset and add it to the album editing request
            guard let videoPlaceholder = createAssetRequest!.placeholderForCreatedAsset else {
                assert(false, "Placeholder is nil")
                return
            }
            
            placeholder = videoPlaceholder
        
            albumChangeRequest.addAssets([videoPlaceholder])
            }, completionHandler: { success, error in
                guard let placeholder = placeholder else {
                    assert(false, "Placeholder is nil")
                    completion(nil)
                    return
                }
                
                if success {
                    completion(PHAsset.ah_fetchAssetWithLocalIdentifier(placeholder.localIdentifier, options:nil))
                }
                else {
                    print(error)
                    completion(nil)
                }
        })
    
        
    }


    static func findAlbum(albumName: String) -> PhotoAlbum? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .AlbumRegular, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject as? PHAssetCollection else {
            return nil
        }
        return photoAlbum
    }
    
    static func createAlbum(albumName: String, completion: (PhotoAlbum?)->()) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            // Request creating an album with parameter name
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
            // Get a placeholder for the new album
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                guard let placeholder = albumPlaceholder else {
                    assert(false, "Album placeholder is nil")
                    completion(nil)
                    return
                }
                
                let fetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([placeholder.localIdentifier], options: nil)
                guard let album = fetchResult.firstObject as? PhotoAlbum else {
                    assert(false, "FetchResult has no PHAssetCollection")
                    completion(nil)
                    return
                }
                
                if success {
                    completion(album)
                }
                else {
                    print(error)
                    completion(nil)
                }
        })
    }
    
    static func loadThumbnailFromLocalIdentifier(localIdentifier: String, completion: (UIImage?)->()) {
        guard let asset = PHAsset.ah_fetchAssetWithLocalIdentifier(localIdentifier, options:nil) else {
            completion(nil)
            return
        }
        loadThumbnailFromAsset(asset, completion: completion)
    }
    
    static func loadThumbnailFromAsset(asset: PhotoAsset, completion: (UIImage?)->()) {
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .AspectFit, options: PHImageRequestOptions(), resultHandler: { result, info in
            completion(result)
        })
    }
    
}

