import Foundation

// Модель для скина, используемая в магазине
struct Skin: Identifiable {
    let id: Int
    let name: String
    let price: Int
    let imageName: String // Имя ассета для панели в магазине
    let planeImageName: String // Имя ассета для самолета в игре
}

// Класс для управления данными игрока (монеты, скины)
// Использует UserDefaults для сохранения данных между сессиями
class PlayerData: ObservableObject {
    static let shared = PlayerData() // Singleton
    
    @Published var coins: Int
    @Published var purchasedSkins: [Int]
    @Published var selectedSkinID: Int
    
    private let coinsKey = "playerCoins"
    private let purchasedSkinsKey = "purchasedSkins"
    private let selectedSkinKey = "selectedSkinID"
    
    private init() {
        // Загружаем данные или устанавливаем значения по умолчанию
        self.coins = UserDefaults.standard.integer(forKey: coinsKey)
        self.purchasedSkins = UserDefaults.standard.array(forKey: purchasedSkinsKey) as? [Int] ?? [0] // Скин 0 куплен по умолчанию
        self.selectedSkinID = UserDefaults.standard.integer(forKey: selectedSkinKey)
        
        // Если игра запускается впервые, даем 1000 монет
        if UserDefaults.standard.object(forKey: coinsKey) == nil {
            self.coins = 1000
        }
    }
    
    // Функция для покупки скина
    func buySkin(skin: Skin) {
        guard coins >= skin.price, !purchasedSkins.contains(skin.id) else {
            print("Недостаточно монет или скин уже куплен.")
            return
        }
        
        coins -= skin.price
        purchasedSkins.append(skin.id)
        saveData()
    }
    
    // Функция для выбора скина
    func selectSkin(skin: Skin) {
        guard purchasedSkins.contains(skin.id) else {
            print("Сначала купите этот скин.")
            return
        }
        
        selectedSkinID = skin.id
        saveData()
    }
    
    // Сохранение данных в UserDefaults
    private func saveData() {
        UserDefaults.standard.set(coins, forKey: coinsKey)
        UserDefaults.standard.set(purchasedSkins, forKey: purchasedSkinsKey)
        UserDefaults.standard.set(selectedSkinID, forKey: selectedSkinKey)
    }
    
    // Список всех доступных скинов в игре
    static func getAvailableSkins() -> [Skin] {
        return [
            Skin(id: 0, name: "Default", price: 0, imageName: "skin1_panel", planeImageName: "skin1_image"),
            Skin(id: 1, name: "Red Baron", price: 500, imageName: "skin2_panel", planeImageName: "skin2_image"),
            Skin(id: 2, name: "Stealth", price: 1000, imageName: "skin3_panel", planeImageName: "skin3_panel"),
            Skin(id: 3, name: "Bumblebee", price: 1500, imageName: "skin4_panel", planeImageName: "skin4_panel")
        ]
    }
    
    // Получение имени изображения для текущего выбранного самолета
    func getCurrentPlaneImageName() -> String {
        let skins = PlayerData.getAvailableSkins()
        if let selected = skins.first(where: { $0.id == selectedSkinID }) {
            return selected.planeImageName
        }
        return "player_plane" // Возвращаем скин по умолчанию, если что-то пошло не так
    }
}
