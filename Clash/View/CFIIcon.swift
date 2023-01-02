import SwiftUI

public struct CFIIcon: View {

    public let systemName: String
    public let backgroundColor: Color

    public var body: some View {
        ZStack {
            Image(systemName: "app.fill")
                .font(.system(size: CGFloat(32)))
                .foregroundColor(backgroundColor)
            Image(systemName: systemName)
                .font(.system(size: CGFloat(16)))
                .foregroundColor(.white)
        }
    }
}
