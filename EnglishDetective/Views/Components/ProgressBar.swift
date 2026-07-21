import SwiftUI

// MARK: - Progress Bar Component

struct ProgressBar: View {
    let progress: Double  // 0.0 ... 1.0
    var color: Color = DetectiveColors.success
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(DetectiveColors.border)
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(
                        width: max(0, min(geometry.size.width, geometry.size.width * progress)),
                        height: height
                    )
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ProgressBar(progress: 0.8, color: DetectiveColors.success)
            .frame(width: 200)
        ProgressBar(progress: 0.5, color: DetectiveColors.accent)
            .frame(width: 200)
        ProgressBar(progress: 0.2, color: DetectiveColors.danger)
            .frame(width: 200)
    }
    .padding()
    .background(DetectiveColors.warmBackground)
}
