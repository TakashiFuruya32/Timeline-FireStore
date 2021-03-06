//
//  ViewController.swift
//  FireStoreBasic
//
//  Created by HechiZan on 2021/08/24.
//

import UIKit
import Firebase
import FirebaseFirestore
import EMAlertController
import FirebaseAuth

class ViewController: UIViewController,UITextViewDelegate {
    
    //DBの場所を指定する
    let db1 = Firestore.firestore().collection("Odai").document("IIezRG9laKPe5TNYQg7x")
    
    //DBの場所を指定する
    let db2 = Firestore.firestore()
    var userName = String()
    
    @IBOutlet weak var odaiLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    var idString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        //userNameを変数に格納
        if UserDefaults.standard.object(forKey: "userName") != nil{
            
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: "documentID") != nil{
            
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
            
        }else{
            
            idString = db2.collection("Answers").document().path
            print(idString)
            idString = String(idString.dropFirst(8))//先頭から８文字を捨てる
            UserDefaults.standard.setValue(idString, forKey: "documentID")
        }
        
        self.navigationController?.isNavigationBarHidden = true
        
        
        //Odaiのロード
        loadQustionData()
    }
    
    func loadQustionData(){
        
        db1.getDocument { (snapShot,error) in
            
            if error != nil{
                
                return
            }
            
            let data = snapShot?.data()
            
            self.odaiLabel.text = data!["odaiText"] as! String
        }
        
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.textView.resignFirstResponder()
    }
    
    @IBAction func send(_ sender: Any) {
        
        db2.collection("Answers").document(idString).setData(["answer":textView.text as Any,"userName":userName as Any,"postDate":Date().timeIntervalSince1970,"like":0,"likeFlagDic":[idString:false]])
        
        
        //送信完了のアラート
        //アラート
        let alert = EMAlertController(icon: UIImage(named: "check"), title: "投稿完了！", message: "みんなの回答を見てみよう！")
        let doneAction = EMAlertAction(title: "OK", style: .normal)
        alert.addAction(doneAction)
        present(alert, animated: true, completion: nil)
        textView.text = ""

        
    }
    
    
    
    
    @IBAction func checkAnswer(_ sender: Any) {
        
        //画面遷移
        
        let checkVC = self.storyboard?.instantiateViewController(identifier: "checkVC") as! CheckViewController
        checkVC.odaiString = odaiLabel.text!
        self.navigationController?.pushViewController(checkVC, animated: true)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "documentID")
            
        } catch let error as NSError {
            print(error)
        }
        
        self.navigationController?.popViewController(animated: true)
print("logout tap")
    }
   
}

