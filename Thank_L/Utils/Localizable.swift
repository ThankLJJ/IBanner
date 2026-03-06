//
//  Localizable.swift
//  iBanner - 临时横幅工具
//
//  Created by L on 2024/7/13.
//  Copyright © 2024 L. All rights reserved.
//

import Foundation

/// 类型安全的本地化封装
enum L10n {
    // MARK: - App
    enum App {
        static let name = NSLocalizedString("app.name", value: "iBanner", comment: "App name")
        static let cancel = NSLocalizedString("app.cancel", value: "Cancel", comment: "Cancel button")
        static let done = NSLocalizedString("app.done", value: "Done", comment: "Done button")
        static let delete = NSLocalizedString("app.delete", value: "Delete", comment: "Delete button")
        static let save = NSLocalizedString("app.save", value: "Save", comment: "Save button")
        static let clear = NSLocalizedString("app.clear", value: "Clear", comment: "Clear button")
        static let search = NSLocalizedString("app.search", value: "Search", comment: "Search placeholder")
        static let confirm = NSLocalizedString("app.confirm", value: "Confirm", comment: "Confirm button")
        static let close = NSLocalizedString("app.close", value: "Close", comment: "Close button")
        static let loading = NSLocalizedString("app.loading", value: "Loading...", comment: "Loading text")
        static let remove = NSLocalizedString("app.remove", value: "Remove", comment: "Remove button")
    }

    // MARK: - Navigation
    enum Navigation {
        static let styleSettings = NSLocalizedString("nav.styleSettings", value: "Style Settings", comment: "Style settings title")
        static let templates = NSLocalizedString("nav.templates", value: "Templates", comment: "Templates title")
        static let history = NSLocalizedString("nav.history", value: "History", comment: "History title")
        static let subscription = NSLocalizedString("nav.subscription", value: "Premium", comment: "Subscription title")
    }

    // MARK: - Content
    enum Content {
        static let bannerContent = NSLocalizedString("content.bannerContent", value: "Banner Content", comment: "Banner content label")
        static let content = NSLocalizedString("content.content", value: "Content", comment: "Content label")
        static let inputPlaceholder = NSLocalizedString("content.inputPlaceholder", value: "Enter text to display...\nEmoji supported 😊", comment: "Input placeholder")
        static let preview = NSLocalizedString("content.preview", value: "Preview", comment: "Preview label")
        static let previewText = NSLocalizedString("content.previewText", value: "Preview Text", comment: "Preview placeholder text")
        static let showBanner = NSLocalizedString("content.showBanner", value: "Start Display", comment: "Show banner button")
        static let characterCount = NSLocalizedString("content.characterCount", value: "%d/100", comment: "Character count format")
    }

    // MARK: - Quick Settings
    enum QuickSettings {
        static let title = NSLocalizedString("quick.title", value: "Quick Settings", comment: "Quick settings title")
        static let colorTheme = NSLocalizedString("quick.colorTheme", value: "Color Theme", comment: "Color theme label")
        static let color = NSLocalizedString("quick.color", value: "Color", comment: "Color label")
        static let animationEffect = NSLocalizedString("quick.animationEffect", value: "Animation Effect", comment: "Animation effect label")
        static let animation = NSLocalizedString("quick.animation", value: "Animation", comment: "Animation label")
    }

    // MARK: - Color Themes
    enum ColorTheme {
        static let classic = NSLocalizedString("theme.classic", value: "Classic", comment: "Classic theme")
        static let support = NSLocalizedString("theme.support", value: "Support", comment: "Support theme")
        static let birthday = NSLocalizedString("theme.birthday", value: "Birthday", comment: "Birthday theme")
        static let pickup = NSLocalizedString("theme.pickup", value: "Pickup", comment: "Pickup theme")
        static let driver = NSLocalizedString("theme.driver", value: "Driver", comment: "Driver theme")
        static let thanks = NSLocalizedString("theme.thanks", value: "Thanks", comment: "Thanks theme")
    }

