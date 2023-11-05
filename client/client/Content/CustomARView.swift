import ARKit
import RealityKit
import SwiftUI

class CustomARView: ARView {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        setupARView()
    }
    
    dynamic required init?(coder decoder: NSCoder) {
        fatalError("(coder:) has not been initialized")
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    func setupARView() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
    }
}
