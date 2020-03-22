//
//  ASE.swift
//  ASE
//
//  Created by griffin-stewie on 2020/03/22.
//

import CoreFoundation
import Foundation
import Cocoa

// https://github.com/hughsk/adobe-swatch-exchange
// https://github.com/m99coder/ase2json
// https://github.com/ramonpoca/ColorTools

// MARK: - Public

public struct ASE {

    public let colorList: NSColorList

    public init(from url: URL) throws {
        guard let c = Self.parse(url: url) else {
            throw NSError(domain: "ASE", code: 0, userInfo: nil)
        }

        self.colorList = c
    }

    public subscript(name: String) -> NSColor? {
        get {
            return colorList.color(withKey: name)
        }
        set(color) {
            if let c = color {
                colorList.setColor(c, forKey: name)
            } else {
                colorList.removeColor(withKey: name)
            }
        }
    }

    public func writeAsColorList(to url: URL?) throws {
        try self.colorList.write(to: url)
    }
}

// MARK: - Internal

extension ASE {

    enum ColorModel: String {
        case cmyk = "CMYK"
        case rgb = "RGB " // DO NOT drop trailing space
        case lab = "LAB " // DO NOT drop trailing space
        case gray = "Gray"
    }

    static func parse(url: URL) -> NSColorList? {
        return parse(path: url.path)
    }

    static func parse(path: String) -> NSColorList? {

        let SIGNATURE = "ASEF"

        let colorList = NSColorList(name: "x")

        guard let ASEFileHandle = FileHandle(forReadingAtPath:path) else  {
            return nil
        }

        let header = ASEFileHandle.readData(ofLength: 4)

        if header != Data(SIGNATURE.utf8) {
            NSLog("%s %@", #function, "this file is not ASE");
            return nil
        }

        let majVData: Data = ASEFileHandle.readData(ofLength: 2)
        let minVData: Data = ASEFileHandle.readData(ofLength: 2)
        let nblocksData: Data = ASEFileHandle.readData(ofLength: 4)

        _ = minVData.readUInt16BE(minVData.count)
        _ = majVData.readUInt16BE(majVData.count)
        let nBlocks:UInt32 = nblocksData.readUInt32BE(nblocksData.count)

        //NSLog("Version %d.%d, blocks %d", majV, minV, nBlocks);

        for _ in 0..<nBlocks {
            self.readBlock(ASEFileHandle, to: colorList)
        }


        return colorList
    }

    static func readBlock(_ fileHandle :FileHandle, to colorList: NSColorList) {
        let blockTypeColorEntry: UInt16 = 0x0001

        let blockType: UInt16 = fileHandle.readUInt16()!
        let blockLength: UInt32 = fileHandle.readUInt32()!

        switch blockType {
        case blockTypeColorEntry:
            let nameLength: UInt16 = fileHandle.readUInt16()!
            let nameData: Data = fileHandle.readData(ofLength: Int(nameLength * 2))
            var name = String(data: nameData, encoding: String.Encoding.utf16)
            let colorModelData: Data = fileHandle.readData(ofLength: 4)
            if let colorModel = String(data: colorModelData, encoding: .ascii) {
                let color = colorFromModel(colorModel, fileHandle: fileHandle)
                _ = fileHandle.readUInt16()

                if name == nil || name == "\0" {
                    let convertedColor = color.usingColorSpace(NSColorSpace.sRGB)!;

                    let hexString = String(format: "#%02X%02X%02X"
                        , Int(convertedColor.redComponent * 0xFF)
                        , Int(convertedColor.greenComponent * 0xFF)
                        , Int(convertedColor.blueComponent * 0xFF));
                    name = hexString
                } else {
                    var set = CharacterSet.controlCharacters
                    set.formUnion(CharacterSet.whitespacesAndNewlines)
                    name = name?.trimmingCharacters(in: set)
                }

                colorList.setColor(color, forKey: name!)
            }

        default:
            fileHandle.readData(ofLength: Int(blockLength))
        }
    }

    static func colorFromModel(_ colorModel: String, fileHandle: FileHandle) -> NSColor {
        guard let model = ColorModel(rawValue: colorModel) else {
            fatalError("Unkonw Color Model")
        }

        switch model {
        case .rgb:
            let red :CGFloat = CGFloat(fileHandle.readFloat()!)
            let green :CGFloat = CGFloat(fileHandle.readFloat()!)
            let blue :CGFloat = CGFloat(fileHandle.readFloat()!)
            let color = NSColor(srgbRed: red, green: green, blue: blue, alpha: 1.0)
            return color
        case .cmyk:
            let cyan :CGFloat = CGFloat(fileHandle.readFloat()!)
            let magenta :CGFloat = CGFloat(fileHandle.readFloat()!)
            let yellow :CGFloat = CGFloat(fileHandle.readFloat()!)
            let black :CGFloat = CGFloat(fileHandle.readFloat()!)
            let color = NSColor(deviceCyan: cyan, magenta: magenta, yellow: yellow, black: black, alpha: 1.0).usingColorSpace(NSColorSpace.sRGB)!
            return color
        case .lab:
            fatalError("Unsupport Color Model")
        case .gray:
            let white :CGFloat = CGFloat(fileHandle.readFloat()!)
            let color = NSColor(white: white, alpha: 1.0).usingColorSpace(NSColorSpace.sRGB)!
            return color
        }
    }
}

// MARK: - Helper Extension

private extension Data {

    func readUInt32BE(_ position : Int) -> UInt32 {
        var blocks : UInt32 = 0
        (self as NSData).getBytes(&blocks, length: position)
        return NSSwapBigIntToHost(blocks)
    }

    func readUInt16BE(_ position : Int) -> UInt16 {
        var blocks : UInt16 = 0
        (self as NSData).getBytes(&blocks, length: position)
        return NSSwapBigShortToHost(blocks)
    }

    func readUInt32LE(_ position : Int) -> UInt32 {
        var blocks : UInt32 = 0
        (self as NSData).getBytes(&blocks, length: position)
        return NSSwapLittleIntToHost(blocks)
    }

    func readUInt8(_ position : Int) -> UInt8 {
        var blocks : UInt8 = 0
        (self as NSData).getBytes(&blocks, length: position)
        return blocks
    }
}
