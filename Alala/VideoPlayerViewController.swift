//
//  VideoPlayerViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 7. 15..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayerViewController: AVPlayerViewController {

  fileprivate let playButton = UIButton().then {
    $0.backgroundColor = UIColor.blue
    $0.setTitle("Pause", for: UIControlState.normal)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.showsPlaybackControls = false

    self.view.addSubview(playButton)

  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    playButton.snp.makeConstraints { make in
      make.height.width.equalTo(50)
      make.center.equalTo(self.view)
    }

  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("touch")
    if player?.rate == 0 {
      player!.play()

      playButton.setTitle("Pause", for: UIControlState.normal)
    } else {
      player!.pause()

      playButton.setTitle("Play", for: UIControlState.normal)
    }
  }

}
