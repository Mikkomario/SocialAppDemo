//
//  CircleView.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 31.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit

class CircleView: UIView, Shadowed
{
	override func awakeFromNib()
	{
		super.awakeFromNib()
		setDefaultShadow()
		layer.cornerRadius = self.frame.width / 2
	}
}
