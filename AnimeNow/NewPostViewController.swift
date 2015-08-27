//
//  NewPostViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/24/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import Parse
import Bolts

public class NewPostViewController: CommentViewController {
    
    @IBOutlet weak var spoilersButton: UIButton!
    
    var hasSpoilers = false {
        didSet {
            if hasSpoilers {
                spoilersButton.setTitle(" Spoilers", forState: .Normal)
                spoilersButton.setTitleColor(UIColor.dropped(), forState: .Normal)
            } else {
                spoilersButton.setTitle("No Spoilers", forState: .Normal)
                spoilersButton.setTitleColor(UIColor(white: 0.75, alpha: 1.0), forState: .Normal)
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.becomeFirstResponder()
        
        if let editingPost = editingPost {
            hasSpoilers = (editingPost as! Postable).hasSpoilers
            textView.text = editingPost["content"] as? String
            if let parentPost = parentPost as? TimelinePostable {
                inReply.text = "  Editing Reply to \(parentPost.userTimeline.aozoraUsername)"
            } else {
                inReply.text = "  Editing Post"
            }
            photoButton.hidden = true
            videoButton.hidden = true
        } else {
            if let parentPost = parentPost as? TimelinePostable {
                inReply.text = "  In Reply to \(parentPost.userTimeline.aozoraUsername)"
            } else {
                inReply.text = "  New Post"
            }
        }
    }

    override func performPost() {
        super.performPost()
        
        if !validPost() {
            return
        }
        
        self.sendButton.setTitle("Sending...", forState: .Normal)
        self.sendButton.backgroundColor = UIColor.watching()
        self.sendButton.userInteractionEnabled = false
        
        switch threadType {
        case .Timeline:
            var timelinePost = TimelinePost()
            timelinePost.content = textView.text
            timelinePost.edited = false
            timelinePost.hasSpoilers = hasSpoilers
            if let selectedImageData = selectedImageData {
                timelinePost.images = [selectedImageData]
            }
            
            if let youtubeID = selectedVideoID {
                timelinePost.youtubeID = youtubeID
            }
            
            if let parentPost = parentPost as? TimelinePostable {
                timelinePost.replyLevel = 1
                timelinePost.userTimeline = parentPost.userTimeline
                timelinePost.parentPost = parentPost as? TimelinePost
            } else {
                timelinePost.replyLevel = 0
                timelinePost.userTimeline = postedIn
            }
            
            timelinePost.postedBy = postedBy
            timelinePost.saveInBackgroundWithBlock({ (result, error) -> Void in
                self.postedBy?.incrementPostCount()
                self.completeRequest(timelinePost, error: error)
            })
            
        default:
            var post = Post()
            post.content = textView.text
            post.edited = false
            post.hasSpoilers = hasSpoilers
            if let selectedImageData = selectedImageData {
                post.images = [selectedImageData]
            }
            
            if let youtubeID = selectedVideoID {
                post.youtubeID = youtubeID
            }
            
            if let parentPost = parentPost as? ThreadPostable {
                post.replyLevel = 1
                post.thread = parentPost.thread
                post.parentPost = parentPost as? Post
            } else {
                post.replyLevel = 0
                post.thread = thread!
            }
            post.thread.incrementKey("replies")
            post.postedBy = postedBy
            post.saveInBackgroundWithBlock({ (result, error) -> Void in
                self.postedBy?.incrementPostCount()
                self.completeRequest(post, error: error)
            })
        }
    }
    
    override func performUpdate(post: PFObject) {
        super.performUpdate(post)
        
        if !validPost() {
            return
        }
        
        self.sendButton.setTitle("Updating...", forState: .Normal)
        self.sendButton.backgroundColor = UIColor.watching()
        self.sendButton.userInteractionEnabled = false
        
        if var post = post as? Postable {
            post.hasSpoilers = hasSpoilers
            post.content = textView.text
            post.edited = true
        }
        
        post.saveInBackgroundWithBlock ({ (result, error) -> Void in
            self.completeRequest(post, error: error)
        })
    }
    
    func validPost() -> Bool {
        let content = textView.text
        // Validate post
        if count(content) < 2 {
            presentBasicAlertWithTitle("Too Short", message: "Message should be a 3 characters or longer")
            return false
        }
        return true
    }
  
    // MARK: - IBActions
    
    @IBAction func spoilersButtonPressed(sender: AnyObject) {
        
        hasSpoilers = !hasSpoilers
    }
}