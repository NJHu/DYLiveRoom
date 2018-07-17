//
//  DYTarget_Trends.swift
//  DYTrends
//
//  Created by HuXuPeng on 2018/6/7.
//

import UIKit
import NJKit

@objc class Target_DYLiveRoom: NSObject {
    
    @objc func Action_DYLiveRoomController(params: [String: AnyObject]) -> UIViewController? {
        
        let liveRoom = NJDYLiveRoomController()
        liveRoom.roomId = params["roomId"] as? String
        return liveRoom
    }
}
