//
//  MessageCell.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 31.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit
import FirebaseStorage

class MessageCell: UITableViewCell
{
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var likeButton: UIButton!
	
	@IBOutlet weak var messageImageView: UIImageView!
	@IBOutlet weak var messageTextView: UITextView!
	@IBOutlet weak var likeLabel: UILabel!
	
	private var post: Post!
	
	func configureCell(tableView: UITableView, post: Post, image: UIImage? = nil)
	{
		self.post = post
		
		messageTextView.text = post.caption
		likeLabel.text = "\(post.likes)"
		
		if let currentUser = User.currentUser
		{
			if currentUser.likes(post: post)
			{
				likeButton.setImage(#imageLiteral(resourceName: "filled-heart"), for: .normal)
			}
			else
			{
				likeButton.setImage(#imageLiteral(resourceName: "empty-heart"), for: .normal)
			}
		}
		else
		{
			print("ERROR: No user logged in")
		}
		
		if let image = image
		{
			messageImageView.image = image
		}
		else
		{
			let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
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
						self.messageImageView.image = image
						Storage.imageCache.setObject(image, forKey: post.imageUrl as NSString)
						
						tableView.beginUpdates()
						tableView.endUpdates()
					}
				}
			}
		}
	}
	
	@IBAction func LikeButtonPressed(_ sender: UIButton)
	{
		if let currentUser = User.currentUser
		{
			if currentUser.likes(post: post)
			{
				post.likes -= 1
				currentUser.unlike(post: post)
			}
			else
			{
				post.likes += 1
				currentUser.like(post: post)
			}
			
			currentUser.pushLikes()
			post.pushLikes()
		}
		else
		{
			print("ERROR: No user logged in")
		}
	}
}
