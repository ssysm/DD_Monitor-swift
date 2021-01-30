//
//  RoomInputComponent.swift
//  ddmonitor
//
//  Created by apple on 1/30/21.
//

import Cocoa

class RoomInputComponent: NSViewController {

    var playerSeq: Int = 0
    var roomID: String = ""
    @IBOutlet weak var playerText: NSTextField!
    @IBOutlet weak var playerRoomID: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.playerText.stringValue = "播放器" + String(self.playerSeq)
        self.playerRoomID.placeholderString = self.roomID
    }
    
    init(nibName: NSNib.Name?, bundle: Bundle?, roomID: String, playerSeq: Int){
        super.init(nibName: nibName, bundle: bundle)
        self.roomID = roomID
        self.playerSeq = playerSeq
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func getRoomID() -> String{
        return playerRoomID.stringValue
    }
}
