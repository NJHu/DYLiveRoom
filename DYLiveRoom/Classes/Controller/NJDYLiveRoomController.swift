//
//  NJNowShowPlayController.swift
//  NJNowShowPlay
//
//  Created by NJHu on 2018/7/14.
//

import UIKit
import NJKit
import NJDYPlayer

public class NJDYLiveRoomController: NJViewController {
    public var roomId: String?
    private var liveUrl: String?
    private let containerView = UIView()
    private var maskControlView = UIView()
    private var moviePlayer: NJPlayerController?
    override public func viewDidLoad() {
        super.viewDidLoad()
        nj_interactivePopDisabled = true
        view.backgroundColor = UIColor.groupTableViewBackground
        setupPlayer()
        setupMaskControlView()
        
        if let roomId = self.roomId {
            let elementId = "html5player-video"
            let roomUrl = "https://www.douyu.com/\(roomId)"
            // 获得直播流
            NJLiveRoomStreamTool.sharedTool.nj_getStreamUrl(roomH5Url: roomUrl, elementId: elementId, elementClass: nil, success: {[weak self] (roomUrl, streamUrl) in
                
                if self?.moviePlayer?.isPlaying != nil && !(self!.moviePlayer!.isPlaying) {
                    self?.moviePlayer?.prepareToPlay(contentURLString: streamUrl)
                }
                
            }) { (roomUrl, error) in
                
                
            }
        }
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let liveUrl = self.liveUrl {
            moviePlayer?.prepareToPlay(contentURLString: liveUrl)
        }
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        moviePlayer?.shutdown()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}
// MARK:- UI
extension NJDYLiveRoomController {
    private func setupPlayer() {
        
        view.addSubview(containerView)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = CGRect(x: 0, y: nj_navigationBar.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.56)
        maskControlView.backgroundColor = UIColor.clear
        
        moviePlayer = NJPlayerController(containerView: containerView, delegate: self)
    }
    private func setupMaskControlView() -> Void {
        containerView.addSubview(maskControlView)
        maskControlView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        maskControlView.frame = containerView.bounds
        maskControlView.backgroundColor = UIColor.clear
    }
}

// MARK:- NJPlayerControllerDelegate
extension NJDYLiveRoomController: NJPlayerControllerDelegate {
    
}

// MARK:- StatusBar&Screen
extension NJDYLiveRoomController {
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    public  override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    public  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    public override var shouldAutorotate: Bool {
        return true
    }
    // MARK: - about keyboard orientation
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown;
    }
    //返回最优先显示的屏幕方向
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}

// MARK:- action
extension NJDYLiveRoomController {
    @objc func closeThisLiveRoom() {
        dismiss(animated: true, completion: nil)
    }
}