    // MARK: - Animation Types
    enum Animation {
        static let none = NSLocalizedString("animation.none", value: "None", comment: "No animation")
        static let scroll = NSLocalizedString("animation.scroll", value: "Scroll", comment: "Scroll animation")
        static let blink = NSLocalizedString("animation.blink", value: "Blink", comment: "Blink animation")
        static let gradient = NSLocalizedString("animation.gradient", value: "Gradient", comment: "Gradient animation")
        static let breathing = NSLocalizedString("animation.breathing", value: "Breathing", comment: "Breathing animation")
        static let typewriter = NSLocalizedString("animation.typewriter", value: "Typewriter", comment: "Typewriter animation")
        static let randomFlash = NSLocalizedString("animation.randomFlash", value: "Random Flash", comment: "Random flash animation")
        static let wave = NSLocalizedString("animation.wave", value: "Wave", comment: "Wave animation")
        static let bounce = NSLocalizedString("animation.bounce", value: "Bounce", comment: "Bounce animation")
        static let particles = NSLocalizedString("animation.particles", value: "Particles", comment: "Particles animation")
        static let led = NSLocalizedString("animation.led", value: "LED Pixel", comment: "LED pixel animation")

        // Animation descriptions
        static let noneDesc = NSLocalizedString("animation.noneDesc", value: "Static display, no animation", comment: "None animation description")
        static let scrollDesc = NSLocalizedString("animation.scrollDesc", value: "Text scrolls across screen", comment: "Scroll animation description")
        static let blinkDesc = NSLocalizedString("animation.blinkDesc", value: "Blinking light effect", comment: "Blink animation description")
        static let gradientDesc = NSLocalizedString("animation.gradientDesc", value: "Rainbow gradient background", comment: "Gradient animation description")
        static let breathingDesc = NSLocalizedString("animation.breathingDesc", value: "Breathing light effect", comment: "Breathing animation description")
        static let typewriterDesc = NSLocalizedString("animation.typewriterDesc", value: "Typewriter character effect", comment: "Typewriter animation description")
        static let randomFlashDesc = NSLocalizedString("animation.randomFlashDesc", value: "Random flash effect", comment: "Random flash animation description")
        static let waveDesc = NSLocalizedString("animation.waveDesc", value: "Wave motion effect", comment: "Wave animation description")
        static let bounceDesc = NSLocalizedString("animation.bounceDesc", value: "Bouncing spring effect", comment: "Bounce animation description")
        static let particlesDesc = NSLocalizedString("animation.particlesDesc", value: "Floating particle effects", comment: "Particles animation description")
        static let ledDesc = NSLocalizedString("animation.ledDesc", value: "LED dot matrix display", comment: "LED animation description")
    }

    // MARK: - Scroll Direction
    enum ScrollDirection {
        static let leftToRight = NSLocalizedString("scrollDirection.leftToRight", value: "Left to Right", comment: "Scroll left to right")
        static let rightToLeft = NSLocalizedString("scrollDirection.rightToLeft", value: "Right to Left", comment: "Scroll right to left")
        static let topToBottom = NSLocalizedString("scrollDirection.topToBottom", value: "Top to Bottom", comment: "Scroll top to bottom")
        static let bottomToTop = NSLocalizedString("scrollDirection.bottomToTop", value: "Bottom to Top", comment: "Scroll bottom to top")
        static let label = NSLocalizedString("scrollDirection.label", value: "Scroll Direction", comment: "Scroll direction label")
    }

