//
//  FeedVC.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 31.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import SwiftyJSON

class FeedVC: UIViewController, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	@IBOutlet weak var addImageView: UIImageView!
	@IBOutlet weak var feedTableView: UITableView!

	@IBOutlet weak var captionInputView: InputTextView!
	
	
	private var posts = [Post]()
	private var imagePicker = UIImagePickerController()
	private var imageSelected = false
	
	private var readPosts: ObserveTask?
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		
		feedTableView.dataSource = self
		
		feedTableView.rowHeight = UITableViewAutomaticDimension
		feedTableView.estimatedRowHeight = 320
		
		readPosts = Post.observeList(from: Post.parentReference.queryOrdered(byChild: Post.PROPERTY_CREATED))
		{
			posts in
			
			self.posts = posts.reversed()
			self.feedTableView.reloadData()
		}
    }
	
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return posts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell
		{
			let post = posts[indexPath.row]
			let cachedImage = Storage.imageCache.object(forKey: post.imageUrl as NSString)
			
			cell.configureCell(tableView: tableView, post: post, image: cachedImage)
			return cell
		}
		else
		{
			fatalError()
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
	{
		if let image = info[UIImagePickerControllerEditedImage] as? UIImage
		{
			addImageView.image = image
			imageSelected = true
		}
		picker.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func selectImagePressed(_ sender: AnyObject)
	{
		present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func postButtonPressed(_ sender: AnyObject)
	{
		guard let caption = captionInputView.text, !caption.isEmpty else
		{
			// TODO: Inform the user
			print("POST: Caption must be entered")
			return
		}
		
		guard let image = addImageView.image, imageSelected else
		{
			print("POST: Image must be selected")
			return
		}
		
		guard let currentUserId = User.currentUserId else
		{
			print("POST: Can't post before logging in")
			return
		}
		
		imageSelected = false
		addImageView.image = UIImage(named: "add-image")
		captionInputView.text = nil
		
		// Uploads the image
		if let imageData = UIImageJPEGRepresentation(image, 0.2)
		{
			let imageUid = NSUUID().uuidString
			let metadata = FIRStorageMetadata()
			metadata.contentType = "image/jpeg"
			
			Storage.REF_POST_IMAGES.child(imageUid).put(imageData, metadata: metadata)
			{
				(metadata, error) in
				
				if let error = error
				{
					print("STORAGE: Failed to upload image to storage \(error)")
				}
				
				if let downloadURL = metadata?.downloadURL()?.absoluteString
				{
					// Caches the image for faster display
					Storage.imageCache.setObject(image, forKey: downloadURL as NSString)
					
					print("STORAGE: Successfully uploaded image to storage")
					_ = Post.post(caption: caption, imageUrl: downloadURL, creatorId: currentUserId)
				}
			}
		}
	}
	
	@IBAction func signOutButtonPressed(_ sender: AnyObject)
	{
		// Doesn't listen to posts anymore
		readPosts?.stop()
		
		try! FIRAuth.auth()?.signOut()
		User.currentUserId = nil
		dismiss(animated: true, completion: nil)
	}
}
