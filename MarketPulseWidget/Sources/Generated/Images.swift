// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
internal typealias ImagesType = ImageAsset

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Images {
  internal static let logoBitcoin48 = ImageAsset(name: "logoBitcoin48")
  internal static let logoBitcoincash48 = ImageAsset(name: "logoBitcoincash48")
  internal static let logoDash48 = ImageAsset(name: "logoDash48")
  internal static let logoEthereum48 = ImageAsset(name: "logoEthereum48")
  internal static let logoEuro48 = ImageAsset(name: "logoEuro48")
  internal static let logoLira48 = ImageAsset(name: "logoLira48")
  internal static let logoLtc48 = ImageAsset(name: "logoLtc48")
  internal static let logoMonero48 = ImageAsset(name: "logoMonero48")
  internal static let logoUsd48 = ImageAsset(name: "logoUsd48")
  internal static let logoWaves48 = ImageAsset(name: "logoWaves48")
  internal static let logoWct48 = ImageAsset(name: "logoWct48")
  internal static let logoZec48 = ImageAsset(name: "logoZec48")
  internal static let scriptasset18White = ImageAsset(name: "scriptasset18White")
  internal static let setting14Classic = ImageAsset(name: "setting14Classic")
  internal static let sponsoritem18White = ImageAsset(name: "sponsoritem18White")
  internal static let update14Classic = ImageAsset(name: "update14Classic")

  // swiftlint:disable trailing_comma
  internal static let allColors: [ColorAsset] = [
  ]
  internal static let allImages: [ImageAsset] = [
    logoBitcoin48,
    logoBitcoincash48,
    logoDash48,
    logoEthereum48,
    logoEuro48,
    logoLira48,
    logoLtc48,
    logoMonero48,
    logoUsd48,
    logoWaves48,
    logoWct48,
    logoZec48,
    scriptasset18White,
    setting14Classic,
    sponsoritem18White,
    update14Classic,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  internal static let allValues: [ImagesType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

internal extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
