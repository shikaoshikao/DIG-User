//
//  textViewController.swift
//  DIGapp
//
//  Created by yoshikik on 2016/08/23.
//  Copyright © 2016年 Yoshiki Kawakita. All rights reserved.
//

import UIKit
import Firebase

class textViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField: UITextField! //投稿のためのTextField
    
    let ref = FIRDatabase.database().reference() //FirebaseDatabaseのルートを指定
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self //デリゲートをセット
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Returnキーを押すと、キーボードを隠す
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func create() {
        //textFieldになにも書かれてない場合は、その後の処理をしない
        guard let text = textField.text else { return }
        
        //ロートからログインしているユーザーのIDをchildにしてデータを作成
        //childByAutoId()でユーザーIDの下に、IDを自動生成してその中にデータを入れる
        //setValueでデータを送信する。第一引数に送信したいデータを辞書型で入れる
        //今回は記入内容と一緒にユーザーIDと時間を入れる
        //FIRServerValue.timestamp()で現在時間を取る
        self.ref.child((FIRAuth.auth()?.currentUser?.uid)!).childByAutoId().setValue(["user": (FIRAuth.auth()?.currentUser?.uid)!,"content": text, "date": FIRServerValue.timestamp()])
    }

    
    func logout() {
        do {
            //do-try-catchの中で、FIRAuth.auth()?.signOut()を呼ぶだけで、ログアウトが完了
            try FIRAuth.auth()?.signOut()
            //先頭のNavigationControllerに遷移
            let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Nav")
            self.presentViewController(storyboard, animated: true, completion: nil)
        }catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        
    }
    
    //データの作成か更新かを判定、trueなら作成、falseなら更新
    var isCreate = true
    //ListViewControllerからのデータの受け取りのための変数
    var selectedSnap: FIRDataSnapshot!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //selectedSnapがnilならその後の処理をしない
        guard let snap = self.selectedSnap else { return }
        //受け取ったselectedSnapを辞書型に変換
        let item = snap.value as! Dictionary<String, AnyObject>
        //textFieldに受け取ったデータのcontentを表示
        textField.text = item["content"] as? String
        //isCreateをfalseにし、更新するためであることを明示
        isCreate = false
    }
    //Postボタンを以下のように変更
    @IBAction func post(sender: UIButton) {
        //isCreateで作成か更新かを分岐
        if isCreate {
            create()
        }else {
            update() //更新するためのメソッド、後ほど記載
        }
    }
    
    //更新のためのメソッド
    func update() {
        //ルートからのchildをユーザーIDに指定
        //ユーザーIDからのchildを受け取ったデータのIDに指定
        //updateChildValueを使って更新
        ref.child((FIRAuth.auth()?.currentUser?.uid)!).child("\(self.selectedSnap.key)").updateChildValues(["user": (FIRAuth.auth()?.currentUser?.uid)!,"content": self.textField.text!, "date": FIRServerValue.timestamp()])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
