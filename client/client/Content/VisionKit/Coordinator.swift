import SwiftUI
import MetalKit
import ARKit

class Coordinator: NSObject, ObservableObject {
  var session: ARSession
  var view: MTKView
  var renderer: MainRenderer!
  var gestureRecognizer: UILongPressGestureRecognizer
  
  @Published var isSharePresented: Bool = false
  var fileToExport: Data?
  
  override init() {
    self.session = ARSession()
    
    guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else {
      fatalError("This iOS device does not have LiDAR.")
    }
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.sceneReconstruction = .mesh
    configuration.frameSemantics.insert(.sceneDepth)
    configuration.frameSemantics.insert(.personSegmentation)
    
    if configuration.videoFormat.imageResolution != CGSize(width: 1920, height: 1440) {
      let formats = ARWorldTrackingConfiguration.supportedVideoFormats
      if let desiredFormat = formats.first(where: {
        $0.imageResolution == CGSize(width: 1920, height: 1440)
      }) {
        configuration.videoFormat = desiredFormat
      } else {
        fatalError("This device lacks 1920 x 1440 image resolution.")
      }
    }
    session.run(configuration)
    
    self.view = MTKView()
    self.gestureRecognizer = UILongPressGestureRecognizer()
    self.gestureRecognizer.allowableMovement = .greatestFiniteMagnitude
    self.gestureRecognizer.minimumPressDuration = 0
    self.view.addGestureRecognizer(self.gestureRecognizer)
    
    let nativeBounds = UIScreen.main.nativeBounds
    view.drawableSize = .init(width: nativeBounds.height, height: nativeBounds.width)
    view.autoResizeDrawable = false
    
    let castedLayer = view.layer as! CAMetalLayer
    castedLayer.framebufferOnly = false
    castedLayer.allowsNextDrawableTimeout = false
    
    view.device = MTLCreateSystemDefaultDevice()!
    view.colorPixelFormat = .bgra10_xr

    super.init()
    
    self.view.delegate = self
    self.renderer = MainRenderer(session: session, view: view, coordinator: self)
  }
}

extension Coordinator: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
  
  func draw(in view: MTKView) {
    precondition(view == self.view, "Incorrect MTKView.")
    renderer.update()
    
    if gestureRecognizer.state != .possible {
      self.isSharePresented = true
      if self.fileToExport == nil {
        self.fileToExport = renderer.sceneMeshReducer.exportData()
      }
    }
  }
}
