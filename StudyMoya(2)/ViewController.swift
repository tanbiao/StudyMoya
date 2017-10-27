//
//  ViewController.swift
//  StudyMoya(2)
//
//  Created by 谭彪 on 2017/10/26.
//  Copyright © 2017年 谭彪. All rights reserved.
//

import UIKit
import Alamofire
import Moya

class ViewController: UIViewController {
    
    let param = ["opt_type":1,
                 "size":20,
                 "offset":(2 - 1) * 20]
    
    let logParam = ["phone":"13689652209","sms_code":"123456"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
                
        sendRequest().request(.logout(parameter: logParam)) { (result) in
            
            switch result
            {
              case .failure(let error):
                
                print("error:" + error.errorDescription!)
                
              case .success(let value):
                
                let json = try? JSONSerialization.jsonObject(with: value.data)
                print("成功:\(String(describing: json))")
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

