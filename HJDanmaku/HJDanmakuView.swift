//
//  HJDanmakuView.swift
//  Pods
//
//  Created by haijiao on 2017/8/2.
//
//

import UIKit

public struct HJDanmakuTime {
    
    public var time: Float
    public var interval: Float
    
    public func MaxTime() -> Float {
        return time + interval;
    }
    
}

public struct HJDanmakuAgent {
    
    let danmakuModel: HJDanmakuModel
    var danmakuCell: HJDanmakuCell?
    
    var force: Bool = false
    
    var toleranceCount = 4
    var remainingTime: Float = 5.0
    
    var px: Float = 0
    var py: Float = 0
    var size: CGSize = CGSize.zero
    
    var yIdx: Int = -1 // the line of trajectory, default -1
    
    public init(danmakuModel: HJDanmakuModel) {
        self.danmakuModel = danmakuModel
    }
    
}

//_______________________________________________________________________________________________________________

public class HJDanmakuSource {
    
    var spinLock: OSSpinLock = OS_SPINLOCK_INIT
    var danmakuAgents: Array<HJDanmakuAgent> = Array<HJDanmakuAgent>.init()
    
    static func danmakuSource(withModel mode: HJDanmakuMode) -> HJDanmakuSource {
        return HJDanmakuSource.init()
    }
    
    public func prepareDanmakus(_ danmakus: Array<HJDanmakuModel>, completion: @escaping () -> Swift.Void) {
        assert(false, "subClass implementation")
    }
    
    public func sendDanmaku(_ danmaku: HJDanmakuMode, forceRender force: Bool) {
        assert(false, "subClass implementation")
    }
    
    public func sendDanmakus(_ danmakus: Array<HJDanmakuMode>) {
        assert(false, "subClass implementation")
    }
    
    public func fetchDanmakuAgents(forTime time: HJDanmakuTime) -> Array<HJDanmakuMode>? {
        assert(false, "subClass implementation");
        return nil
    }
}

//_______________________________________________________________________________________________________________

public protocol HJDanmakuViewDelegate : NSObjectProtocol {
    
    // preparate completed. you can start render after callback
    func prepareCompleted(_ danmakuView: HJDanmakuView)
    
    // called before render. return NO will ignore danmaku
    func danmakuView(_ danmakuView: HJDanmakuView, shouldRenderDanmaku danmaku: HJDanmakuModel) -> Bool
    
    // display customization
    func danmakuView(_ danmakuView: HJDanmakuView, willDisplayCell cell: HJDanmakuCell, danmaku: HJDanmakuModel)
    func danmakuView(_ danmakuView: HJDanmakuView, didEndDisplayCell cell: HJDanmakuCell, danmaku: HJDanmakuModel)
    
    // selection customization
    func danmakuView(_ danmakuView: HJDanmakuView, shouldSelectCell cell: HJDanmakuCell, danmaku: HJDanmakuModel)
    func danmakuView(_ danmakuView: HJDanmakuView, didSelectCell cell: HJDanmakuCell, danmaku: HJDanmakuModel)
    
}

extension HJDanmakuViewDelegate {
    
    func prepareCompleted(_ danmakuView: HJDanmakuView) {}
    func danmakuView(_ danmakuView: HJDanmakuView, shouldRenderDanmaku danmaku: HJDanmakuModel) -> Bool {return true}
    
    func danmakuView(_ danmakuView: HJDanmakuView, willDisplayCell cell: HJDanmakuCell, danmaku: HJDanmakuModel) {}
    func danmakuView(_ danmakuView: HJDanmakuView, didEndDisplayCell cell: HJDanmakuCell, danmaku: HJDanmakuModel) {}
    
    func danmakuView(_ danmakuView: HJDanmakuView, shouldSelectCell cell: HJDanmakuCell, danmaku: HJDanmakuModel) {}
    func danmakuView(_ danmakuView: HJDanmakuView, didSelectCell cell: HJDanmakuCell, danmaku: HJDanmakuModel) {}

}

//_______________________________________________________________________________________________________________

public protocol HJDanmakuViewDateSource : NSObjectProtocol {
    
    // variable cell width support
    func danmakuView(_ danmakuView: HJDanmakuView, widthForDanmaku danmaku: HJDanmakuModel) -> Float
    
    // cell display. implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    func danmakuView(_ danmakuView: HJDanmakuView, cellForDanmaku danmaku: HJDanmakuModel) -> HJDanmakuCell
    
    // current play time, unit second, must implementation when videoModel
    func playTimeWithDanmakuView(_ danmakuView: HJDanmakuView) -> Float
    
    // play buffer status, when YES, stop render new danmaku, rendered danmaku in screen will continue anim until disappears, only valid when videoModel
    func bufferingWithDanmakuView(_ danmakuView: HJDanmakuView) -> Bool
    
}

extension HJDanmakuViewDateSource {
    
    func playTimeWithDanmakuView(_ danmakuView: HJDanmakuView) -> Float {return 0}
    
    func bufferingWithDanmakuView(_ danmakuView: HJDanmakuView) -> Bool {return false}
    
}

//_______________________________________________________________________________________________________________

open class HJDanmakuView: UIView {
    
    weak open var dataSource: HJDanmakuViewDateSource?
    weak open var delegate: HJDanmakuViewDelegate?
    
    public private(set) var isPrepared = false
    public private(set) var isPlaying = false
    
    let configuration: HJDanmakuConfiguration
    
    public init(frame: CGRect, configuration: HJDanmakuConfiguration) {
        self.configuration = configuration
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func register(_ cellClass: Swift.AnyClass?, forCellReuseIdentifier identifier: String) {
        
    }

    public func dequeueReusableCell(withIdentifier identifier: String) -> HJDanmakuCell {
        let cell: HJDanmakuCell = HJDanmakuCell.init(reuseIdentifier: "cell")
        cell.prepareForReuse()
        
        return HJDanmakuCell.init(reuseIdentifier:"cell")
    }
    
    // returns nil if cell is not visible
    public func danmakuForVisibleCell(_ danmakuCell: HJDanmakuCell) -> HJDanmakuCell? {
        return nil
    }
    
    var visibleCells: Array<HJDanmakuCell> {
        get {
            let visibleCells: Array<HJDanmakuCell> = Array<HJDanmakuCell>()
            
            return visibleCells;
        }
    }
    
    
    // you can prepare with nil when liveModel
    public func prepareDanmakus(_ danmakus: Array<HJDanmakuCell>) {
        
    }
    
    // be sure to call -prepareDanmakus before -play, when isPrepared is NO, call will be invalid
    public func play() {
        
    }
    
    public func pause() {
        
    }
    
    public func stop() {
        
    }
    
    public func clearScreen() {
        
    }
    
    /* send customization. when force, renderer will draw the danmaku immediately and ignore the maximum quantity limit.
     you should call -sendDanmakus: instead of -sendDanmaku:forceRender: to send the danmakus from a remote servers
     */
    public func sendDanmaku(_ danmaku: HJDanmakuMode, forceRender force: Bool) {
        
    }
    
    public func sendDanmakus(_danmakus: Array<HJDanmakuMode>) {
        
    }
}
