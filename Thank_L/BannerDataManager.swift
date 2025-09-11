//
//  BannerDataManager.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import SwiftUI
import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// 横幅数据管理器
/// 负责管理历史记录、模板存储和用户偏好设置
class BannerDataManager: ObservableObject {
    // MARK: - 单例模式
    static let shared = BannerDataManager()
    
    // MARK: - 发布属性
    /// 历史记录列表
    @Published var historyList: [BannerHistory] = []
    
    /// 用户自定义模板列表
    @Published var customTemplates: [BannerTemplate] = []
    
    /// 内置模板列表
    @Published var builtInTemplates: [BannerTemplate] = []
    
    /// 收藏的模板ID列表
    @Published var favoriteTemplateIds: Set<UUID> = []
    
    // MARK: - 私有属性
    private let userDefaults = UserDefaults.standard
    
    // MARK: - UserDefaults键名
    private enum Keys {
        static let historyList = "iBanner_HistoryList"
        static let customTemplates = "iBanner_CustomTemplates"
        static let favoriteTemplateIds = "iBanner_FavoriteTemplateIds"
        static let maxHistoryCount = "iBanner_MaxHistoryCount"
    }
    
    // MARK: - 配置常量
    /// 最大历史记录数量
    private let maxHistoryCount = 10
    
    /// 背景图片存储目录名
    private let backgroundImagesFolder = "BackgroundImages"
    
    // MARK: - 初始化
    private init() {
        setupImageDirectory()
        loadData()
        loadBuiltInTemplates()
    }
    
    // MARK: - 数据加载
    /// 从UserDefaults加载所有数据
    private func loadData() {
        loadHistoryList()
        loadCustomTemplates()
        loadFavoriteTemplateIds()
    }
    
    /// 加载历史记录
    private func loadHistoryList() {
        if let data = userDefaults.data(forKey: Keys.historyList) {
            do {
                let decoder = JSONDecoder()
                historyList = try decoder.decode([BannerHistory].self, from: data)
                // 按时间倒序排列
                historyList.sort { $0.timestamp > $1.timestamp }
            } catch {
                print("加载历史记录失败: \(error)")
                historyList = []
            }
        }
    }
    
    /// 加载自定义模板
    private func loadCustomTemplates() {
        if let data = userDefaults.data(forKey: Keys.customTemplates) {
            do {
                let decoder = JSONDecoder()
                customTemplates = try decoder.decode([BannerTemplate].self, from: data)
            } catch {
                print("加载自定义模板失败: \(error)")
                customTemplates = []
            }
        }
    }
    
    /// 加载收藏模板ID列表
    private func loadFavoriteTemplateIds() {
        if let data = userDefaults.data(forKey: Keys.favoriteTemplateIds) {
            do {
                let decoder = JSONDecoder()
                let ids = try decoder.decode([UUID].self, from: data)
                favoriteTemplateIds = Set(ids)
            } catch {
                print("加载收藏模板失败: \(error)")
                favoriteTemplateIds = []
            }
        }
    }
    
    /// 加载内置模板
    private func loadBuiltInTemplates() {
        builtInTemplates = BannerTemplate.getBuiltInTemplates()
    }
    
