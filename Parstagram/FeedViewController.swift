//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Jesse Pantoja on 3/19/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]()
    // We need a way to save the post to add a comment
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set placeholder properties of the comment bar
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        // Anytime you have something that can fire events you want to add this.
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Allows you to dismiss the keyboard by just dragging down on table view
        tableView.keyboardDismissMode = .interactive
        
        // Grab the post office notification center
        let center = NotificationCenter.default
        // Observe an event (keyboard will hide notification), when that event happens, call keyboardWillBeHidden function
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        // Clear the text in the comment field
        commentBar.inputTextView.text = nil
        // toggles the keyboard away
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Query the parse database
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        
        selectedPost.add(comment, forKey: "comments")
        // Save the comment in the backend
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        // We need to reload the data to have the comment appear in the table view
        tableView.reloadData()
        
        // Clear and dismiss the input bar
        // Clear the text in the comment field
        commentBar.inputTextView.text = nil
        // toggles the keyboard away
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Because we can have any number of comments within posts, we need to correctly determine how many rows should be returned
        let post = posts[section]
        // Double ?? lets us set default values in the event that the thing on the left is nil. So in this case it will be an empty array if there are no comments
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // +2 because a post will always contain one picture and an addcomment row
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []

        // We need to create different cell types for comments and the actual post. We know that posts though is always the 0th row. Everything else, if any, will be comments
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell

            // Save the username
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
            
        // Check if the the cell to return should be a comment cell
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            // row - 1 because the 0th comment is when indexPath.row is equal to 1 because 0 was the post
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            // The cell should be the add comment cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
        

    }
    
    // Everytime a user taps on a picture, this function is called
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Choose the post to add the comment to. Recall that posts is a PFObject
        let post = posts[indexPath.section]
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        // If the user selected a row that contains "add a comment"
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            // raise the keyboard
            commentBar.inputTextView.becomeFirstResponder()
            // Save the post that was selected, this post will be used in the messageInputBar function when the send button is pushed
            selectedPost = post
            
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
