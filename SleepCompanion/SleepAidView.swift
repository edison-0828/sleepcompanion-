import SwiftUI

struct SleepAidView: View {
    var body: some View {
        TonightView()
    }
}

#Preview {
    SleepAidView()
        .environmentObject(AudioManager())
}