    // MARK: - Style Settings
    enum StyleSettings {
        static let textSettings = NSLocalizedString("style.textSettings", value: "Text Settings", comment: "Text settings section")
        static let fontSize = NSLocalizedString("style.fontSize", value: "Font Size", comment: "Font size label")
        static let bold = NSLocalizedString("style.bold", value: "Bold", comment: "Bold toggle")
        static let fontStyle = NSLocalizedString("style.fontStyle", value: "Font Style", comment: "Font style label")
        static let colorSettings = NSLocalizedString("style.colorSettings", value: "Color Settings", comment: "Color settings section")
        static let textColor = NSLocalizedString("style.textColor", value: "Text Color", comment: "Text color label")
        static let backgroundColor = NSLocalizedString("style.backgroundColor", value: "Background Color", comment: "Background color label")
        static let backgroundSettings = NSLocalizedString("style.backgroundSettings", value: "Background Settings", comment: "Background settings section")
        static let backgroundType = NSLocalizedString("style.backgroundType", value: "Background Type", comment: "Background type label")
        static let colorBackground = NSLocalizedString("style.colorBackground", value: "Color", comment: "Color background type")
        static let imageBackground = NSLocalizedString("style.imageBackground", value: "Image", comment: "Image background type")
        static let backgroundImage = NSLocalizedString("style.backgroundImage", value: "Background Image", comment: "Background image label")
        static let selectImage = NSLocalizedString("style.selectImage", value: "Tap to select background image", comment: "Select image hint")
        static let selectBackgroundImage = NSLocalizedString("style.selectBackgroundImage", value: "Select Background Image", comment: "Select background image title")
        static let selectFromAlbum = NSLocalizedString("style.selectFromAlbum", value: "Select from Album", comment: "Select from album")
        static let selectFromFile = NSLocalizedString("style.selectFromFile", value: "Select from File", comment: "Select from file")
        static let removeBackgroundImage = NSLocalizedString("style.removeBackgroundImage", value: "Remove Background Image", comment: "Remove background image")
        static let selectedImage = NSLocalizedString("style.selectedImage", value: "Selected: %@", comment: "Selected image format")
        static let supportedFormats = NSLocalizedString("style.supportedFormats", value: "JPG, PNG supported", comment: "Supported formats")
        static let removeImage = NSLocalizedString("style.removeImage", value: "Remove", comment: "Remove image button")
        static let imageOpacity = NSLocalizedString("style.imageOpacity", value: "Image Opacity", comment: "Image opacity label")
        static let animationSettings = NSLocalizedString("style.animationSettings", value: "Animation Effects", comment: "Animation settings section")
        static let animationType = NSLocalizedString("style.animationType", value: "Animation Type", comment: "Animation type label")
        static let animationSpeed = NSLocalizedString("style.animationSpeed", value: "Animation Speed", comment: "Animation speed label")
        static let speedSlow = NSLocalizedString("style.speedSlow", value: "Slow", comment: "Slow speed label")
        static let speedFast = NSLocalizedString("style.speedFast", value: "Fast", comment: "Fast speed label")
        static let presetStyles = NSLocalizedString("style.presetStyles", value: "Quick Styles", comment: "Preset styles section")
        static let textSettingsTitle = NSLocalizedString("style.textSettingsTitle", value: "Text Color", comment: "Text color picker title")
        static let bgColorTitle = NSLocalizedString("style.bgColorTitle", value: "Background Color", comment: "Background color picker title")
        static let selectColor = NSLocalizedString("style.selectColor", value: "Select Color", comment: "Color picker title")

        // Animation Config
        static let breathingConfig = NSLocalizedString("style.breathingConfig", value: "Breathing Config", comment: "Breathing animation config")
        static let waveConfig = NSLocalizedString("style.waveConfig", value: "Wave Config", comment: "Wave animation config")
        static let bounceConfig = NSLocalizedString("style.bounceConfig", value: "Bounce Config", comment: "Bounce animation config")
        static let ledConfig = NSLocalizedString("style.ledConfig", value: "LED Config", comment: "LED animation config")

        // Artistic & Neon Style
        static let artisticStyle = NSLocalizedString("style.artisticStyle", value: "Artistic Style", comment: "Artistic style section")
        static let neonStyle = NSLocalizedString("style.neonStyle", value: "Neon Style", comment: "Neon style section")
        static let customConfig = NSLocalizedString("style.customConfig", value: "Custom Config", comment: "Custom config section")
        static let animationConfig = NSLocalizedString("style.animationConfig", value: "Animation Config", comment: "Animation config section")
        static let blinkConfig = NSLocalizedString("style.blinkConfig", value: "Blink Config", comment: "Blink animation config")

