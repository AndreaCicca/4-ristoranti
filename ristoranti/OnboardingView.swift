import SwiftUI

struct FeatureRow: View {
    let iconName: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: iconName)
                .font(.largeTitle)
                .foregroundColor(.cyan)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isAnimatingIcon = false
    
    // Configura questa variabile per mostrare le novità degli aggiornamenti in futuro (flessibile)
    let isShowingUpdates = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // Icona animata al centro
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.cyan)
                .rotationEffect(.degrees(isAnimatingIcon ? 360 : 0))
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: isAnimatingIcon)
                .onAppear {
                    isAnimatingIcon = true
                }
                .padding(.bottom, 20)
            
            Text(isShowingUpdates ? "Novità dell'Aggiornamento" : "Benvenuto in 4 Ristoranti")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 24) {
                if isShowingUpdates {
                    FeatureRow(iconName: "wand.and.stars", title: "Nuove Funzioni", description: "Abbiamo introdotto nuove funzioni e migliorato le prestazioni generali.")
                    FeatureRow(iconName: "list.bullet.rectangle.portrait", title: "Nuovi Episodi", description: "Tutti i ristoranti aggiornati all'ultima stagione.")
                } else {
                    FeatureRow(iconName: "map.fill", title: "Esplora la Mappa", description: "Trova tutti i ristoranti visitati da Alessandro Borghese direttamente sulla mappa.")
                    FeatureRow(iconName: "location.fill", title: "Vicino a Me", description: "Scopri i ristoranti del programma più vicini alla tua posizione attuale.")
                    FeatureRow(iconName: "sparkles", title: "Suggerimenti AI", description: "Ricevi consigli intelligenti per la tua serata, basati sui dati dell'app.")
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    hasSeenOnboarding = true
                }
            }) {
                Text(isShowingUpdates ? "Continua" : "Inizia a Esplorare")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.cyan)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding()
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 600)
        #endif
    }
}

#Preview {
    OnboardingView()
}
