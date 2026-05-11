import SwiftUI
import AVKit

struct HLSPlayerView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.loadStream(urlString: urlString)
    }

    static func dismantleUIView(_ uiView: PlayerUIView, coordinator: ()) {
        uiView.cleanup()
    }
}

final class PlayerUIView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var currentUrlString: String?

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    func loadStream(urlString: String) {
        guard urlString != currentUrlString else { return }
        cleanup()

        guard let url = URL(string: urlString) else { return }
        currentUrlString = urlString

        let player = AVPlayer(url: url)
        let layer = AVPlayerLayer()
        layer.player = player
        layer.videoGravity = .resizeAspect
        layer.frame = bounds

        self.layer.addSublayer(layer)
        self.player = player
        self.playerLayer = layer

        player.play()
    }

    func cleanup() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        currentUrlString = nil
    }
}