        // Animation Parameters
        static let minScale = NSLocalizedString("style.minScale", value: "Min Scale", comment: "Minimum scale")
        static let amplitude = NSLocalizedString("style.amplitude", value: "Amplitude", comment: "Wave amplitude")
        static let bounceHeight = NSLocalizedString("style.bounceHeight", value: "Bounce Height", comment: "Bounce height")
        static let ledSize = NSLocalizedString("style.ledSize", value: "LED Size", comment: "LED dot size")

        // Additional
        static let selectStyle = NSLocalizedString("style.selectStyle", value: "Select Style", comment: "Select style")
        static let glowColor = NSLocalizedString("style.glowColor", value: "Glow Color", comment: "Glow color")
        static let minOpacity = NSLocalizedString("style.minOpacity", value: "Min Opacity", comment: "Minimum opacity")
        static let maxScale = NSLocalizedString("style.maxScale", value: "Max Scale", comment: "Maximum scale")
        static let frequency = NSLocalizedString("style.frequency", value: "Frequency", comment: "Frequency")
        static let glowIntensity = NSLocalizedString("style.glowIntensity", value: "Glow Intensity", comment: "Glow intensity")
        static let glowRadius = NSLocalizedString("style.glowRadius", value: "Glow Radius", comment: "Glow radius")
        static let elasticity = NSLocalizedString("style.elasticity", value: "Elasticity", comment: "Elasticity")
        static let ledSpacing = NSLocalizedString("style.ledSpacing", value: "LED Spacing", comment: "LED spacing")
        static let ledGlowIntensity = NSLocalizedString("style.ledGlowIntensity", value: "LED Glow", comment: "LED glow intensity")

        // Artistic Config
        static let strokeWidth = NSLocalizedString("style.strokeWidth", value: "Stroke Width", comment: "Stroke width")
        static let strokeColor = NSLocalizedString("style.strokeColor", value: "Stroke Color", comment: "Stroke color")
        static let shadowRadius = NSLocalizedString("style.shadowRadius", value: "Shadow Radius", comment: "Shadow radius")
        static let shadowOpacity = NSLocalizedString("style.shadowOpacity", value: "Shadow Opacity", comment: "Shadow opacity")
        static let materialIntensity = NSLocalizedString("style.materialIntensity", value: "Material Intensity", comment: "Material intensity")
        static let atmosphereIntensity = NSLocalizedString("style.atmosphereIntensity", value: "Atmosphere Intensity", comment: "Atmosphere intensity")

        // Neon Config
        static let glitchIntensity = NSLocalizedString("style.glitchIntensity", value: "Glitch Intensity", comment: "Glitch intensity")
        static let gradientEndColor = NSLocalizedString("style.gradientEndColor", value: "Gradient End Color", comment: "Gradient end color")
        static let enableMultipleLayers = NSLocalizedString("style.enableMultipleLayers", value: "Enable Multiple Layers", comment: "Enable multiple layers")
        static let secondaryGlowColor = NSLocalizedString("style.secondaryGlowColor", value: "Secondary Glow Color", comment: "Secondary glow color")
        static let secondaryGlowRadius = NSLocalizedString("style.secondaryGlowRadius", value: "Secondary Glow Radius", comment: "Secondary glow radius")
    }

    // MARK: - Font Styles
    enum FontStyle {
        static let normal = NSLocalizedString("fontStyle.normal", value: "Normal", comment: "Normal font style")
        static let artistic = NSLocalizedString("fontStyle.artistic", value: "Artistic", comment: "Artistic font style")
        static let neon = NSLocalizedString("fontStyle.neon", value: "Neon", comment: "Neon font style")
        static let normalDesc = NSLocalizedString("fontStyle.normalDesc", value: "Standard font display", comment: "Normal font description")
        static let artisticDesc = NSLocalizedString("fontStyle.artisticDesc", value: "Artistic decorative style", comment: "Artistic font description")
        static let neonDesc = NSLocalizedString("fontStyle.neonDesc", value: "Neon glowing effect", comment: "Neon font description")
    }

