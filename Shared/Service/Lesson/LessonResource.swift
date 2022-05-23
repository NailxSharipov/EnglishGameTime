//
//  LessonResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 12.05.2022.
//

#if DEBUG
import SwiftUI
#endif
import Foundation

actor LessonResource {
    
    static let shared = LessonResource()
    
    private static let infoName = "Lesson.json"
    private let root: URL
    
    var data: [LessonData] = []
    private let fileManager = FileManager.default
    
    init() {
        self.root = Bundle.main.resourceURL?.appendingPathComponent("Lesson", isDirectory: true) ?? Bundle.main.bundleURL
    }
    
    func readMeta() async -> [Lesson.Meta] {
        let data = await self.readData()
        return data.map({ Lesson.Meta(data: $0) }).sorted(by: { $0.id < $1.id })
    }
    
    private func readData() async -> [LessonData] {
        guard data.isEmpty else { return data }

        let urls = fileManager.find(dir: root, fileExtension: "json")
        guard !urls.isEmpty else {
            assertionFailure("root is empty")
            return []
        }

        data = self.read(urls: urls)
        
#if DEBUG
        Self.validate(lessons: data)
#endif
        return data
    }

    private func read(urls: [URL]) -> [LessonData] {
        var lessons = [LessonData]()
        let decoder = JSONDecoder()
        for url in urls {
            guard let data = fileManager.contents(atPath: url.path) else { continue }
            
            do {
                let json = try decoder.decode(LessonData.Data.self, from: data)
                let root = url.deletingLastPathComponent()
                lessons.append(LessonData(root: root, data: json))
            } catch {
                debugPrint("\(url.lastPathComponent) error:")
                debugPrint(error)
                assertionFailure("JSON error")
            }
        }
        
        return lessons
    }
    
    func read(lessonId: Int) async -> Lesson {
        let list = await readData()
        let data = list.first(where: { $0.id == lessonId }) ?? data[0]
        
        return Lesson(data: data)
    }
    
    
#if DEBUG
    private static func validate(lessons: [LessonData]) {
        assert(!lessons.isEmpty, "No Lessons")
        
        var orderSet = Set<Int>(0..<lessons.count)
        var ids = Set<Int>()

        for lesson in lessons {
            assert(!lesson.name.isEmpty)
            assert(!ids.contains(lesson.id), "\(lesson.name): id(\(lesson.id) is not uniq")
            ids.insert(lesson.id)
            orderSet.remove(lesson.id)
        }
        
        assert(orderSet.isEmpty, "Order id problem")
    }
    
#endif
    
}

private extension FileManager {
    
    func find(dir: URL, fileExtension: String) -> [URL] {
        guard let urls = try? self.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {
            return []
        }

        var result = [URL]()
        for url in urls where url.isFileURL {
            if url.hasDirectoryPath {
                let subResult = self.find(dir: url, fileExtension: fileExtension)
                result.append(contentsOf: subResult)
            } else if url.pathExtension == fileExtension {
                result.append(url)
            }
        }
        
        return result
    }
    
}
