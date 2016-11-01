//
//  FeedVC.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 31.10.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftKeychainWrapper
import SwiftyJSON

class FeedVC: UIViewController, UITableViewDataSource
{
	@IBOutlet weak var feedTableView: UITableView!

	var posts = [Post]()
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

		feedTableView.dataSource = self
		
		feedTableView.rowHeight = UITableViewAutomaticDimension
		feedTableView.estimatedRowHeight = 320
		
		Post.parentReference.observe(.value, with:
		{
			snapshot in
			
			self.posts = [] // Clears previous posts
			if let postSnaps = snapshot.children.allObjects as? [FIRDataSnapshot]
			{
				for postSnap in postSnaps
				{
					print("PARSE: \(postSnap.value)")
					let json = JSON(postSnap.value)
					self.posts.append(Post.fromJSON(json, id: postSnap.key))
				}
			}
			self.feedTableView.reloadData()
		})
    }
	
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return posts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell
		{
			cell.configureCell(post: posts[indexPath.row])
			return cell
		}
		else
		{
			fatalError()
		}
	}
	
	@IBAction func signOutButtonPressed(_ sender: AnyObject)
	{
		try! FIRAuth.auth()?.signOut()
		KeychainWrapper.standard.removeObject(forKey: KEY_UID)
		dismiss(animated: true, completion: nil)
	}
}
