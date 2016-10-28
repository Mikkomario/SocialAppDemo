//
//  FancyView.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 28.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit

class FancyView: UIView, Shadowed
{
	override func awakeFromNib()
	{
		super.awakeFromNib()
		setDefaultShadow()
	}
}
