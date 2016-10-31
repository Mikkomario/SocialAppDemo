//
//  CircleImage.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 31.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit

class CircleImage: UIImageView
{

	override func layoutSubviews()
	{
		super.layoutSubviews()
		layer.cornerRadius = self.frame.width / 2
		clipsToBounds = true
	}

}
