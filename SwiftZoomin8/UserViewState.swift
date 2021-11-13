import Combine
import Foundation

import class UIKit.UIImage

final class UserViewState {
    let id: User.ID
    
    @Published private(set) var user: User?
    @Published private(set) var iconImage: UIImage?
    
    init(id: User.ID) {
        self.id = id
    }
    
    func loadUser() async throws {
        // User の JSON の取得
        let url: URL = .init(string: "https://koherent.org/fake-service/api/user?id=\(id)")!
        let data = try await downloadData(from: url)
        
        // JSON のデコード
        self.user = try JSONDecoder().decode(User.self, from: data)
        
        // アイコン画像の取得
        let iconData = try await downloadData(from: user!.iconURL)
        // Data を UIImage に変換
        guard let iconImage: UIImage = .init(data: iconData) else {
            // エラーハンドリング
            print("The icon image at \(user!.iconURL) has an illegal format.")
            return
        }
        
        self.iconImage = iconImage
    }
}
