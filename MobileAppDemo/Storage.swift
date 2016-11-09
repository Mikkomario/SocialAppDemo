//
//  Storage.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 2.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import Foundation
import FirebaseStorage
import UIKit

let STORAGE_BASE = FIRStorage.storage().reference()

class Storage
{
	static let REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
	static let REF_USER_IMAGES = STORAGE_BASE.child("user-pics")
	
	static let imageCache: NSCache<NSString, UIImage> = NSCache()
	
	static func upload(image: UIImage, to reference: FIRStorageReference, completionHandler: @escaping (String?, Error?) -> ())
	{
		// Uploads the image
		if let imageData = UIImageJPEGRepresentation(image, 0.2)
		{
			let imageUid = NSUUID().uuidString
			let metadata = FIRStorageMetadata()
			metadata.contentType = "image/jpeg"
			
			reference.child(imageUid).put(imageData, metadata: metadata)
			{
				(metadata, error) in
				
				if let error = error
				{
					completionHandler(nil, error)
				}
				
				if let downloadURL = metadata?.downloadURL()?.absoluteString
				{
					// Caches the image for faster display
					imageCache.setObject(image, forKey: downloadURL as NSString)
					completionHandler(downloadURL, nil)
				}
			}
		}
		else
		{
			completionHandler(nil, StorageError.compressionFailed)
		}
	}
	
	// Storage.imageCache.object(forKey: post.imageUrl as NSString)
	static func getImage(with url: String, completionHandler: @escaping (UIImage) -> ())
	{
		if let image = imageCache.object(forKey: url as NSString)
		{
			completionHandler(image)
		}
		else
		{
			let ref = FIRStorage.storage().reference(forURL: url)
			ref.data(withMaxSize: 2 * 1024 * 1024)
			{
				(data, error) in
				
				if let error = error
				{
					print("STORAGE: Unable to read image from storage \(error)")
				}
				else if let data = data
				{
					print("STORAGE: Image read from storage")
					if let image = UIImage(data: data)
					{
						// Caches the image
						Storage.imageCache.setObject(image, forKey: url as NSString)
						completionHandler(image)
					}
				}
			}
		}
	}
}

enum StorageError: Error
{
	case compressionFailed
}
