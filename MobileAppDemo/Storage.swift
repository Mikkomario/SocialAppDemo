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
	
	static let imageCache: NSCache<NSString, UIImage> = NSCache()
}
