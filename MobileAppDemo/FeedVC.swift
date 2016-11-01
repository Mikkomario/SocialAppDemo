//
//  FeedVC.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 31.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDataSource
{
	@IBOutlet weak var feedTableView: UITableView!

    override func viewDidLoad()
	{
        super.viewDidLoad()

		feedTableView.dataSource = self
		
		feedTableView.rowHeight = UITableViewAutomaticDimension
		feedTableView.estimatedRowHeight = 320
    }
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		return UITableViewCell()
	}
	
	@IBAction func signOutButtonPressed(_ sender: AnyObject)
	{
		try! FIRAuth.auth()?.signOut()
		KeychainWrapper.standard.removeObject(forKey: KEY_UID)
		dismiss(animated: true, completion: nil)
	}
}
