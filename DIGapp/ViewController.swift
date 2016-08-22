import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase

class ViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        senderDisplayName = "A"
        senderId = "Dummy1"
        let ref = FIRDatabase.database().reference()
        ref.observeEventType(.Value, withBlock: { snapshot in
            guard let dic = snapshot.value as? Dictionary<String, AnyObject> else {
                return
            }
            guard let posts = dic["messages"] as? Dictionary<String, Dictionary<String, String>> else {
                return
            }
            self.messages = posts.values.map { dic in
                let senderId = dic["senderId"] ?? ""
                let text = dic["text"] ?? ""
                let displayName = dic["displayName"] ?? ""
                return JSQMessage(senderId: senderId,  displayName: displayName, text: text)
            }
            self.collectionView!.reloadData()
        })
    }
    
   
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if messages[indexPath.row].senderId == senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(
                UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(
                UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? JSQMessagesCollectionViewCell
        if messages[indexPath.row].senderId == senderId {
            cell?.textView?.textColor = UIColor.whiteColor()
        } else {
            cell?.textView?.textColor = UIColor.darkGrayColor()
        }
        return cell!
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(
            messages[indexPath.row].senderDisplayName,
            backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.whiteColor(),
            font: UIFont.systemFontOfSize(10), diameter: 30)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        inputToolbar!.contentView!.textView!.text = ""
        var ref = FIRDatabase.database().reference()
        ref.child("messages").childByAutoId().setValue(
            ["senderId": senderId, "text": text, "displayName": senderDisplayName])
    }
    
}