    // MARK: - Preset Styles
    enum PresetStyle {
        static let concert = NSLocalizedString("preset.concert", value: "Concert", comment: "Concert preset")
        static let birthday = NSLocalizedString("preset.birthday", value: "Birthday Party", comment: "Birthday preset")
        static let pickup = NSLocalizedString("preset.pickup", value: "Pickup Sign", comment: "Pickup preset")
        static let driver = NSLocalizedString("preset.driver", value: "Driver Service", comment: "Driver preset")
        static let thanks = NSLocalizedString("preset.thanks", value: "Thanks", comment: "Thanks preset")
        static let wait = NSLocalizedString("preset.wait", value: "Please Wait", comment: "Wait preset")
    }

    // MARK: - Template Categories
    enum TemplateCategory {
        static let all = NSLocalizedString("templateCategory.all", value: "All", comment: "All templates")
        static let support = NSLocalizedString("templateCategory.support", value: "Support", comment: "Support category")
        static let party = NSLocalizedString("templateCategory.party", value: "Party", comment: "Party category")
        static let transport = NSLocalizedString("templateCategory.transport", value: "Transport", comment: "Transport category")
        static let celebration = NSLocalizedString("templateCategory.celebration", value: "Celebration", comment: "Celebration category")
        static let communication = NSLocalizedString("templateCategory.communication", value: "Communication", comment: "Communication category")
        static let custom = NSLocalizedString("templateCategory.custom", value: "Custom", comment: "Custom category")
    }

    // MARK: - Templates
    enum Template {
        static let title = NSLocalizedString("template.title", value: "Templates", comment: "Templates title")
        static let builtIn = NSLocalizedString("template.builtIn", value: "Built-in Templates", comment: "Built-in templates section")
        static let custom = NSLocalizedString("template.custom", value: "My Templates", comment: "Custom templates section")
        static let favorites = NSLocalizedString("template.favorites", value: "Favorites", comment: "Favorites section")
        static let addTemplate = NSLocalizedString("template.add", value: "Add Template", comment: "Add template button")
        static let useTemplate = NSLocalizedString("template.use", value: "Use", comment: "Use template button")
        static let templateName = NSLocalizedString("template.name", value: "Template Name", comment: "Template name placeholder")
        static let concertSupport = NSLocalizedString("template.concertSupport", value: "❤️ I Love You ❤️", comment: "Concert support template")
        static let fanSupport = NSLocalizedString("template.fanSupport", value: "🌟 Go Go! 🌟", comment: "Fan support template")
        static let happyBirthday = NSLocalizedString("template.happyBirthday", value: "🎂 Happy Birthday 🎂", comment: "Birthday template")
        static let partyTime = NSLocalizedString("template.partyTime", value: "🎉 Party Time 🎉", comment: "Party template")
        static let airportPickup = NSLocalizedString("template.airportPickup", value: "✈️ Airport Pickup ✈️", comment: "Airport pickup template")
        static let driverService = NSLocalizedString("template.driverService", value: "🚗 Driver Service 🚗", comment: "Driver service template")
        static let thankYou = NSLocalizedString("template.thankYou", value: "🙏 Thank You 🙏", comment: "Thank you template")
        static let pleaseWait = NSLocalizedString("template.pleaseWait", value: "⏰ Please Wait ⏰", comment: "Please wait template")
    }

    // MARK: - History
    enum History {
        static let title = NSLocalizedString("history.title", value: "History", comment: "History title")
        static let empty = NSLocalizedString("history.empty", value: "No history yet", comment: "Empty history message")
        static let emptyHint = NSLocalizedString("history.emptyHint", value: "Records will appear here after using the banner display feature", comment: "Empty history hint")
        static let clearAll = NSLocalizedString("history.clearAll", value: "Clear All", comment: "Clear all history")
        static let confirmClear = NSLocalizedString("history.confirmClear", value: "Clear all history?", comment: "Confirm clear title")
        static let confirmClearMessage = NSLocalizedString("history.confirmClearMessage", value: "This action cannot be undone.", comment: "Confirm clear message")
        static let records = NSLocalizedString("history.records", value: "%d records", comment: "Records count")
    }

    // MARK: - Quick Access
    enum QuickAccess {
        static let history = NSLocalizedString("quickAccess.history", value: "History", comment: "History quick access")
        static let templates = NSLocalizedString("quickAccess.templates", value: "Templates", comment: "Templates quick access")
    }

