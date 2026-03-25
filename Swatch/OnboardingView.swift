import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    
    private let totalSteps = 3
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Step indicator
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step == currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Content based on step
            Group {
                switch currentStep {
                case 0:
                    welcomeStep
                case 1:
                    pickColorStep
                case 2:
                    createPaletteStep
                default:
                    welcomeStep
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            
            Spacer()
            
            // Buttons
            HStack {
                Button("Skip") {
                    completeOnboarding()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                
                Spacer()
                
                if currentStep < totalSteps - 1 {
                    Button("Continue") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 360, height: 420)
        .background(Color(nsColor: Theme.backgroundColor))
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "#FF6B6B"), Color(hex: "#4ECDC4"), Color(hex: "#45B7D1")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Welcome to Swatch")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Your color companion in the menu bar. Pick, palette, and export colors with ease.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }
    
    private var pickColorStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "eye.dropper")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("Pick a Color")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text("Click the menu bar icon")
                        .font(.system(size: 13))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text("Press Cmd+Shift+C anywhere")
                        .font(.system(size: 13))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text("Copy colors in any format")
                        .font(.system(size: 13))
                }
            }
            .padding(.horizontal, 24)
            
            // Mini demo
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "#FF6B6B"))
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading) {
                    Text("#FF6B6B")
                        .font(.system(size: 12, design: .monospaced))
                        .fontWeight(.medium)
                    Text("rgb(255, 107, 107)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color(nsColor: Theme.surfaceColor))
            .cornerRadius(8)
        }
    }
    
    private var createPaletteStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("Create a Palette")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Save colors you love into palettes. Export them anywhere — CSS, Swift, or JSON.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            // Palette preview
            VStack(alignment: .leading, spacing: 8) {
                Text("My Palette")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    ForEach(["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7"], id: \.self) { hex in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: hex))
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .padding(16)
            .background(Color(nsColor: Theme.surfaceColor))
            .cornerRadius(12)
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        isPresented = false
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
