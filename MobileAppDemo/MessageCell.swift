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
	
	func configureCell(tableView: UITableView, post: Post, image: UIImage? = nil)
	{
		messageTextView.text = post.caption
		likeLabel.text = "\(post.likes)"
		
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
		
	}
}
