import UIKit
import Firebase //Firebaseをインポート

class loginViewController: UIViewController, UITextFieldDelegate {
    
    init() {
        super.init(nibName: nil, bundle: nil);
    }
    
    required init(coder aDecoder: NSCoder) {
        // FIXME: Why do we have to implement this?
        super.init(nibName: nil, bundle: nil)
    }
    
    @IBOutlet var emailTextField: UITextField! //Email用のTextFieldを追加
    
    @IBOutlet var passwordTextField: UITextField! //Password用のTextFieldを追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self //デリゲートをセット
        passwordTextField.delegate = self //デリゲートをセット
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //ログインボタン
    @IBAction func didRegisterUser() {
        //ログインのためのメソッド、後ほど記載
        login()
    }
    //Returnキーを押すと、キーボードを隠す
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //ログイン完了後に、ListViewControllerへの遷移のためのメソッド
    func transitionToView()  {
        self.performSegueWithIdentifier("toVC", sender: self)
    }
    
    //ログインのためのメソッド
    func login() {
        //EmailとPasswordのTextFieldに文字がなければ、その後の処理をしない
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        //signInWithEmailでログイン
        //第一引数にEmail、第二引数にパスワードを取ります
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            //エラーなしなら、ログイン完了
            if error == nil{
                print(FIRAuth.auth()?.currentUser)
                self.transitionToView()
            }else {
                print("error...\(error?.localizedDescription)")
            }
        })
    }
}