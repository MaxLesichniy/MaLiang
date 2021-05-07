//
//  StampBrash.swift
//  MaLiang
//
//  Created by Max Lesichniy on 27.10.2020.
//

import Foundation

open class StampBrash: Brush {
    
    public required init(name: String?, textureID: String?, target: Canvas) {
        super.init(name: name, textureID: textureID, target: target)
        
        color = .red
        opacity = 1
        pointStep = 5
        pointSize = 80
        rotation = .fixed(0)
    }
    
    public override func makeShaderFragmentFunction(from library: MTLLibrary) -> MTLFunction? {
        return library.makeFunction(name: "fragment_point_func_stamp")
    }

    public override func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
        attachment.isBlendingEnabled = true

        attachment.rgbBlendOperation = .add
        attachment.alphaBlendOperation = .add

//        attachment.sourceRGBBlendFactor = .blendColor
//        attachment.sourceAlphaBlendFactor = .one
//
//        attachment.destinationRGBBlendFactor = .sourceColor
//        attachment.destinationAlphaBlendFactor = .sourceAlpha
        
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.sourceAlphaBlendFactor = .one

        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    
    }
    
}
