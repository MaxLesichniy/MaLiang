//
//  TexturedBrush.swift
//  MaLiang
//
//  Created by Max Lesichniy on 27.10.2020.
//

import Foundation
import CoreGraphics
import Metal
import AVFoundation

public final class TexturedBrush: Brush {
    
    /// color of stroke
    public var foregroundImage: UIImage? {
        didSet {
            updateRenderingTexture()
        }
    }
    private var foregroundBrushTexture: MTLTexture?
    
    private func updateRenderingTexture() {
        guard let foregroundImage = foregroundImage,
              let target = target else { return }
        let resizedForegroundImage = resize(foregroundImage)
        if let texture = try? target.makeTexture(with: resizedForegroundImage.pngData()!) {
            foregroundBrushTexture = target.findTexture(by: texture.id)?.texture
        }
    }
    
    private func resize(_ image: UIImage) -> UIImage {
        guard let target = target else { return UIImage() }
        target.setNeedsLayout()
        target.layoutIfNeeded()
        let targetRect = CGRect(origin: .zero,
                                size: target.drawableSize / target.contentScaleFactor)
        return image.resized(in: targetRect)
    }
    
    /// make shader fragment function from the library made by makeShaderLibrary()
    /// overrides to provide your own fragment function
    public override func makeShaderFragmentFunction(from library: MTLLibrary) -> MTLFunction? {
        return library.makeFunction(name: "fragment_point_func_textured")
    }
    
    //    /// Blending options for this brush, overrides to implement your own blending options
    public override func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
        attachment.isBlendingEnabled = true
        
        attachment.rgbBlendOperation = .add
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        attachment.alphaBlendOperation = .add
        attachment.sourceAlphaBlendFactor = .sourceAlpha
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }
    
    /// render a specifyed line strip by this brush
    internal override func render(lineStrip: LineStrip, on renderTarget: RenderTarget? = nil) {
        
        let renderTarget = renderTarget ?? target?.screenTarget
        
        guard lineStrip.lines.count > 0, let target = renderTarget else {
            return
        }
        
        /// make sure reusable command buffer is ready
        target.prepareForDraw()
        
        /// get commandEncoder form resuable command buffer
        let commandEncoder = target.makeCommandEncoder()
        
        commandEncoder?.setRenderPipelineState(pipelineState)
        
        if let vertex_buffer = lineStrip.retrieveBuffers(rotation: rotation) {
            commandEncoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
            commandEncoder?.setVertexBuffer(target.uniform_buffer, offset: 0, index: 1)
            commandEncoder?.setVertexBuffer(target.transform_buffer, offset: 0, index: 2)
            if let texture = texture {
                commandEncoder?.setFragmentTexture(texture, index: 0)
            }
            if let testTexture = foregroundBrushTexture {
                commandEncoder?.setFragmentTexture(testTexture, index: 1)
            }
            commandEncoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: lineStrip.vertexCount)
        }
        
        commandEncoder?.endEncoding()
    }
}
