import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase

class ViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    

    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(
                    messages[indexPath.row].senderDisplayName,
                    backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.whiteColor(),
                    font: UIFont.systemFontOfSize(10), diameter: 30)
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        // ユーザーアイコンに対してジェスチャーをつける
        let avatarImageTap = UITapGestureRecognizer(target: self, action: "tappedAvatar")
        cell.avatarImageView?.userInteractionEnabled = true
        cell.avatarImageView?.addGestureRecognizer(avatarImageTap)
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    func tappedAvatar() {
        print("tapped user avatar")
    }
    
    
    // 送信時刻を出すために高さを調整する
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item]
        if indexPath.item == 0 {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            if message.date.timeIntervalSinceDate(previousMessage.date) / 60 > 1 {
                return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
            }
        }
        return nil
    }
    
    
    // 送信時刻を出すために高さを調整する
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = messages[indexPath.item - 1]
            let message = messages[indexPath.item]
            if message.date .timeIntervalSinceDate(previousMessage.date) / 60 > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rootRef = FIRDatabase.database().reference()
        senderId = "Dummy2"
        senderDisplayName = "B"
//        title = "ChatChat"
        setupBubbles()
        var messageRef = rootRef.childByAppendingPath("messages")
    }
    
    
    func addMessage(id: String, text: String, displayName: String, postTime: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let postTime = dateFormatter.dateFromString(postTime)
        let message = JSQMessage(senderId: id, senderDisplayName: displayName, date: postTime, text: text)
        messages.append(message)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       observeMessages()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
                                     senderDisplayName: String!, date: NSDate!) {
        let rootRef = FIRDatabase.database().reference()
        var messageRef = rootRef.childByAppendingPath("messages")
        let itemRef = messageRef.childByAutoId() // 1
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let postTime = dateFormatter.stringFromDate(date)
        let messageItem = [ // 2
            "text": text,
            "senderId": senderId,
            "displayName": senderDisplayName,
            "postTime": postTime
        ]
        itemRef.setValue(messageItem) // 3
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
    }
    
    private func observeMessages() {
        let rootRef = FIRDatabase.database().reference()
        var messageRef = rootRef.childByAppendingPath("messages")
        // 1
        let messagesQuery = messageRef.queryLimitedToLast(25)
        // 2
        messagesQuery.observeEventType(.ChildAdded , withBlock: {snapshot in
            // 3
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String
            let displayName = snapshot.value!["displayName"] as! String
            let postTime = snapshot.value!["postTime"] as! String
            // 4
            self.addMessage(id, text: text, displayName: displayName, postTime: postTime)
            
            // 5
            self.finishReceivingMessage()
        })
    }
    
    
}



    
//    var messages = [JSQMessage]()
//    var messageNum: Int! = 0
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        observeMessages()
//    }
//    
//    func addMessage(id: String, text: String) {
//        let message = JSQMessage(senderId: id, displayName: "", text: text)
//        messages.append(message)
//    }
//    
//    private func observeMessages() {
//        let ref = FIRDatabase.database().reference()
//        // 1
//        let messagesQuery = ref.queryLimitedToLast(25)
//        // 2
//        messagesQuery.observeEventType(.ChildAdded, withBlock: { snapshot in
//            // 3
//            let senderId = snapshot.value!["senderId"] as! String
//            let text = snapshot.value!["text"] as! String
//            let displayName = snapshot.value!["displayName"] as! String
////            let postTime = snapshot.value!["postTime"]  as! String
//            
//            //postTimeをNSDate型にする
////            let dateFormatter = NSDateFormatter()
////            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
////            let date = dateFormatter.dateFromString(postTime)
//            print("hogehoge")
//            
//            // 4
//            self.addMessage(senderId, text: text)
//            
//            // 5
//            self.finishReceivingMessage()
//        })
//        
//    }
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        senderDisplayName = "A"
//        senderId = "Dummy1"
//        //        setupfirebase()
//    }
//    
//    //    func setupfirebase() {
//    //        let ref = FIRDatabase.database().reference()
//    //        //読み出しのメソッド
//    //        ref.observeEventType(.Value, withBlock: { snapshot in
//    //            //snapshot.value（中身）がnilだったら何もしない
//    //            guard let dic = snapshot.value as? Dictionary<String, AnyObject> else {
//    //                return
//    //            }
//    //            //snapshot.valueのmessagesのkeyが空だったら何もしない
//    //            guard let posts = dic["messages"] as? Dictionary<String, Dictionary<String, String>> else {
//    //                return
//    //            }
//    //            //Mapは<String, Object>。
//    //            self.messages = posts.values.map { dic in
//    //                let senderId = dic["senderId"] ?? ""
//    //                let text = dic["text"] ?? ""
//    //                let displayName = dic["displayName"] ?? ""
//    //                let postTime = dic["postTime"] ?? ""
//    //
//    //                //postTimeをNSDate型にする
//    //                let dateFormatter = NSDateFormatter()
//    //                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//    //                let date = dateFormatter.dateFromString(postTime)
//    //                print("hogehoge")
//    //
//    //                //                let message =
//    //                //                self.messages?.append(message)
//    //                //                self.finishReceivingMessageAnimated(true)
//    //
//    //                return JSQMessage(senderId: senderId, senderDisplayName: displayName, date: date, text: text)
//    //            }
//    //            self.collectionView.reloadData()
//    //        })
//    //
//    //
//    //    }
//    
//    
//    //    func setupfirebase() {
//    //        let ref = FIRDatabase.database().reference()
//    //        //読み出しのメソッド
//    //        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
//    //            //snapshot.value（中身）がnilだったら何もしない
//    //            let dic = snapshot.value as? Dictionary<String, AnyObject>
//    //            //snapshot.valueのmessagesのkeyが空だったら何もしない
//    //            let posts = dic!["messages"] as? Dictionary<String, Dictionary<String, String>>
//    //            //Mapは<String, Object>。
//    //
//    //            let senderId = String(dic!["senderId"] ?? "")
//    //            let text = dic!["text"] ?? ""
//    //            let displayName = dic!["displayName"] ?? ""
//    //            let postTime = String(dic!["postTime"] ?? "")
//    //
//    //            //postTimeをNSDate型にする
//    //            let dateFormatter = NSDateFormatter()
//    //            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//    //            let date = dateFormatter.dateFromString(postTime)
//    //            print("hogehoge")
//    //
//    //            let message = JSQMessage(senderId: senderId, displayName: String(displayName), text: String(text))
//    ////            let message = JSQMessage(senderId: String(senderId), senderDisplayName: String(displayName), date: date, text: String(text))
//    ////            self.messages.append(message)
//    ////            self.finishReceivingMessageAnimated(true)
//    //
//    //            self.collectionView.reloadData()
//    //        })
//    //
//    //
//    //    }
//    
//    
//    
//    // 省略
//    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
//        //        return messages[indexPath.row]
//        return messages[indexPath.item]
//    }
//    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
//        if messages[indexPath.row].senderId == senderId {
//            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(
//                UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))
//        } else {
//            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(
//                UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
//        }
//    }
//    
//    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
//        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? JSQMessagesCollectionViewCell
//        if messages[indexPath.row].senderId == senderId {
//            cell?.textView?.textColor = UIColor.whiteColor()
//        } else {
//            cell?.textView?.textColor = UIColor.darkGrayColor()
//        }
//        return cell!
//    }
//    
//    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
//    }
//    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
//        
//        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(
//            messages[indexPath.row].senderDisplayName,
//            backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.whiteColor(),
//            font: UIFont.systemFontOfSize(10), diameter: 30)
//    }
//    
//    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//        
//        let now = NSDate()
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//        let dateString = formatter.stringFromDate(now)
//        
//        inputToolbar.contentView.textView.text = ""
//        let ref = FIRDatabase.database().reference()
//        let messageRef = ref.child("messages").child("message\(messageNum)")
//        let message = ["senderId": senderId, "text": text, "displayName": senderDisplayName, "postTime": dateString]
//        messageRef.setValue(message)
//        messageNum = messageNum+1
//        //        ref.child("messages").childByAutoId().setValue(
//        //            ["senderId": senderId, "text": text, "displayName": senderDisplayName])
//    }
//}




