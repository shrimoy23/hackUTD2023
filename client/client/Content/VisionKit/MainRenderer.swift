import MetalKit
import ARKit

class MainRenderer {
  unowned let coordinator: Coordinator
  var session: ARSession
  var view: MTKView
  
  var device: MTLDevice
  var commandQueue: MTLCommandQueue
  var library: MTLLibrary
  
  static let numRenderBuffers = 3
  var renderIndex: Int = -1
  var renderSemaphore = DispatchSemaphore(value: numRenderBuffers)
  
  var updateTexturesSemaphore = DispatchSemaphore(value: 0)
  var colorTextureY: MTLTexture!
  var colorTextureCbCr: MTLTexture!
  var sceneDepthTexture: MTLTexture!
  var segmentationTexture: MTLTexture!
  var textureCache: CVMetalTextureCache
  
  var msaaTexture: MTLTexture
  var intermediateDepthTexture: MTLTexture
  var depthTexture: MTLTexture
  
  var userSettings: UserSettings!
  var cameraMeasurements: CameraMeasurements { userSettings.cameraMeasurements }
  var sceneRenderer: SceneRenderer!
  var sceneMeshReducer: SceneMeshReducer!
  
  init(session: ARSession, view: MTKView, coordinator: Coordinator) {
    self.session = session
    self.view = view
    self.coordinator = coordinator
    
    self.device = view.device!
    self.commandQueue = device.makeCommandQueue()!
    self.library = device.makeDefaultLibrary()!
    
    self.textureCache = CVMetalTextureCache?(
      nil, [kCVMetalTextureCacheMaximumTextureAgeKey : 1e-5], device,
      [kCVMetalTextureUsage : MTLTextureUsage.shaderRead.rawValue])!
    
    let textureDescriptor = MTLTextureDescriptor()
    let bounds = UIScreen.main.nativeBounds
    textureDescriptor.width  = Int(bounds.height)
    textureDescriptor.height = Int(bounds.width)
    
    textureDescriptor.usage = .renderTarget
    textureDescriptor.textureType = .type2D//.type2DMultisample
    textureDescriptor.storageMode = .memoryless
    textureDescriptor.sampleCount = 1//4
    
    textureDescriptor.pixelFormat = view.colorPixelFormat
    self.msaaTexture = device.makeTexture(descriptor: textureDescriptor)!
    self.msaaTexture.label = "MSAA Texture"
    
    textureDescriptor.pixelFormat = .depth32Float
    self.depthTexture = device.makeTexture(descriptor: textureDescriptor)!
    self.depthTexture.label = "Depth Texture"
    
    textureDescriptor.usage = [.renderTarget, .shaderRead]
    textureDescriptor.storageMode = .private

    textureDescriptor.sampleCount = 1//4//1
    self.intermediateDepthTexture = device.makeTexture(descriptor: textureDescriptor)!
    self.intermediateDepthTexture.label = "Depth Texture"
    
    self.userSettings = UserSettings(renderer: self, library: library)
    self.sceneRenderer = SceneRenderer(renderer: self, library: library)
    self.sceneMeshReducer = SceneMeshReducer(renderer: self, library: library)
  }
}

extension MainRenderer {
  func updateMesh() {
    guard sceneMeshReducer.shouldUpdateMesh else { return }
    
    DispatchQueue.global(qos: .utility).async(execute: { [unowned self] in
      sceneMeshReducer.reduceMeshes()
      sceneMeshReducer.justCompletedMatching = true
      sceneMeshReducer.currentlyMatchingMeshes = false
    })
  }
}

extension MainRenderer {
  func update() {
    renderSemaphore.wait()
    guard let frame = session.currentFrame else {
      renderSemaphore.signal()
      return
    }
    
    updateUniforms(frame: frame)
    
    DispatchQueue.global(qos: .userInteractive).async {
      self.asyncUpdateTextures(frame: frame)
      self.updateTexturesSemaphore.signal()
    }
    self.sceneMeshReducer.updateResources(frame: frame)
    
    let commandBuffer = commandQueue.makeCommandBuffer()!
    commandBuffer.addCompletedHandler { _ in
      self.renderSemaphore.signal()
    }
    
    sceneRenderer.drawZBuffer(commandBuffer: commandBuffer)
    
    updateTexturesSemaphore.wait()
    
    let drawable = view.currentDrawable!
    
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture//msaaTexture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].storeAction = .store//.multisampleResolve
//    renderPassDescriptor.colorAttachments[0].resolveTexture = drawable.texture
    renderPassDescriptor.depthAttachment.texture = intermediateDepthTexture
    renderPassDescriptor.depthAttachment.clearDepth = 0
    
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(
      descriptor: renderPassDescriptor)!
    renderEncoder.setFrontFacing(.counterClockwise)
    
    sceneRenderer.drawGeometry(renderEncoder: renderEncoder)
    renderEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
    
    self.updateMesh()
  }
  
  func updateUniforms(frame: ARFrame) {
    renderIndex = (renderIndex + 1) % 3
    cameraMeasurements.updateResources(frame: frame)
    sceneRenderer.updateResources(frame: frame)
  }
  
  func asyncUpdateTextures(frame: ARFrame) {
    func bind(
      _ pixelBuffer: CVPixelBuffer?,
      to reference: inout MTLTexture!,
      _ label: String,
      _ pixelFormat: MTLPixelFormat,
      _ width: Int,
      _ height: Int,
      _ planeIndex: Int = 0
    ) {
      guard let pixelBuffer = pixelBuffer else {
          reference = nil
          return
      }
      reference = textureCache.createMTLTexture(
        pixelBuffer, pixelFormat, width, height, planeIndex)!
      reference.label = label
    }
    
    bind(
      frame.segmentationBuffer, to: &segmentationTexture,
      "Segmentation Texture", .r8Unorm, 256, 192)
    bind(
      frame.sceneDepth?.depthMap, to: &sceneDepthTexture,
      "Scene Depth Texture", .r32Float, 256, 192)
    
    let width  = Int(cameraMeasurements.imageResolution.width)
    let height = Int(cameraMeasurements.imageResolution.height)
    bind(
      frame.capturedImage, to: &colorTextureY,
      "Color Texture (Y)", .r8Unorm, width, height, 0)
    bind(
      frame.capturedImage, to: &colorTextureCbCr,
      "Color Texture (CbCr)", .rg8Unorm, width >> 1, height >> 1, 1)
  }
}
