//
//  NJNowShowPlayController.swift
//  NJNowShowPlay
//
//  Created by NJHu on 2018/7/14.
//

import UIKit
import NJKit
import NJDYPlayer

fileprivate let WHScale: CGFloat =  0.56;

public class NJDYLiveRoomController: NJViewController {
    public var roomId: String?
    private var liveUrl: String?
    private let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * WHScale))
    private lazy var moviePlayer: NJPlayerController = NJPlayerController(containerView: self.containerView, delegate: self)
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupLiveRoomUI()
        
        if let roomId = self.roomId {
            NJProgressHUD.showLoading(in: self.view)
            let elementId = "html5player-video"
            let roomUrl = "https://www.douyu.com/\(roomId)"
            // 获得直播流
            NJLiveRoomStreamTool.sharedTool.nj_getStreamUrl(roomH5Url: roomUrl, elementId: elementId, success: {[weak self] (roomUrl, streamUrl) in
                self?.liveUrl = streamUrl
                if self?.moviePlayer.isPlaying != nil && !(self!.moviePlayer.isPlaying) {
                    self?.moviePlayer.prepareToPlay(contentURLString: streamUrl)
                }
                NJProgressHUD.hideLoading(in: self?.view)
            }) {[weak self] (roomUrl, error) in
                NJProgressHUD.hideLoading(in: self?.view)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK:- UI
extension NJDYLiveRoomController {
    private func setupLiveRoomUI() {
        let statusBarBg = UIView()
        statusBarBg.backgroundColor = UIColor.black
        view.addSubview(statusBarBg)
        statusBarBg.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(50)
        }
        nj_navigationBar.isHidden = true
        title = "斗鱼直播间"
        view.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(containerView)
        containerView.backgroundColor = UIColor.black
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIApplication.shared.nj_interfaceOrientation_isPortrait {
            containerView.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * WHScale)
        }else {
            containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
}

// MARK:- view-life
extension NJDYLiveRoomController {
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let liveUrl = self.liveUrl, !moviePlayer.isPlaying {
            moviePlayer.prepareToPlay(contentURLString: liveUrl)
        }
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        moviePlayer.shutdown()
    }
}

// MARK:- NJPlayerControllerDelegate
extension NJDYLiveRoomController: NJPlayerControllerDelegate {}

extension NJDYLiveRoomController: NJPlayerControllerPlaybackFinishDelegate {
    
}

extension NJDYLiveRoomController: NJPlayerControllerLoadStateDelegate {
    
}

extension NJDYLiveRoomController: NJPlayerControllerPlaybackStateStateDelegate {
    public func playerController(playbackState playerController: NJPlayerController, playing contentURLString: String) {
        
    }
}

// MARK:- StatusBar&Screen
extension NJDYLiveRoomController {
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    public  override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
    
}
