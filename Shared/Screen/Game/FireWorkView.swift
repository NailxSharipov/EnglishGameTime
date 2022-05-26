//
//  FireWorkView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 25.05.2022.
//

import SwiftUI

struct FireWorkView: View {

    struct Animation: Equatable {

        struct Generation: Equatable {
            let maxLifeTime: ClosedRange<TimeInterval>
            let speed: ClosedRange<CGFloat>
            let size: CGFloat
            let friction: CGFloat
        }
        
        let count: ClosedRange<Int>
        let blust: ClosedRange<Int>
        let first: Generation
        let second: Generation
        let gravity: CGFloat
    }
    
    @ObservedObject
    private var animator = Animator()
    let animation: Animation
    let animate: Bool
    
    var body: some View {
        animator.animation = animation
        animator.set(animate: animate)
        return GeometryReader { proxy in
            if !animator.particles.isEmpty {
                TimelineView(.periodic(from: .now, by: 0.02)) { context in
                    ZStack {
                        ForEach(animator.iterate(size: proxy.size, time: context.date)) { line in
                            LineView(line: line)
                        }
                    }
                }
            }
        }
    }
}

private struct Line: Identifiable {
    let id: Int
    let a: CGPoint
    let b: CGPoint
    let size: CGFloat
}

private struct LineView: View {
    
    let line: Line

    var body: some View {
        Path() { path in
            path.move(to: line.a)
            path.addLine(to: line.b)
        }.strokedPath(.init(lineWidth: line.size, lineCap: .round)).foregroundColor(.white)
    }
}

private final class Animator: ObservableObject {
    
    struct Particle {
        let id: Int
        let generation: Int
        let maxLifeTime: TimeInterval
        var lifeTime: TimeInterval
        var position: CGPoint
        var velocity: CGPoint
        let size: CGFloat
        let friction: CGFloat
    }
    
    private let timeInterval: TimeInterval = 0
    private var prevTime: Date?
    private var size: CGSize = .zero
    var particles: [Particle] = []

    var animation: FireWorkView.Animation = .init(
        count: 0...0, blust: 0...0,
        first: .init(maxLifeTime: 0...0, speed: 0...0, size: 0, friction: 0),
        second: .init(maxLifeTime: 0...0, speed: 0...0, size: 0, friction: 0),
        gravity: 0
    ) {
        didSet {
            if oldValue != animation {
                prevTime = nil
            }
        }
    }
    
    func iterate(size: CGSize, time: Date) -> [Line] {
        guard let prevTime = self.prevTime else {
            return []
        }
        
        let coordSystem = CoordSystem(size: size)
        
        let dt = time.timeIntervalSince(prevTime)
        self.prevTime = time
        
        var lines = [Line]()
        
        var remove = Set<Int>()
        
        var newParticles = [Particle]()
        
        for i in 0..<particles.count {
            var particle = particles[i]

            guard particle.lifeTime < particle.maxLifeTime else {
                if particle.generation == 0 {
                    let list = self.blust(particle: particle)
                    newParticles.append(contentsOf: list)
                }
                remove.insert(particle.id)
                continue
            }
            
            let a = coordSystem.view(point: particle.position)
            
            var v = particle.velocity
            v.y += dt * animation.gravity
            v = particle.friction * v
            
            particle.velocity = v
            particle.position = particle.position + dt * v
            particle.lifeTime += dt
            particles[i] = particle

            if a.y > -1 {
                let b = coordSystem.view(point: particle.position)
                lines.append(Line(id: particle.id, a: a, b: b, size: particle.size))
            }
        }
        
        if !remove.isEmpty {
            particles = particles.filter({ !remove.contains($0.id) })
        }
        
        if !newParticles.isEmpty {
            particles.append(contentsOf: newParticles)
        }
        
        if particles.isEmpty {
            objectWillChange.send()
        }
        
        return lines
    }
    
    func set(animate: Bool) {
        if animate {
            if prevTime == nil {
                self.start()
            }
        } else {
            self.particles.removeAll()
            self.prevTime = nil
        }
    }

    
    private func start() {
        prevTime = Date()
        let n = Int.random(in: animation.count)
        particles.removeAll()
        
        let cen = CGPoint(x: 0, y: 2)

        for _ in 0..<n {
            let x = CGFloat.random(in: -4...4)
            let y = CGFloat.random(in: -2...(-1))
            let pos = CGPoint(x: x, y: y)
            let vel = CGFloat.random(in: animation.first.speed) * (cen - pos).normalized

            let maxLifeTime = TimeInterval.random(in: animation.first.maxLifeTime)
            
            let p = Particle(
                id: particles.count,
                generation: 0,
                maxLifeTime: maxLifeTime,
                lifeTime: 0,
                position: pos,
                velocity: vel,
                size: animation.first.size,
                friction: animation.first.friction
            )
            
            particles.append(p)
        }
    }

    private func blust(particle: Particle) -> [Particle] {
        let n = Int.random(in: animation.blust)
        let s = 2 * Double.pi / Double(n)
        var a = Double.random(in: 0..<s)
        
        var result = [Particle]()
        
        let pos = particle.position
        
        for i in 0..<n {
            let cs = CGFloat(cos(a))
            let sn = CGFloat(sin(a))
            let e: CGFloat = CGFloat.random(in: animation.second.speed)
            let v = e * CGPoint(x: cs, y: sn)
            a += s * Double.random(in: 0.8...1.2)
            
            let maxLifeTime = TimeInterval.random(in: animation.second.maxLifeTime)
            
            let p = Particle(
                id: 100 * (particle.id + 1) + i,
                generation: 1,
                maxLifeTime: maxLifeTime,
                lifeTime: 0,
                position: pos,
                velocity: v,
                size: animation.second.size,
                friction: animation.second.friction
            )
            
            result.append(p)
        }

        return result
    }
    
}

private struct CoordSystem {
    
    private let w: CGFloat
    private let h: CGFloat
    
    init(size: CGSize) {
        w = 0.5 * size.width
        h = 0.5 * size.height
    }
    
    func view(point p: CGPoint) -> CGPoint {
        let x = h * p.x + w
        let y = h * (1 - p.y)
        
        return CGPoint(x: x, y: y)
    }

}
