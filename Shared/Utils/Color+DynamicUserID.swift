// Color+DynamicUserID.swift

import SwiftUI
import Backend

extension Color {
    init?(from userId: Int64) async throws {
        // Source:
        // https://www.hackingwithswift.com/example-code/media/
        // how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
        let user = try await TdApi.shared.getUser(userId: userId)

        guard let profilePhoto = user.profilePhoto else { return nil }
        guard let photo = profilePhoto.minithumbnail else { return nil }
        guard let inputImage = CIImage(data: photo.data) else { return nil }

        let extentVector = CIVector(
            x: inputImage.extent.origin.x,
            y: inputImage.extent.origin.y,
            z: inputImage.extent.size.width,
            w: inputImage.extent.size.height
        )

        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: inputImage,
                kCIInputExtentKey: extentVector
            ]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        self.init(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            opacity: 1
        )
    }

    // Source:
    // https://medium.com/trinity-mirror-digital/adjusting-uicolor-luminosity-in-swift-4168e3c4cdf1
    // swiftlint:disable function_body_length cyclomatic_complexity
    func withLuminosity(_ colorSchemeContrast: ColorSchemeContrast = .standard) -> Color {
        // TODO: calculate newLuminosity
        // depending on the foreground color of a message bubble
        // Color.contrastRatio() may help
        let newLuminosity: CGFloat
        switch colorSchemeContrast {
            case .standard:
                newLuminosity = 0.6
            case .increased:
                newLuminosity = 0.8
            @unknown default:
                newLuminosity = 0.6
        }
        
        let nsColor = NSColor(self)
        guard let coreColour = CIColor(color: nsColor) else { return self }
        var red = coreColour.red
        var green = coreColour.green
        var blue = coreColour.blue
        let alpha = coreColour.alpha

        red = red.clamp(min: 0, max: 1)
        green = green.clamp(min: 0, max: 1)
        blue = blue.clamp(min: 0, max: 1)

        guard let minRGB = [red, green, blue].min(),
            let maxRGB = [red, green, blue].max() else { return self }

        var luminosity = (minRGB + maxRGB) / 2

        var saturation: CGFloat = 0

        if luminosity <= 0.5 {
            saturation = (maxRGB - minRGB)/(maxRGB + minRGB)
        } else if luminosity > 0.5 {
            saturation = (maxRGB - minRGB)/(2.0 - maxRGB - minRGB)
        }

        var hue: CGFloat = 0
        if red == maxRGB {
            hue = (green - blue) / (maxRGB - minRGB)
        } else if green == maxRGB {
            hue = 2.0 + ((blue - red) / (maxRGB - minRGB))
        } else if blue == maxRGB {
            hue = 4.0 + ((red - green) / (maxRGB - minRGB))
        }

        if hue < 0 {
            hue += 360
        } else {
            hue *= 60
        }

        luminosity = newLuminosity

        if saturation == 0 {
            return Color(red: 1.0 * luminosity, green: 1.0 * luminosity, blue: 1.0 * luminosity, opacity: alpha)
        }

        var temporaryVariableOne: CGFloat = 0
        if luminosity < 0.5 {
            temporaryVariableOne = luminosity * (1 + saturation)
        } else {
            temporaryVariableOne = luminosity + saturation - luminosity * saturation
        }

        let temporaryVariableTwo = 2 * luminosity - temporaryVariableOne

        let convertedHue = hue / 360

        let tempRed = (convertedHue + 0.333).convertToColourChannel()
        let tempGreen = convertedHue.convertToColourChannel()
        let tempBlue = (convertedHue - 0.333).convertToColourChannel()

        let newRed = tempRed.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newGreen = tempGreen.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newBlue = tempBlue.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)

        return Color(red: newRed, green: newGreen, blue: newBlue, opacity: alpha)
    }
}
