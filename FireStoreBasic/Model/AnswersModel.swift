//
//  AnswersModel.swift
//  FireStoreBasic
//
//  Created by HechiZan on 2021/08/25.
//

import Foundation

struct AnswersModel {
    
    let answer:String
    let userName:String
    let docID:String
    let likeCount:Int
    let likeFlagDic:Dictionary<String,Any>
}
