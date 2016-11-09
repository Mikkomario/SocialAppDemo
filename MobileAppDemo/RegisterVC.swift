//
//  RegisterVC.swift
//  MobileAppDemo
//
//  Created by Mikko Hilpinen on 9.11.2016.
//  Copyright © 2016 Mikkomario. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var confirmPasswordField: UITextField!
	@IBOutlet weak var profileImageView: UIImageView!
	
	private var imagePicker: UIImagePickerController = UIImagePickerController()
	
	private var email = ""
	private var password = ""
	private var imageSelected = false
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		emailField.text = email
		passwordField.text = password
		
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
    }
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
	{
		if let image = info[UIImagePickerControllerEditedImage] as? UIImage
		{
			profileImageView.image = image
			imageSelected = true
		}
		picker.dismiss(animated: true, completion: nil)
	}

	@IBAction func RegisterBtnPressed(_ sender: AnyObject)
	{
		// Checks that all data is provided and OK
		// TODO: Inform user if not
		guard let userName = usernameField.text else
		{
			print("AUTH: No userName provided")
			return
		}
		
		guard let password = passwordField.text else
		{
			print("AUTH: No password provided")
			return
		}
		
		guard let confirmedPassword = confirmPasswordField.text, confirmedPassword == password else
		{
			print("AUTH: Passwords don't match")
			return
		}
		
		var image: UIImage?
		if imageSelected
		{
			image = profileImageView.image
		}
		
		// Creates the user and logs in
		FIRAuth.auth()?.createUser(withEmail: email, password: password)
		{
			(user, error) in
			
			if let error = error
			{
				print("AUTH: FAILED TO CREATE USER \(error)")
			}
			else if let user = user
			{
				print("AUTH: SUCCESSFULLY CREATED NEW USER")
				User.post(uid: user.uid, provider: user.providerID, userName: userName, image: image)
				{
					user in
					user.push(overwrite: true)
					User.currentUser = user
					User.startTrackingCurrentUser()
					self.performSegue(withIdentifier: "ToFeed", sender: nil)
				}
			}
		}
	}
	
	@IBAction func cancelBtnPressed(_ sender: AnyObject)
	{
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func profilePictureTapped(_ sender: AnyObject)
	{
		present(imagePicker, animated: true, completion: nil)
	}

	func setBaseInfo(email: String, password: String)
	{
		self.email = email
		self.password = password
	}
}
