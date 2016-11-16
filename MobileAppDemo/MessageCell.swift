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
	
	func configureCell(tableView: UITableView, post: Post)
	{
		self.post = post
		
		// Basic info
		messageTextView.text = post.caption
		likeLabel.text = "\(post.likes)"
		
		// Post user
		User.get(id: post.creatorId)
		{
			postCreator in 
			
			self.titleLabel.text = postCreator.userName
			
			// Profile-pic
			if let profilePicUrl = postCreator.imageUrl
			{
				Storage.getImage(with: profilePicUrl)
				{
					profilePic in
					
					self.profileImageView.image = profilePic
				}
			}
			else
			{
				// TODO: Use unkown user icon instead of nil (no asset at this time)
				self.profileImageView.image = nil
			}
		}
		
		// Liking
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
		
		// Image
		Storage.getImage(with: post.imageUrl)
		{
			postPic in
			
			self.messageImageView.image = postPic
			// Row height changes so table needs to be reset
			tableView.beginUpdates()
			tableView.endUpdates()
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