    // MARK: - Subscription
    enum Subscription {
        static let premium = NSLocalizedString("subscription.premium", value: "Premium Version", comment: "Premium title")
        static let lifetime = NSLocalizedString("subscription.lifetime", value: "Lifetime Unlock", comment: "Lifetime subscription")
        static let lifetimeDesc = NSLocalizedString("subscription.lifetimeDesc", value: "One-time purchase, lifetime use", comment: "Lifetime description")
        static let lifetimeDescFull = NSLocalizedString("subscription.lifetimeDescFull", value: "One-time purchase, enjoy unlimited banner display experience for life", comment: "Full lifetime description")
        static let lifetimeGuarantee = NSLocalizedString("subscription.lifetimeGuarantee", value: "One-time purchase, lifetime use, no need to worry about renewals", comment: "Lifetime guarantee")
        static let restore = NSLocalizedString("subscription.restore", value: "Restore Purchase", comment: "Restore purchase button")
        static let features = NSLocalizedString("subscription.features", value: "Premium Features", comment: "Premium features title")
        static let unlockAll = NSLocalizedString("subscription.unlockAll", value: "Unlock All Premium Features", comment: "Unlock all features")
        static let selectPlan = NSLocalizedString("subscription.selectPlan", value: "Select a Plan", comment: "Select plan title")
        static let recommended = NSLocalizedString("subscription.recommended", value: "Recommended", comment: "Recommended badge")
        static let oneTime = NSLocalizedString("subscription.oneTime", value: "One-time", comment: "One-time payment")
        static let termsOfUse = NSLocalizedString("subscription.termsOfUse", value: "Terms of Use", comment: "Terms of use")
        static let privacyPolicy = NSLocalizedString("subscription.privacyPolicy", value: "Privacy Policy", comment: "Privacy policy")
    }

    // MARK: - Premium Features
    enum PremiumFeature {
        static let premiumFeature = NSLocalizedString("premium.premiumFeature", value: "Premium Feature", comment: "Premium feature title")
        static let unlimitedPreview = NSLocalizedString("premium.unlimitedPreview", value: "Unlimited Preview", comment: "Unlimited preview feature")
        static let unlimitedPreviewDesc = NSLocalizedString("premium.unlimitedPreviewDesc", value: "Enjoy unlimited fullscreen display time", comment: "Unlimited preview description")
        static let advancedAnimations = NSLocalizedString("premium.advancedAnimations", value: "Advanced Animations", comment: "Advanced animations feature")
        static let customFonts = NSLocalizedString("premium.customFonts", value: "Custom Fonts", comment: "Custom fonts feature")
        static let backgroundImages = NSLocalizedString("premium.backgroundImages", value: "Background Images", comment: "Background images feature")
        static let backgroundImagesDesc = NSLocalizedString("premium.backgroundImagesDesc", value: "Use custom images as banner background", comment: "Background images description")
        static let exportFeatures = NSLocalizedString("premium.exportFeatures", value: "Export Features", comment: "Export features")
        static let prioritySupport = NSLocalizedString("premium.prioritySupport", value: "Priority Support", comment: "Priority support feature")
        static let upgrade = NSLocalizedString("premium.upgrade", value: "Upgrade Now", comment: "Upgrade button")
        static let later = NSLocalizedString("premium.later", value: "Maybe Later", comment: "Later button")
        static let freeTrialLimit = NSLocalizedString("premium.freeTrialLimit", value: "Free users can display for 30 seconds", comment: "Free trial limit message")
    }

    // MARK: - Quick Actions
    enum QuickAction {
        static let styleSettings = NSLocalizedString("quickAction.styleSettings", value: "Style Settings", comment: "Style settings action")
        static let selectTemplate = NSLocalizedString("quickAction.selectTemplate", value: "Select Template", comment: "Select template action")
    }

    // MARK: - Info
    enum Info {
        static let developer = NSLocalizedString("info.developer", value: "Thank_L Team", comment: "Developer name")
        static let version = NSLocalizedString("info.version", value: "Version", comment: "Version label")
    }
}
