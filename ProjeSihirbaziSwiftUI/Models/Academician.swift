import Foundation

// Akademisyen modelini tanımlıyoruz.
struct Academician: Codable, Identifiable  {
    var id: String { name } // Identifiable için id ekledim, isterseniz farklı bir alan kullanabilirsiniz.
    var title: String
    var name: String
    var section: String
    var keywords: String
    var imageUrl: String
    var university: String
    var province: String
}
