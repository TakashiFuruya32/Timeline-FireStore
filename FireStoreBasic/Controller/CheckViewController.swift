//
//  CheckViewController.swift
//  FireStoreBasic
//
//  Created by HechiZan on 2021/08/24.
//

import UIKit
import Firebase
import FirebaseFirestore

class CheckViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    

    var odaiString = String()
    
    @IBOutlet weak var odaiLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var dataSets:[AnswersModel] = []
    
    var idString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        odaiLabel.text = odaiString
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        if UserDefaults.standard.object(forKey: "documentID") != nil{
            
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        }
        // Do any additional setup after loading the view.
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath) as! CustomCell
        tableView.rowHeight = 200

        cell.answerLabel.numberOfLines = 0
        cell.answerLabel.text = "\(self.dataSets[indexPath.row].userName)くんの回答\n\(self.dataSets[indexPath.row].answer)"
        cell.likeButton.tag = indexPath.row
        cell.countLabel.text = String(self.dataSets[indexPath.row].likeCount) + "いいね"
        cell.likeButton.addTarget(self, action: #selector(like(_:)), for: .touchUpInside)
        
        if (self.dataSets[indexPath.row].likeFlagDic[idString] != nil) == true{
            
            let flag = self.dataSets[indexPath.row].likeFlagDic[idString]
            
            if flag! as! Bool == true{
                
                cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
                
            }else{
                
                cell.likeButton.setImage(UIImage(named: "nolike"), for: .normal)
                
            }
            
            
        }
        
        return cell
        
    }
    
    @objc func like(_ sender:UIButton){
        
        var count = Int()
        let flag = self.dataSets[sender.tag].likeFlagDic[idString]
        
        if flag == nil {
            
            count = self.dataSets[sender.tag].likeCount + 1
            db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
            
        }else{
            
            if flag! as! Bool == true{
                
                count = self.dataSets[sender.tag].likeCount - 1
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString:false]], merge: true)
                
            }else{
                
                count = self.dataSets[sender.tag].likeCount + 1
                db.collection("Answers").document(dataSets[sender.tag].docID).setData(["likeFlagDic":[idString:true]], merge: true)
            }
        }
        
        db.collection("Answers").document(dataSets[sender.tag].docID).updateData(["like":count],completion: nil)
        tableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension//可変にする
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let commentVC = self.storyboard?.instantiateViewController(identifier: "commentVC") as! CommentViewController
        commentVC.idString = dataSets[indexPath.row].docID
        commentVC.kaitouString = "\(self.dataSets[indexPath.row].userName)くんの回答\n\(self.dataSets[indexPath.row].answer)"
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func loadData(){
        
        //Answersのdocumentを引っ張ってくる。新しい投稿が下にくるように
        db.collection("Answers").order(by: "postDate").addSnapshotListener { (snapShot,error) in
            
            self.dataSets = []
            if error != nil{
                
                return
            }
            
            //snapShotの中にはドキュメントが全て入っている
            if let snapShotDoc = snapShot?.documents{
                
                for doc in snapShotDoc{
                    
                    let data = doc.data()
                    if let answer = data["answer"] as? String,let userName = data["userName"] as? String,let likeCount = data["like"] as? Int,let likeFlagDic = data["likeFlagDic"]as? Dictionary<String,Bool>{
                        
                        if likeFlagDic["\(doc.documentID)"] != nil{
                            
                            let answerModel = AnswersModel(answer: answer, userName: userName, docID: doc.documentID, likeCount: likeCount, likeFlagDic: likeFlagDic)
                            
                            self.dataSets.append(answerModel)
                        }
                    }
                
                }
          
                //全部入ったらリロード
                self.tableView.reloadData()
            }
        }
        
        //dataSetsに入れる
        
        
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
