import SwiftUI
import TDLibKit

public extension Optional where Wrapped == ProfilePhoto {
    /// Returns a SwiftUI Image instance for this photo. If the ProfilePhoto is null, then
    /// it would use `firstName` and `lastName` strings to generate a placeholder.
    /// - Parameters:
    ///   - firstName: User's first name
    ///   - lastName: User's last name
    ///   - uID: User's ID
    /// - Returns: A generated Image
    func getImage(firstName: String, lastName: String, uID: Int64) -> Image {
        return Image(systemName: "xmark.circle")
    }
}
public extension Color {
    init(userId: Int64) {
        let colors: [Color] = [
            .red,
            .green,
            .blue,
            .purple,
            .pink,
            .blue,
            .orange
        ]
        let id = Int(String(userId).replacingOccurrences(of: "-100", with: "-"))!
        // colors[[0, 7, 4, 1, 6, 3, 5][id % 7]]

        self.init(nsColor: NSColor(colors[[0, 7, 4, 1, 6, 3, 5][id % 7]]))
    }
}
