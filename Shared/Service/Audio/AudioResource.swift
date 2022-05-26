//
//  GameSoundResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 16.05.2022.
//

import AVFoundation
import Foundation

final class AudioResource {
    
    private struct Source {
        let file: String
        let volume: Float
        
        init(_ file: String, volume: Float = 0.5) {
            self.file = file
            self.volume = volume
        }
    }
    
    enum Sound {
        case click
        case incorrect
        case success
        case win
        case fail
        case start
        case timeIsRunnigOut
    }
    
    enum Music {
        case main
        case gameFast
        case gameSlow
    }

    static let shared = AudioResource()
    
    private static let soundMap: [Sound: Source] = [
        .click : Source("click.wav"),
        .incorrect : Source("incorrect.wav", volume: 0.5),
        .success : Source("success.wav"),
        .win : Source("success_end.wav"),
        .fail : Source("fail_end.wav"),
        .start : Source("start.wav"),
        .timeIsRunnigOut: Source("time_is_running.wav", volume: 0.3)
    ]

    private static let musicMap: [Music: Source] = [
        .main : Source("main_music_4.mp3", volume: 0.3),
        .gameFast : Source("game_music_1.mp3", volume: 0.15),
        .gameSlow : Source("game_music_1.mp3", volume: 0.15)
    ]

    private let rootSound: URL
    private let rootMusic: URL
    private let fileManager = FileManager.default
    private var sounds = [Sound: AVAudioPlayer]()
    private var musics = [Music: AVAudioPlayer]()
    private var prevMusic: Music?
    
    private var isLoaded: Bool {
        !musics.isEmpty && !sounds.isEmpty
    }
    
    init() {
        let root = Bundle.main.resourceURL ?? Bundle.main.bundleURL
        self.rootSound = root.appendingPathComponent("Sound", isDirectory: true)
        self.rootMusic = root.appendingPathComponent("Music", isDirectory: true)
    }
    
    func load() async {
        guard !isLoaded else { return }
        
        for (sound, source) in Self.soundMap {
            let audioFile = rootSound.add(name: source.file)
            do {
                let audio = try AVAudioPlayer(contentsOf: audioFile)
                audio.prepareToPlay()
                audio.volume = source.volume
                sounds[sound] = audio
            } catch {
                debugPrint("audioFile: \(audioFile)")
                assertionFailure("audio file is not exist")
            }
        }
        
        for (music, source) in Self.musicMap {
            let audioFile = rootMusic.add(name: source.file)
            do {
                let audio = try AVAudioPlayer(contentsOf: audioFile)
                audio.numberOfLoops = -1    // infinity
                audio.volume = source.volume
                musics[music] = audio
            } catch {
                debugPrint("audioFile: \(audioFile)")
                assertionFailure("audio file is not exist")
            }
        }
    }
    
    func play(sound: Sound) async {
        if !isLoaded {
            await self.load()
        }
        guard let audio = sounds[sound] else { return }
        audio.currentTime = 0
        audio.play()
    }
    
    func play(sound: Sound) {
        Task { [weak self] in
            await self?.play(sound: sound)
        }
    }
    
    func stop(sound: Sound) async {
        guard let audio = sounds[sound] else { return }
        audio.stop()
    }

    func stop(sound: Sound) {
        Task { [weak self] in
            await self?.stop(sound: sound)
        }
    }

    func play(music: Music) async {
        if !isLoaded {
            await self.load()
        }
        if let prev = prevMusic, let prevAudio = musics[prev] {
            if music == prevMusic && prevAudio.isPlaying {
                return
            }
            prevAudio.stop()
        }
        
        if let audio = musics[music] {
            audio.currentTime = 0
            audio.play()
        } else {
            assertionFailure("music not exist")
        }
        prevMusic = music
    }

    func play(music: Music) {
        Task { [weak self] in
            await self?.play(music: music)
        }
    }
    
    func stopMusic() async {
        for music in musics {
            music.value.stop()
        }
        self.prevMusic = nil
    }

    func stopMusic() {
        Task { [weak self] in
            await self?.stopMusic()
        }
    }

}
