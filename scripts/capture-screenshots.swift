#!/usr/bin/env swift
// Screenshot capture script for App Store
// Run from the project root: swift scripts/capture-screenshots.swift

import Foundation
import AppKit
import SwiftUI

// MARK: - Screenshot Captor

struct ScreenshotCaptor {
    enum ScreenshotType {
        case popover
        case palettes
        case contrast
        case eyedropper
        case gradient
    }
    
    static func capturePopover() {
        print("Capturing popover screenshot...")
        // In a real implementation, this would render the SwiftUI view to an image
        // For now, we create placeholder images
        savePlaceholder(filename: "screenshot-popover", size: CGSize(width: 2880, height: 2592))
    }
    
    static func capturePalettes() {
        print("Capturing palettes screenshot...")
        savePlaceholder(filename: "screenshot-palettes", size: CGSize(width: 2880, height: 2592))
    }
    
    static func captureContrast() {
        print("Capturing contrast screenshot...")
        savePlaceholder(filename: "screenshot-contrast", size: CGSize(width: 2880, height: 2592))
    }
    
    static func captureEyedropper() {
        print("Capturing eyedropper screenshot...")
        savePlaceholder(filename: "screenshot-eyedropper", size: CGSize(width: 2880, height: 2592))
    }
    
    static func captureGradient() {
        print("Capturing gradient screenshot...")
        savePlaceholder(filename: "screenshot-gradient", size: CGSize(width: 2880, height: 2592))
    }
    
    private static func savePlaceholder(filename: String, size: CGSize) {
        let color = NSColor(red: 0.97, green: 0.97, blue: 0.96, alpha: 1.0)
        let image = NSImage(size: size)
        image.lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        
        // Add filename text
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 120, weight: .semibold),
            .foregroundColor: NSColor.darkGray
        ]
        let text = "Swatch - \(filename)"
        let textSize = text.size(withAttributes: attrs)
        let textRect = NSRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attrs)
        
        image.unlockFocus()
        
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            print("Failed to create image for \(filename)")
            return
        }
        
        let path = "screenshots/\(filename).png"
        do {
            try pngData.write(to: URL(fileURLWithPath: path))
            print("Saved: \(path)")
        } catch {
            print("Error saving \(filename): \(error)")
        }
    }
    
    static func generateAllScreenshots() {
        // Create screenshots directory
        let fileManager = FileManager.default
        let screenshotsDir = "screenshots"
        
        if !fileManager.fileExists(atPath: screenshotsDir) {
            do {
                try fileManager.createDirectory(atPath: screenshotsDir, withIntermediateDirectories: true)
            } catch {
                print("Failed to create screenshots directory: \(error)")
                return
            }
        }
        
        // Generate screenshots at both sizes
        capturePopover()
        capturePalettes()
        captureContrast()
        captureEyedropper()
        captureGradient()
        
        print("\nScreenshot generation complete!")
        print("Note: These are placeholder images. Replace with actual app screenshots.")
    }
}

// MARK: - Main

ScreenshotCaptor.generateAllScreenshots()
