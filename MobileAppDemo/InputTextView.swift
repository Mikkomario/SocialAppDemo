//
//  InputTextView.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 31.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit

class InputTextView: UITextView
{
	override func awakeFromNib()
	{
		super.awakeFromNib()
		layer.borderColor = SHADOW_GRAY.cgColor
		layer.cornerRadius = 2.0
	}
}
