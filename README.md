# SMNetworkManager

SMNetwork Manager will help to make the API reqest in an Object Oriented Way with the help of Alamofire. It will help you to make an api request easily with more cofigurable. 

# Features!
  - Cache api response if required, it easy to configure
  - In Offline, store user changes and synch back once network reachable.

### Requirement

* Swift 4+
* Xcode 10+


### Tech

Main Components
* `APIObject` - Every api request must have one api object. Where you will configure specific to the API. Which should be subclass of `APIBase`
* `APIConfig-Extension` - API config extension where you need to add Base URL & Other api paths.

# Example

##### `APIObject`

```
import Alamofire

let RP_Email = "email"
let RP_Password = "password"

class LoginAPI: APIBase {
    var email: String
    var password: String
    var errorMessage: String?

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    // MARK: URL
    override func urlForRequest() -> String {
        let urlString = APIConfig.BaseURL + APIConfig.LoginAPI
        return urlString
    }
    
    // MARK: HTTP method type
    override func requestType() -> Alamofire.HTTPMethod {
        return Alamofire.HTTPMethod.post
    }
    
    // MARK: API parameters
    override func requestParameter() -> Dictionary<String, Any>?{
    
        let user = [RP_Email : email, RP_Password : password] as [String : Any]
        return user
    }
    
    override func isJSONRequest() -> Bool {
        return true
    }
    
    override func responseHeader(header: [AnyHashable : Any]) {
        accessToken = header["access-token"] as? String
        client = header["client"] as? String
    }
    
    // MARK: Response parser
    override func parseAPIResponse(response: Dictionary<String, AnyObject>?) {
        Logger.log(message: response ?? "nil")
        
        guard let response  = response else {
            return
        }
        
        if let error = response[Error] as? String {
            errorMessage = error
            return
        } else if let errors = response[reponseError] as? [String], errors.count > 0 {
            errorMessage = errors[0]
            return
        }
        
        // Parse api response and store the model here. Which can be accessed from where the api request made.
        }
    }
}
```
#### `APIConfig-Extension`

```
extension APIConfig {

   static func configServerDetails() {
        APIConfig.isProduction = true
    
        APIConfig.ProductionURL = "http://mydomain.com/api/"
        APIConfig.StagingURL = "http://staging.mydomain.com/api/"
    
        APIConfig.ImageProductionURL = "http://mydomain.com"
        APIConfig.ImageStagingURL = "http://staging.mydomain.com"
    }
    
    // APIs
    static let APILogin = "v1/user/login.json"
}
```

- Trigger this class function `APIConfig.configServerDetails()` on application launch

#### `Login Request`

```
 @IBAction func loginAPI() {
        //Validation
        guard isValidationPassed() == true else {
            return
        }
        
        //Network check
        if let  isNetworkReachable = isNetworkReachable, isNetworkReachable == false  {
            // Show network error message here.
            return
        }
                    
        if let email = emailTextField.text, let password = passwordTextField.text {
            //API Call
            let loginAPI = LoginAPI(email: email, password: password)
            
            //Show busy view here.
            SMNetworkManager.sharedInstance.makeAPIRequest(apiObject: loginAPI) { [weak self] (reponse, error, isNetworkReachable) in
                
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    //Hide busy view
                    if let error = error {
                        if error.code == APIConfig.timeOutErrorCode { 
                           // Show timeour error message here.
                        }
                        else { // Handle any other error message here. }
                        return
                    }
                    
                    if let errorMessage = loginAPI.errorMessage {
                        // Show server error message here.
                        return
                    }
                    
                    // Handle UI / Other logics here.
                }
            }
        }
    }
```


License
----

The MIT License (MIT)
Copyright (c) 2018 https://github.com/mailmemani/SMNetworkManager

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
