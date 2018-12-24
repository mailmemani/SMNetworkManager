//
//  APIKeys.swift
//  APIManager-Alamofire
//
//  Created by Subramanian on 26/7/18.
//  Copyright © 2018 Subramanian. All rights reserved.
//


import Foundation

let API_Environment_Key = "isProductionEnvironment"

struct APIConfig {
    
    
    // Config
    static let isProduction: Bool = Bundle.main.infoDictionary?[API_Environment_Key] as? Bool ?? true
    
    static let ProductionURL: String = "http://vardrapport.cortexcraft.com/"
    static let StagingURL: String = "http://vardrapport.cortexcraft.com/"
    
    static let ImageProductionURL: String = ""
    static let ImageStagingURL: String = ""
    
    static var BaseURL: String {
        if isProduction  {
            return ProductionURL
        } else {
            return StagingURL
        }
    }
    
    static var ImageBaseURL: String {
        if isProduction  {
            return ImageProductionURL
        } else {
            return ImageStagingURL
        }
    }
    
    static let  timeoutInterval = 20.0 // In Seconds
    static let timeOutErrorCode = -1001
    
    static let LoginAPI = "api/v1/auth/sign_in.json"
    static let RegistrationAPI = "api/v1/auth/invitation.json"
    static let ForgotPasswordAPI = "api/v1/auth/password.json"
    static let NewPasswordAPI = "api/v1/auth/password.json"
    static let PushTokenAPI = "api/v1/update_token.json"
    static let NotificationListAPI = "api/v1/notifications?hospital_id=%d&notification_type=%@"
    static let TaskDetailAPI = "api/v1/tasks/%d.json?hospital_id=%d&include_completed=%@"
    static let FormDetailAPI = "api/v1/forms/%d.json?hospital_id=%d"
    static let TaskListAPI = "api/v1/tasks/filter.json?hospital_id=%d"
    static let TaskListByRoomAPI = "api/v1/tasks/tasks_by_room.json?hospital_id=%d"
    static let BeaconListAPI = "api/v1/beacons.json?hospital_id=%d"
    static let SubmitFormDetailAPI = "api/v1/form_values.json?hospital_id=%d"
    static let LogoutAPI = "api/v1/auth/sign_out.json"
    static let ChangePasswordAPI = "api/v1/users/set_password.json"
    static let EmergencyFormAPI = "api/v1/forms/forms_by_category.json?hospital_id=%d&category_id=%d"
    static let FormCategoryAPI = "api/v1/forms/form_categories.json?hospital_id=%d"
    static let ScheduleAPI = "api/v1/staff_schedules/schedules_by_month.json?hospital_id=%d&month=%@"
    static let ScheduleStatusUpdateAPI = "api/v1/staff_schedules/%d/update_status?event=%@&hospital_id=%d"
    static let NewNotificationCountAPI = "api/v1/notifications/any_new_notifications.json"
    static let ProfileDetailAPI = "api/v1/users/profile.json"
    static let UpdateProfileAPI = "api/v1/users/%d.json"
}


