//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Jesse Pantoja on 3/19/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Query the parse database
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell

        let post = posts[indexPath.row]
        // Save the username
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }
    
    // Everytime a user taps on a picture, this function is called
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Choose the post to add the comment to. Recall that posts is a PFObject
        let post = posts[indexPath.section]
        
        // Create the table in Parse
        let comment = PFObject(className: "Comments")
        // Text attribute for a comment
        comment["text"] = "This is a random comment"
        // post attribute contains the pointer to the picture
        comment["post"] = post
        // Author attribute tells you who wrote the post
        comment["author"] = PFUser.current()!
        
        // This is made up. Every post 'should' have an arry called comments and we should add this comment to the array
        // This essentially adds a new column called comments that contains all the comments for that post
        post.add(comment, forKey: "comments")
        
        // After we added the comment we save the post in Parse
        post.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onLogoutButton(_ sender: Any) {
        
        // Clear the logged in user from the Parse cache..i.e. tell Parse that the user should no longer be logged in
        PFUser.logOut()
        
        // Switch the user back to the login screen
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginViewController
        
    }
    

}