    // MARK: - 数据保存
    /// 保存历史记录到UserDefaults
    private func saveHistoryList() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(historyList)
            userDefaults.set(data, forKey: Keys.historyList)
        } catch {
            print("保存历史记录失败: \(error)")
        }
    }
    
    /// 保存自定义模板到UserDefaults
    private func saveCustomTemplates() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(customTemplates)
            userDefaults.set(data, forKey: Keys.customTemplates)
        } catch {
            print("保存自定义模板失败: \(error)")
        }
    }
    
    /// 保存收藏模板ID列表到UserDefaults
    private func saveFavoriteTemplateIds() {
        do {
            let encoder = JSONEncoder()
            let ids = Array(favoriteTemplateIds)
            let data = try encoder.encode(ids)
            userDefaults.set(data, forKey: Keys.favoriteTemplateIds)
        } catch {
            print("保存收藏模板失败: \(error)")
        }
    }
    
    // MARK: - 历史记录管理
    /// 添加历史记录
    /// - Parameter style: 横幅样式
    func addHistory(_ style: BannerStyle) {
        // 检查是否已存在相同的记录（基于文字内容）
        if let existingIndex = historyList.firstIndex(where: { $0.style.text == style.text }) {
            // 更新现有记录的使用时间
            historyList[existingIndex].timestamp = Date()
        } else {
            // 添加新记录
            let history = BannerHistory(text: style.text, style: style)
            historyList.insert(history, at: 0)
        }
        
        // 限制历史记录数量
        if historyList.count > maxHistoryCount {
            historyList = Array(historyList.prefix(maxHistoryCount))
        }
        
        // 重新排序并保存
        historyList.sort { $0.timestamp > $1.timestamp }
        saveHistoryList()
    }
    
    /// 删除历史记录
    /// - Parameter history: 要删除的历史记录
    func deleteHistory(_ history: BannerHistory) {
        historyList.removeAll { $0.id == history.id }
        saveHistoryList()
    }
    
    /// 清空所有历史记录
    func clearAllHistory() {
        historyList.removeAll()
        saveHistoryList()
    }
    
    // MARK: - 模板管理
    /// 获取所有模板（内置+自定义）
    func getAllTemplates() -> [BannerTemplate] {
        return builtInTemplates + customTemplates
    }
    
    /// 根据分类获取模板
    /// - Parameter category: 模板分类
    /// - Returns: 该分类下的所有模板
    func getTemplates(for category: TemplateCategory) -> [BannerTemplate] {
        let allTemplates = getAllTemplates()
        return allTemplates.filter { $0.category == category }
    }
    
    /// 获取收藏的模板
    func getFavoriteTemplates() -> [BannerTemplate] {
        let allTemplates = getAllTemplates()
        return allTemplates.filter { favoriteTemplateIds.contains($0.id) }
    }
    
    /// 添加自定义模板
    /// - Parameters:
    ///   - name: 模板名称
    ///   - style: 横幅样式
    ///   - category: 模板分类
    func addCustomTemplate(name: String, style: BannerStyle, category: TemplateCategory = .custom) {
        let template = BannerTemplate(name: name, text: style.text, style: style, category: category, isBuiltIn: false)
        customTemplates.append(template)
        saveCustomTemplates()
    }
    
    /// 删除自定义模板
    /// - Parameter template: 要删除的模板
    func deleteCustomTemplate(_ template: BannerTemplate) {
        // 只能删除自定义模板
        guard !template.isBuiltIn else { return }
        
        customTemplates.removeAll { $0.id == template.id }
        // 同时从收藏中移除
        favoriteTemplateIds.remove(template.id)
        
        saveCustomTemplates()
        saveFavoriteTemplateIds()
    }
    
    /// 切换模板收藏状态
    /// - Parameter template: 要切换收藏状态的模板
    func toggleTemplateFavorite(_ template: BannerTemplate) {
        if favoriteTemplateIds.contains(template.id) {
            favoriteTemplateIds.remove(template.id)
        } else {
            favoriteTemplateIds.insert(template.id)
        }
        saveFavoriteTemplateIds()
    }
    
    /// 检查模板是否被收藏
    /// - Parameter template: 要检查的模板
    /// - Returns: 是否被收藏
    func isTemplateFavorited(_ template: BannerTemplate) -> Bool {
        return favoriteTemplateIds.contains(template.id)
    }
    
    // MARK: - 搜索功能
    /// 搜索模板
    /// - Parameter keyword: 搜索关键词
    /// - Returns: 匹配的模板列表
    func searchTemplates(keyword: String) -> [BannerTemplate] {
        guard !keyword.isEmpty else { return getAllTemplates() }
        
        let allTemplates = getAllTemplates()
        return allTemplates.filter { template in
            template.name.localizedCaseInsensitiveContains(keyword) ||
            template.style.text.localizedCaseInsensitiveContains(keyword) ||
            template.category.displayName.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    /// 搜索历史记录
    /// - Parameter keyword: 搜索关键词
    /// - Returns: 匹配的历史记录列表
    func searchHistory(keyword: String) -> [BannerHistory] {
        guard !keyword.isEmpty else { return historyList }
        
        return historyList.filter { history in
            history.style.text.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    // MARK: - 数据统计
    /// 获取使用统计信息
    func getUsageStatistics() -> (historyCount: Int, customTemplateCount: Int, favoriteCount: Int) {
        return (
            historyCount: historyList.count,
            customTemplateCount: customTemplates.count,
            favoriteCount: favoriteTemplateIds.count
        )
    }
    
    // MARK: - 数据导入导出（扩展功能）
    /// 导出用户数据
    func exportUserData() -> Data? {
        let userData = [
            "history": historyList,
            "customTemplates": customTemplates,
            "favoriteIds": Array(favoriteTemplateIds)
        ] as [String : Any]
        
        do {
            return try JSONSerialization.data(withJSONObject: userData, options: .prettyPrinted)
        } catch {
            print("导出数据失败: \(error)")
            return nil
        }
    }
    
    /// 重置所有数据
    func resetAllData() {
        historyList.removeAll()
        customTemplates.removeAll()
        favoriteTemplateIds.removeAll()
        
        // 清除UserDefaults中的数据
        userDefaults.removeObject(forKey: Keys.historyList)
        userDefaults.removeObject(forKey: Keys.customTemplates)
        userDefaults.removeObject(forKey: Keys.favoriteTemplateIds)
        
        // 清理所有背景图片
        clearAllBackgroundImages()
    }
    
    // MARK: - 图片管理功能
    
    /// 设置图片存储目录
    private func setupImageDirectory() {
        let documentsPath = getDocumentsDirectory()
        let imagesPath = documentsPath.appendingPathComponent(backgroundImagesFolder)
        
        if !FileManager.default.fileExists(atPath: imagesPath.path) {
            do {
                try FileManager.default.createDirectory(at: imagesPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建图片目录失败: \(error)")
            }
        }
    }
    
    /// 获取Documents目录
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// 获取背景图片目录
    private func getBackgroundImagesDirectory() -> URL {
        return getDocumentsDirectory().appendingPathComponent(backgroundImagesFolder)
    }
    
    #if os(iOS)
    /// 保存UIImage到背景图片目录
    func saveBackgroundImage(_ image: UIImage) -> String? {
        let fileName = "bg_\(UUID().uuidString).jpg"
        let filePath = getBackgroundImagesDirectory().appendingPathComponent(fileName)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("图片数据转换失败")
            return nil
        }
        
        do {
            try imageData.write(to: filePath)
            return "\(backgroundImagesFolder)/\(fileName)"
        } catch {
            print("保存图片失败: \(error)")
            return nil
        }
    }
    #elseif os(macOS)
    /// 保存NSImage到背景图片目录
    func saveBackgroundImage(_ image: NSImage) -> String? {
        let fileName = "bg_\(UUID().uuidString).jpg"
        let filePath = getBackgroundImagesDirectory().appendingPathComponent(fileName)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let imageData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            print("图片数据转换失败")
            return nil
        }
        
        do {
            try imageData.write(to: filePath)
            return "\(backgroundImagesFolder)/\(fileName)"
        } catch {
            print("保存图片失败: \(error)")
            return nil
        }
    }
    #endif
    
    /// 删除背景图片
    func deleteBackgroundImage(at path: String) {
        let documentsPath = getDocumentsDirectory()
        let filePath = documentsPath.appendingPathComponent(path)
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                print("删除图片失败: \(error)")
            }
        }
    }
    
    /// 获取所有背景图片路径
    func getAllBackgroundImages() -> [String] {
        let imagesDirectory = getBackgroundImagesDirectory()
        
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: imagesDirectory.path)
            return fileNames.compactMap { fileName in
                let fullPath = "\(backgroundImagesFolder)/\(fileName)"
                return fullPath
            }
        } catch {
            print("获取图片列表失败: \(error)")
            return []
        }
    }
    
    /// 清理所有背景图片
    func clearAllBackgroundImages() {
        let imagesDirectory = getBackgroundImagesDirectory()
        
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: imagesDirectory.path)
            for fileName in fileNames {
                let filePath = imagesDirectory.appendingPathComponent(fileName)
                try FileManager.default.removeItem(at: filePath)
            }
        } catch {
            print("清理图片失败: \(error)")
        }
    }
    
    /// 检查图片文件是否存在
    func backgroundImageExists(at path: String) -> Bool {
        let documentsPath = getDocumentsDirectory()
        let filePath = documentsPath.appendingPathComponent(path)
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
    /// 获取图片文件大小（字节）
    func getBackgroundImageSize(at path: String) -> Int64? {
        let documentsPath = getDocumentsDirectory()
        let filePath = documentsPath.appendingPathComponent(path)
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath.path)
            return attributes[.size] as? Int64
        } catch {
            print("获取图片大小失败: \(error)")
            return nil
        }
    }
}
