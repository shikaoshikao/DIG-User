import UIKit
import Firebase //Firebaseをインポート

class listViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView! //送信したデータを表示するTableView
    
    var contentArray: [FIRDataSnapshot] = [] //Fetchしたデータを入れておく配列、この配列をTableViewで表示
    
    let ref = FIRDatabase.database().reference() //Firebaseのルートを宣言しておく
    
    var snap: FIRDataSnapshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TableViewCellをNib登録、カスタムクラスを作成していますが、本記事では立ち入りません
        table.registerNib(UINib(nibName: "listTableViewCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        
        table.delegate = self //デリゲートをセット
        table.dataSource = self //データソースをセット
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //データを読み込むためのメソッド、後ほど記載
        self.read()
        //Cellの高さを調節、xibでカスタムクラスを作成した時に使うが、本記事では立ち入りません
        table.estimatedRowHeight = 56
        table.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        //画面が消えたときに、Firebaseのデータ読み取りのObserverを削除しておく
        ref.removeAllObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //ViewControllerへの遷移のボタン
    @IBAction func didSelectAdd() {
        self.transition()
    }
    
    //ViewControllerへの遷移
    func transition() {
        self.performSegueWithIdentifier("toView", sender: self)
    }
    //セルの数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentArray.count
    }
    //返すセルを決める
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCellWithIdentifier("ListCell") as! ListTableViewCell
        //ここから追加
        //配列の該当のデータをitemという定数に代入
        let item = contentArray[indexPath.row]
        //itemの中身を辞書型に変換
        let content = item.value as! Dictionary<String, AnyObject>
        //contentという添字で保存していた投稿内容を表示
        cell.contentLabel.text = String(content["content"]!)
        //dateという添字で保存していた投稿時間をtimeという定数に代入
        let time = content["date"] as! NSTimeInterval
        //getDate関数を使って、時間をtimestampから年月日に変換して表示
        cell.postDateLabel.text = self.getDate(time/1000)
        //ここまで追加
        return cell
    }
    
    func read()  {
        //FIRDataEventTypeを.Valueにすることにより、なにかしらの変化があった時に、実行
        //今回は、childでユーザーIDを指定することで、ユーザーが投稿したデータの一つ上のchildまで指定することになる
        ref.child((FIRAuth.auth()?.currentUser?.uid)!).observeEventType(.Value, withBlock: {(snapShots) in
            if snapShots.children.allObjects is [FIRDataSnapshot] {
                print("snapShots.children...\(snapShots.childrenCount)") //いくつのデータがあるかプリント
                
                print("snapShot...\(snapShots)")//読み込んだデータをプリント
                
                self.snap = snapShots
            }
            self.reload(self.snap)
        })
    }
    //読み込んだデータは最初すべてのデータが一つにまとまっているので、それらを分割して、配列に入れる
    func reload(snap: FIRDataSnapshot) {
        //FIRDataSnapshotが存在するか確認
        if snap.exists() {
            contentArray.removeAll()
            //1つになっているFIRDataSnapshotを分割し、配列に入れる
            for item in snap.children {
                contentArray.append(item as! FIRDataSnapshot)
            }
            //テーブルビューをリロード
            table.reloadData()
        }
    }
    
    //timestampで保存されている投稿時間を年月日に表示形式を変換する
    func getDate(number: NSTimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970: number)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.stringFromDate(date)
    }
    
    //スワイプ削除のメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //デリートボタンを追加
        if editingStyle == .Delete {
            //選択されたCellのNSIndexPathを渡し、データをFirebase上から削除
            //後ほど記載
            self.delete(deleteIndexPath: indexPath)
            //TableView上から削除
            table.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func delete(deleteIndexPath indexPath: NSIndexPath) {
        //ルートからのchildをユーザーのIDに指定
        //ユーザーIDからのchildを選択されたCellのデータのIDに指定
        //removeValueで削除
        ref.child((FIRAuth.auth()?.currentUser?.uid)!).child(contentArray[indexPath.row].key).removeValue()
        //ローカルの配列からも削除
        contentArray.removeAtIndex(indexPath.row)
    }
    
    
    //変更したいデータのための変数、CellがタップされるselectedSnapに値が代入される
    var selectedSnap: FIRDataSnapshot!
    //選択されたCellの番号を引数に取り、contentArrayからその番号の値を取り出し、selectedSnapに代入
    //その後遷移
    func didSelectRow(selectedIndexPath indexPath: NSIndexPath) {
        self.selectedSnap = contentArray[indexPath.row]
        self.transition()
    }
    //Cellがタップされると呼ばれる
    //上記のdidSelectedRowにタップされたCellのNSIndexPathを渡す
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSelectRow(selectedIndexPath: indexPath)
    }
    //遷移するときに呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //ViewControllerへの遷移か確認
        if segue.identifier == "toView" {
            let view = segue.destinationViewController as! textViewController
            //Cellがタップされたのか、Addボタンが押されたのかを確認
            if let snap = self.selectedSnap {
                //ViewControllerのselectedSnapに押されたCellのデータを渡す
                view.selectedSnap = snap
            }
        }
    }
}
