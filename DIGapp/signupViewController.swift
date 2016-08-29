import UIKit
import Firebase //Firebaseをインポート
import FirebaseAuth

class signupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField! //Emailを打つためのTextField
    
    @IBOutlet var passwordTextField: UITextField! //Passwordを打つためのTextField
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self //デリゲートをセット
        passwordTextField.delegate = self //デリゲートをセット
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //ログインしていれば、遷移
        //FIRAuthがユーザー認証のためのフレーム
        //checkUserVerifyでチェックして、ログイン済みなら画面遷移
        if self.checkUserVerify() {
            self.transitionToView()
        }
    }
    
    // ログイン済みかどうかと、メールのバリデーションが完了しているか確認
    func checkUserVerify()  -> Bool {
        guard let user = FIRAuth.auth()?.currentUser else { return false }
        return user.emailVerified
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //サインアップボタン
    @IBAction func willSignup() {
        //サインアップのための関数、後ほど記載
        signup()
    }
    //ログイン画面への遷移ボタン
    @IBAction func willTransitionToLogin() {
        transitionToLogin()
    }
    
    //ログイン画面への遷移
    func transitionToLogin() {
        self.performSegueWithIdentifier("toLogin", sender: self)
    }
    //ListViewControllerへの遷移
    func transitionToView() {
        self.performSegueWithIdentifier("toView", sender: self)
    }
    //Returnキーを押すと、キーボードを隠す
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Signupのためのメソッド
    func signup() {
        //emailTextFieldとpasswordTextFieldに文字がなければ、その後の処理をしない
        guard let email = emailTextField.text else  { return }
        guard let password = passwordTextField.text else { return }
        //FIRAuth.auth()?.createUserWithEmailでサインアップ
        //第一引数にEmail、第二引数にパスワード
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            //エラーなしなら、認証完了
            if error == nil{
                // メールのバリデーションを行う
                user?.sendEmailVerificationWithCompletion({ (error) in
                    if error == nil {
                        // エラーがない場合にはそのままログイン画面に飛び、ログインしてもらう
                        self.transitionToLogin()
                    }else {
                        print("\(error?.localizedDescription)")
                    }
                })
            }else {
                print("\(error?.localizedDescription)")
            }
        })
    }
}
