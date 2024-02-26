//
//  MotionViewModel.swift
//  Motion Demo
//
//  Created by Anthony Li on 2/26/24.
//

import SwiftUI
import CoreMotion

protocol MotionViewModel: ObservableObject {
    var motion: CMDeviceMotion? { get }
    var isStarted: Bool { get }
    
    init()
    
    func start()
    func stop()
}

final class DeviceMotionViewModel: MotionViewModel {
    let motionManager = CMMotionManager()
    
    @Published private(set) var motion: CMDeviceMotion?
    @Published private(set) var isStarted = false
    
    func start() {
        motionManager.deviceMotionUpdateInterval = 1 / 15
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] motion, error in
            guard let self else { return }
            
            if let motion {
                self.motion = motion
            } else if let error {
                print("CMMotionManager ran into an error: \(error)")
                stop()
            }
        }
        
        isStarted = true
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        isStarted = false
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

final class HeadphoneMotionViewModel: MotionViewModel {
    let motionManager = CMHeadphoneMotionManager()
    
    @Published private(set) var motion: CMDeviceMotion?
    @Published private(set) var isStarted = false
    
    func start() {
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self else { return }
            
            if let motion {
                self.motion = motion
            } else if let error {
                print("CMHeadphoneMotionManager ran into an error: \(error)")
                stop()
            }
        }
        
        isStarted = true
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        isStarted = false
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
