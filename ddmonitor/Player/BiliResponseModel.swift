//
//  BiliResponseModel.swift
//  ddmonitor
//
//  Created by apple on 1/18/21.
//

import Foundation
struct RoomInfoResponse: Decodable {
    let data: RoomInfoResponseData
}

struct RoomInfoResponseData: Decodable {
    let room_info: RoomInfoResponseDataRoomInfo
}
struct RoomInfoResponseDataRoomInfo: Decodable {
    let room_id: Int
    let live_status: Int
}

struct StreamInfoResponse: Decodable {
    let data: StreamInfoResponseData
}

struct StreamInfoResponseData: Decodable {
    let durl: [StreamInfoResponseDataURL]
}

struct StreamInfoResponseDataURL: Decodable {
    let url: String
}
