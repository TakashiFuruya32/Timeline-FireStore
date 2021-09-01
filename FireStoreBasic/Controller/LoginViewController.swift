//
//  LoginViewController.swift
//  FireStoreBasic
//
//  Created by HechiZan on 2021/08/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func login(){
        
        //匿名ログイン
        Auth.auth().signInAnonymously { (result,error) in
            
            let user = result?.user
            print(user)
            
            UserDefaults.standard.setValue(self.textField.text, forKey: "userName")
            
            let viewVC = self.storyboard?.instantiateViewController(identifier: "viewVC") as! ViewController
            self.navigationController?.pushViewController(viewVC, animated: true)
        }
        
    }

    @IBAction func done(_ sender: Any) {
        
        login()
        
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
