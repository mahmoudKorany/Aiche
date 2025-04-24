import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Reset application badge number
    UIApplication.shared.applicationIconBadgeNumber = 0
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}