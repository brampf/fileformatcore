<p align="center">
<img src = "Doc/FileFormatBanner@0.5x.png" alt="FileFormatCore">
</p>

<p align="center">
<a href="LICENSE.md">
<img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
</a>
<a href="https://swift.org">
<img src="https://img.shields.io/badge/swift-5.3-brightgreen.svg" alt="Swift 5.3">
</a>
<img src="https://img.shields.io/github/languages/top/brampf/csvcore?color=bright" alt="Language">
<img src="https://img.shields.io/github/workflow/status/brampf/csvcore/Swift" alt="Swift">
</p>

A native Swift library to read and write custom file formats

## Description
FileFormatCore is asupport library to implement reading and writing custom file formats in pure swift

FileFormatCore consists of two modules
* [FileReader](Doc/FileReader.md) : Read files from disk to memory
* [FileWriter](Doc/FileWriter.md) : Write files from memory to disk

### References
The following projects are based on this project:

| ![CSVCore](Doc/CsvCore@0.5x.png "CSVCore") |
| :----------: |
| *[CSVCore](https://github.com/brampf/csvcore)* |

| ![ISOBMFFCore](Doc/ISOBMFFCore@0.5x.png "ISOBMFFCore") | ![HEIFCore](Doc/HEIFCore@0.5x.png "HEIFCore") |
| :----------: | :----------: |
| *[ISOBMFFCore](https://github.com/brampf/ISOBMFFCore)* | *[HEIFCore](https://github.com/brampf/HEIFCore)* | 

Planned
| ![FitsCore](Doc/FitsCore@0.5x.png "FITSCore") |
| :----------: |
| *[FITSCore](https://github.com/brampf/fitscore)* |


## Getting started

### Package Manager

With the swift package manager, add the library to your dependencies
```swift
dependencies: [
.package(url: "https://github.com/brampf/fileformatcore.git", from: "0.0.3")
]
```

then simply add the `FileReader`  import to your target for the parser

```swift
.target(name: "YourApp", dependencies: ["FileReader"])
```


## License

MIT license; see [LICENSE](LICENSE.md).
(c) 2021
