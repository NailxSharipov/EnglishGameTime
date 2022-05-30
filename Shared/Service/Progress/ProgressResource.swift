//
//  ProgressResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 18.05.2022.
//

import Foundation

actor ProgressResource {
    
    private static let winSaveKey = "winSaveKey"
    static let shared = ProgressResource()
    private let fileManager = FileManager.default
    private var progress = Progress(lessons: [], winCounter: 0)
    private var isLoaded = false
    
    private var file: URL? {
        fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("progress.json", isDirectory: false)
    }

    private var winCounts: URL? {
        fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("progress.json", isDirectory: false)
    }
    
    func load() async -> Progress {
        guard !isLoaded else {
            return progress
        }
        
        isLoaded = true
        
        guard let url = self.file else {
            assertionFailure("user don't have self folder")
            return progress
        }

        debugPrint("progress fileL \(url.path)")
        
        guard let data = try? Data(contentsOf: url), !data.isEmpty else {
            debugPrint("progress file is not exist")
            return progress
        }

        do {
            progress = try JSONDecoder().decode(Progress.self, from: data)
        } catch {
            debugPrint(error)
            assertionFailure("JSON error")
        }
        
        return progress
    }
    
    func save(_ lesson: Progress.Lesson) async {
        var progress = await self.load()
        
        if let index = progress.lessons.firstIndex(where: { $0.id == lesson.id }) {
            progress.lessons[index] = lesson
        } else {
            progress.lessons.append(lesson)
        }
        
        if lesson.lifeCount != nil {
            progress.winCounter += 1
        }

        self.progress = progress
        
        guard
            let path = self.file?.path,
            let data = try? JSONEncoder().encode(progress) else {
            assertionFailure("progress file is not created")
            return
        }
        
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
        
        fileManager.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    func lesson(id: Int) async -> Progress.Lesson {
        let progress = await self.load()
        if let lesson = progress.lessons.first(where: { $0.id == id }) {
            return lesson
        } else {
            return Progress.Lesson(id: id, time: nil, lifeCount: nil)
        }
    }

    func allLesson() async -> [Int: Progress.Lesson] {
        let progress = await self.load()
        var map = [Int: Progress.Lesson]()
        for lesson in progress.lessons {
            map[lesson.id] = lesson
        }
        
        return map
    }
    
    func winCounts() async -> Int {
        let progress = await self.load()
        return progress.winCounter
    }
}
