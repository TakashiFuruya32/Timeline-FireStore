//
//  CommentViewController.swift
//  FireStoreBasic
//
//  Created by HechiZan on 2021/08/25.
//

import UIKit
import Firebase
import FirebaseFirestore

class CommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {


    var idString = String()
    var kaitouString = String()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var kaitouLabel: UILabel!
    
    var userName = String()
    
    let db = Firestore.firestore()
    
    var dataSets:[CommentModel] = []
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    //キーボードの上下用
    let screenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        kaitouLabel.text = kaitouString
        
        //userNameを変数に格納
        if UserDefaults.standard.object(forKey: "userName") != nil{
            
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        //キーボード上げる
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        //キーボード下げる
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(_ notification:NSNotification){
                  
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
                  
            textField.frame.origin.y = screenSize.height - keyboardHeight - textField.frame.height
                  sendButton.frame.origin.y = screenSize.height - keyboardHeight - sendButton.frame.height
                  
                  
     }

     @objc func keyboardWillHide(_ notification:NSNotification){

            textField.frame.origin.y = screenSize.height - textField.frame.height
                  
                  sendButton.frame.origin.y = screenSize.height - sendButton.frame.height
           
              
               guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else{return}


                  UIView.animate(withDuration: duration) {
                      
                      let transform = CGAffineTransform(translationX: 0, y: 0)
                      self.view.transform = transform
                      
                  }
                  
         }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        loadData()
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension//可変にする
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        tableView.rowHeight = 200
        
        let commentLabel = cell.contentView.viewWithTag(1) as! UILabel
        commentLabel.numberOfLines = 0
        commentLabel.text = "\(self.dataSets[indexPath.row].userName)くんの回答\n\(self.dataSets[indexPath.row].comment)"
        
        return cell
        
    }
    
    
    
    func loadData(){
        
        //Answersのdocumentを引っ張ってくる。新しい投稿が下にくるように
        db.collection("Answers").document(idString).collection("comments").order(by: "postDate").addSnapshotListener { (snapShot,error) in
            
            self.dataSets = []
            if error != nil{
                
                return
            }
            
            //snapShotの中にはドキュメントが全て入っている
            if let snapShotDoc = snapShot?.documents{
                
                for doc in snapShotDoc{
                    
                    let data = doc.data()
                    if let userName = data["userName"] as? String,let comment = data["comment"] as? String,let postDate = data["postDate"] as? Double{
                        
                        let commentModel = CommentModel(userName: userName, comment: comment, postDate: postDate)
                        self.dataSets.append(commentModel)
                    }
                    
                }
                self.dataSets.reverse()
                //全部入ったらリロード
                self.tableView.reloadData()
            }
        }
        
        //dataSetsに入れる
        
        
    }

    
    @IBAction func sendAction(_ sender: Any) {
        
        //もしtextFieldの値が空なら。の判定
        if textField.text?.isEmpty == true{
            
            return
        }
        
        db.collection("Answers").document(idString).collection("comments").document().setData(["userName":userName as Any,"comment":textField.text! as Any,"postDate":Date().timeIntervalSince1970])
        
        textField.text = ""
        textField.resignFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        textField.resignFirstResponder()
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
