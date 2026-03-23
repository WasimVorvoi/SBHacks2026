import UIKit

enum Theme {
    // Brand colors — matching website CSS variables
    static let bg = UIColor(red: 0.024, green: 0.024, blue: 0.047, alpha: 1.0)           // #06060c
    static let bgSubtle = UIColor(red: 0.047, green: 0.047, blue: 0.086, alpha: 1.0)      // #0c0c16
    static let card = UIColor(red: 0.067, green: 0.067, blue: 0.125, alpha: 1.0)           // #111120
    static let cardHover = UIColor(red: 0.086, green: 0.086, blue: 0.165, alpha: 1.0)      // #16162a
    static let border = UIColor(red: 0.118, green: 0.118, blue: 0.22, alpha: 1.0)          // #1e1e38
    static let borderGlow = UIColor(red: 0.165, green: 0.165, blue: 0.314, alpha: 1.0)     // #2a2a50

    static let accent = UIColor(red: 0.424, green: 0.361, blue: 0.906, alpha: 1.0)         // #6c5ce7
    static let accentLight = UIColor(red: 0.635, green: 0.608, blue: 0.996, alpha: 1.0)    // #a29bfe
    static let accentDim = UIColor(red: 0.424, green: 0.361, blue: 0.906, alpha: 0.15)
    static let accentGlow = UIColor(red: 0.424, green: 0.361, blue: 0.906, alpha: 0.3)

    static let neon = UIColor(red: 0.0, green: 0.96, blue: 0.82, alpha: 1.0)              // #00f5d4
    static let neonDim = UIColor(red: 0.0, green: 0.96, blue: 0.82, alpha: 0.15)
    static let neonGlow = UIColor(red: 0.0, green: 0.96, blue: 0.82, alpha: 0.3)

    static let text = UIColor(red: 0.91, green: 0.91, blue: 0.94, alpha: 1.0)             // #e8e8f0
    static let textDim = UIColor(red: 0.533, green: 0.533, blue: 0.667, alpha: 1.0)       // #8888aa
    static let textMuted = UIColor(red: 0.333, green: 0.333, blue: 0.467, alpha: 1.0)     // #555577

    static let success = UIColor(red: 0.18, green: 0.84, blue: 0.45, alpha: 1.0)          // #2ed573
    static let danger = UIColor(red: 1.0, green: 0.278, blue: 0.341, alpha: 1.0)          // #ff4757
    static let warning = UIColor(red: 1.0, green: 0.702, blue: 0.0, alpha: 1.0)           // #ffb300
    static let gold = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)

    // Difficulty colors matching website
    static let easy = UIColor(red: 0.0, green: 0.902, blue: 0.463, alpha: 1.0)            // #00e676
    static let medium = UIColor(red: 1.0, green: 0.702, blue: 0.0, alpha: 1.0)            // #ffb300
    static let hard = UIColor(red: 1.0, green: 0.427, blue: 0.0, alpha: 1.0)              // #ff6d00
    static let extreme = UIColor(red: 1.0, green: 0.09, blue: 0.267, alpha: 1.0)          // #ff1744

    // Legacy aliases
    static let accentLight_old = accentDim

    // Card styling — dark card with border
    static func applyCard(to view: UIView, cornerRadius: CGFloat = 14) {
        view.backgroundColor = card
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = border.cgColor
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOpacity = 0
    }

    // Glow card variant
    static func applyGlowCard(to view: UIView, cornerRadius: CGFloat = 14) {
        view.backgroundColor = card
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = 1
        view.layer.borderColor = accentGlow.cgColor
        view.layer.shadowColor = accent.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 20
    }

    // Smooth spring animation
    static func spring(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0, damping: CGFloat = 0.75, velocity: CGFloat = 0.5, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [.curveEaseInOut], animations: animations, completion: completion)
    }

    static func fadeIn(_ view: UIView, delay: TimeInterval = 0, duration: TimeInterval = 0.3) {
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 8)
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
            view.alpha = 1
            view.transform = .identity
        })
    }

    static func pop(_ view: UIView, scale: CGFloat = 1.15) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.4, options: [], animations: {
                view.transform = .identity
            })
        }
    }

    static func addButtonEffect(to button: UIButton) {
        button.addTarget(ButtonEffectHandler.shared, action: #selector(ButtonEffectHandler.buttonDown(_:)), for: .touchDown)
        button.addTarget(ButtonEffectHandler.shared, action: #selector(ButtonEffectHandler.buttonUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // Haptics
    static func hapticLight() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func hapticMedium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func hapticSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func hapticError() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    // Difficulty color — matching website
    static func difficultyColor(for difficulty: Int) -> UIColor {
        switch difficulty {
        case 1...3: return easy
        case 4...6: return medium
        case 7...8: return hard
        default: return extreme
        }
    }
}

class ButtonEffectHandler: NSObject {
    static let shared = ButtonEffectHandler()

    @objc func buttonDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            sender.alpha = 0.9
        }
    }

    @objc func buttonUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: []) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
}