//import UIKit
//import JSQMessagesViewController
//import Firebase
//import FirebaseDatabase
//
//class ViewController: JSQMessagesViewController {
//    var messages = [JSQMessage]()
////    var num: Int! = 0
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        senderDisplayName = "C"
//        senderId = "Dummy3"
//        let ref = FIRDatabase.database().reference()
//        ref.observeEventType(.Value, withBlock: { snapshot in
//            guard let dic = snapshot.value as? Dictionary<String, AnyObject> else {
//                return
//            }
//            guard let posts = dic["messages"] as? Dictionary<String, Dictionary<String, String>> else {
//                return
//            }
//            self.messages = posts.values.map { dic in
//                let senderId = dic["senderId"] ?? ""
//                let text = dic["text"] ?? ""
//                let displayName = dic["displayName"] ?? ""
//                return JSQMessage(senderId: senderId,  displayName: displayName, text: text)
//            }
//            self.collectionVew.reloadData()
//        })
//    }
//
//
//
//
//    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
//        return messages[indexPath.row]
//    }
//
//    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
//        if messages[indexPath.row].senderId == senderId {
//            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(
//                UIColor(red: 112/255, green: 192/255, blue:  75/255, alpha: 1))
//        } else {
//            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(
//                UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1))
//        }
//    }
//
//    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//
//        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as? JSQMessagesCollectionViewCell
//        if messages[indexPath.row].senderId == senderId {
//            cell?.textView?.textColor = UIColor.whiteColor()
//        } else {
//            cell?.textView?.textColor = UIColor.darkGrayColor()
//        }
//        return cell!
//    }
//
//    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
//
//        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(
//            messages[indexPath.row].senderDisplayName,
//            backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.whiteColor(),
//            font: UIFont.systemFontOfSize(10), diameter: 30)
//    }
//
//    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//        inputToolbar!.contentView!.textView!.text = ""
//        var ref = FIRDatabase.database().reference()
////        ref.child("messages").setValue(String(num): order)
//        ref.child("messages")..setValue(
//            ["senderId": senderId, "text": text, "displayName": senderDisplayName])
////        num = num+1
//    }
//
//}