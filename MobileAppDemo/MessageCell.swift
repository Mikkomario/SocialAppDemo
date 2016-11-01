//
//  MessageCell.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 31.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell
{
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var likeButton: UIButton!
	
	@IBOutlet weak var messageImageView: UIImageView!
	@IBOutlet weak var messageTextView: UITextView!
	@IBOutlet weak var likeLabel: UILabel!
	
	func configureCell(post: Post)
	{
		messageTextView.text = post.caption
		likeLabel.text = "\(post.likes)"
	}
}
