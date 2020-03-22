# ASE

![platforms](https://img.shields.io/badge/platforms-macOS-333333.svg)
[![Language: Swift 5.0](https://img.shields.io/badge/swift-5.0-4BC51D.svg?style=flat)](https://developer.apple.com/swift)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

`ASE` package load ase file a.k.a. "Adobe Swatch Exchange" as NSColorList.

## Usage

```swift
import ASE

do {
    let ase = try ASE(from: url)
    
    // Access color by name
    let red = ase["Red 50"]
    
    // Get NSColorList
    let colorList = ase.colorList
    
    // Save as NSColorList.
    try ase.writeAsColorList(to: URL(string: "Somewhere"))
} catch {
    fatalError("Failed to load")
}

```

## Acknowledgments

- https://github.com/hughsk/adobe-swatch-exchange
- https://github.com/m99coder/ase2json
- https://github.com/ramonpoca/ColorTools
- https://gist.github.com/codelynx/932150fd13f0317df264
