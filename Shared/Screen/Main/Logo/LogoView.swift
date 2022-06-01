//
//  LogoView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 22.05.2022.
//

import CoreMotion
import SwiftUI

struct LogoView: View {

    let color: Color
    let alpha: CGFloat
    let animate: Bool
    
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        if animate {
            viewModel.start()
        } else {
            viewModel.stop()
        }
        
        return GeometryReader { proxy in
            layout(size: proxy.size)
        }
        .onDisappear() {
            viewModel.stop()
        }
    }
    
    private func layout(size: CGSize) -> some View {
        let w = size.width
        let sw = w * viewModel.scale
        let dx = 0.5 * size.width * (1 - viewModel.scale)
        let h = size.height
        
        return ZStack(alignment: .bottom) {
            EggView(color: color)
                .frame(height: 0.85 * h)
                .offset(x: 0.225 * sw + dx)
                .opacity(alpha)
            MuseumView(color: color)
                .frame(height: 0.5 * h)
                .offset(x: 0.35 * sw + dx)
                .opacity(alpha)
            SkyScraperView(color: color)
                .frame(height: h)
                .offset(x: 0.63 * sw + dx)
                .opacity(alpha)
            WheelView(color: color)
                .frame(height: 0.5 * h)
                .offset(x: 0.69 * sw + dx)
            CastleView(color: color)
                .frame(height: 0.65 * h)
                .offset(x: 0.28 * sw + dx)
            BridgeView(color: color)
                .frame(height: 0.55 * h)
                .offset(x: 0.45 * sw + dx)
            BigBanView(color: color, date: viewModel.time)
                .frame(height: 0.9 * h)
                .offset(x: 0.42 * sw + dx)
            Path { path in
                path.move(to: .init(x: 0.05 * w, y: h + 2))
                path.addLine(to: .init(x: 0.95 * w, y: h + 2))
            }
            .stroke(style: .init(lineWidth: 6, lineCap: .round))
            .foregroundColor(color)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private final class ViewModel: ObservableObject {
    
    var scale: CGFloat = 1
    private (set) var time: Date = Date()
    
    private var timer: Timer?
#if os(iOS)
    private let motion = CMMotionManager()
#endif
    
    func start() {
#if os(iOS)
        guard motion.isGyroAvailable else { return }
        motion.gyroUpdateInterval = 1.0 / 60.0
        if !motion.isGyroActive {
            motion.startGyroUpdates()
        }
#endif
        guard self.timer == nil else { return }
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
#if os(iOS)
            if let data = self.motion.gyroData {
                let a = data.rotationRate.z
                self.scale += 0.015 * a
                self.scale = max(min(1.25, self.scale), 0.75)
            }
#endif
            self.time = Date()
            self.objectWillChange.send()
        }

        self.timer = timer
        
        RunLoop.main.add(timer, forMode: .default)
    }
    
    func stop() {
        if let timer = self.timer {
           timer.invalidate()
            self.timer = nil
        }
#if os(iOS)
        if motion.isGyroActive {
            motion.stopGyroUpdates()
        }
#endif
    }
}
