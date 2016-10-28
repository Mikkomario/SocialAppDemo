//
//  ShadowedImageView.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 28.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit

class ShadowedImageView: UIImageView, Shadowed
{
	override func awakeFromNib()
	{
		super.awakeFromNib()
		setDefaultShadow()
	}
}
