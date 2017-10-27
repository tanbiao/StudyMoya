//
//  TestService.swift
//  StudyMoya
//
//  Created by 谭彪 on 2017/10/25.
//  Copyright © 2017年 谭彪. All rights reserved.
//

import Foundation
import UIKit
import Result
//import Alamofire
import Moya

//let baseUrl = "http://apiv2.yangkeduo.com/operation/14/"

// let baseUrl = "https://api.github.com"

let baseUrl = "http://sdp.hzsb365.com"


/*这个节点闭包是添加自定义请求头*/
let endpointClosure = { (target: TestService) -> Endpoint<TestService> in
    
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
//    defaultEndpoint.adding(newHTTPHeaderFields: ["APP_NAME": "MY_AWESOME_APP"])
    
    
    return  defaultEndpoint.adding(newHTTPHeaderFields: ["APP_NAME": "MY_AWESOME_APP"])
}

let requestTimeoutClosure = { (endpoint: Endpoint<TestService>, done: @escaping MoyaProvider<TestService>.RequestResultClosure) in
    
    guard var request = endpoint.urlRequest else { return }
    request.timeoutInterval = 5    //设置请求超时时间
    done(.success(request))
}

/*这个插件通常用来控制Toastd的展示*/
let networkPlugin = NetworkActivityPlugin { (type) in
    
    switch type
    {
    case .began:
        
        NSLog("显示loading")
        
    case .ended:
        
        NSLog("隐藏loading")
    }
    
}

/*管理HTTP验证的插件*/
/*科普知识:URLCredential 与NSURLCredential 对应.  程序可以保留 credential. URLCredential.Persistence: 并有以下三种保留模式。
 NSURLCredentialPersistenceNone ：要求 URL 载入系统 “在用完相应的认证信息后立刻丢弃”。
 NSURLCredentialPersistenceForSession ：要求 URL 载入系统 “在应用终止时，丢弃相应的 credential ”。
 NSURLCredentialPersistencePermanent ：要求 URL 载入系统 "将相应的认证信息存入钥匙串（keychain），以便其他应用也能使用。*/
let credentialsPlugin = CredentialsPlugin{
   (type) in

    return  URLCredential()
}

/*这个插件是控制打应请求头的的信息和响应体的信息*/
let networkLoggerPlugin = NetworkLoggerPlugin{
  (t) in
    
    let data = Data(base64Encoded: "hhhhhhhh")
    
    return data!
}

/*这个是配置请求头里面的Authorization*/
let accessTokenPlugin = AccessTokenPlugin(token: "EXEEXEXEEXEXEX")

//AccessTokenPlugin 管理AccessToken的插件
//CredentialsPlugin 管理认证的插件
//NetworkActivityPlugin 管理网络状态的插件
//NetworkLoggerPlugin 管理网络log的插件



let plugins = [networkPlugin,accessTokenPlugin,networkLoggerPlugin,CustomPlugin()] as [PluginType]


func sendRequest() -> MoyaProvider<TestService>
{
   return  MoyaProvider<TestService>.init(endpointClosure: endpointClosure, requestClosure: requestTimeoutClosure,plugins: plugins)
}

func test<T:TargetType>() ->T
{
  return T.self as! T
}


enum TestService :TargetType
{
    case login(parameter :[String:Any])
    
    case logout(parameter :[String:Any])
    
    case zen
    
    var baseURL: URL{
        
        return URL(string: baseUrl)!
    
    }
    
    var path: String
    {
        switch self
        {
          case .login:
            
            return "groups"
         
          case .logout:
            return "/api/v1/user/login"
            
          case .zen:
            
            return "/zen"
        }
    }
    
    var method: Moya.Method {

        switch self {
        case .logout(parameter: _):
            return .post
            
        default:
            return .get
        }
    
    }

    var parameters: [String : Any]?
    {
        switch self
        {
          case .login(parameter: let parameter):
    
            return parameter
            
          case .logout(parameter: let parameter):
            
            return parameter
            
          default:
            return nil
          
        }
    }
    
    var parameterEncoding: ParameterEncoding
    {
       return JSONEncoding.default
    }
    
    /*单元测试用的*/
    var sampleData: Data
    {
       return "".data(using: .utf8)!
    }
    
    var task: Task
    {
      return .request
    }
    
    var validate: Bool {
        
        return true
    }
    
}

 class CustomPlugin: PluginType {
    
    // MARK: Plugin
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest
    {
        
        var urlRequest = request
        
        /*这里自定义协议头*/
        urlRequest.addHeader()
        //        var urlRequest = URLRequest(url:URL(string: baseUrl + target.path)!)
        
//        urlRequest.httpMethod = target.method.rawValue
//        urlRequest.url
//        urlRequest.timeoutInterval = 5
//        urlRequest.addHeader()
        print("准备请求...")
        return urlRequest
    }
    
    func willSend(_ request: RequestType, target: TargetType)
    {
        print("将要发送请求...")
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType)
    {
        switch result {
        case .failure(let error):
            print("请求发生错误:" + error.errorDescription!)
        case .success(let value):
            
            let json = try? JSONSerialization.jsonObject(with: value.data)
            
            print("data;\(String(describing: json))")
            
        }
        print("已经收到响应...")
    }
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError>
    {
        switch result
        {
            
         case .failure(let error):
            print("请求发生错误:" + error.errorDescription!)
         case .success(let value):
            print("data;\(value)")
        }

        return result
    }
    
}

extension URLRequest
{
    mutating func addHeader()
    {
        self.addValue("ERREEEER$", forHTTPHeaderField: "accessToken")
    }
}
