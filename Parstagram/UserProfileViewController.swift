//
//  UserProfileViewController.swift
//  Parstagram
//
//  Created by Jesse Pantoja on 3/26/21.
//

import UIKit
import Parse
import AlamofireImage

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let user = PFUser.current()
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userNameField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        
        // Do any additional setup after loading the view.
        
        userNameField.text = self.user!["username"] as! String
        
        if user!["profilePic"] != nil{
            let imageFile = user!["profilePic"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            profilePicture.af_setImage(withURL: url)
        }
        
    }
    
    
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        profilePicture.image = scaledImage
        dismiss(animated: true, completion: nil)
    }
    
    
    func showAlert(){
        let alert = UIAlertController(title: "Success!", message: "Your profile picture has been updated.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onChangeProfilePicture(_ sender: Any) {
        
        let imageData = profilePicture.image!.pngData()
        let file = PFFileObject(data: imageData!)
        
        
        user!["profilePic"] = file
        
        user?.saveInBackground(block: { (success, error) in
            if success {
                self.showAlert()
                print("saved profile picture")
            } else {
                print("error in saving profile picture")
            }
        })
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
