import Foundation

struct FrameCard: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let createdAt: Date
    var title: String
    var associations: [String]
    var atmosphereId: String
    let imageFileName: String
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        title: String,
        associations: [String],
        atmosphereId: String,
        imageFileName: String,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.associations = associations
        self.atmosphereId = atmosphereId
        self.imageFileName = imageFileName
        self.isFavorite = isFavorite
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case title
        case associations
        case atmosphereId
        case imageFileName
        case isFavorite
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        title = try container.decode(String.self, forKey: .title)
        associations = try container.decode([String].self, forKey: .associations)
        atmosphereId = try container.decode(String.self, forKey: .atmosphereId)
        imageFileName = try container.decode(String.self, forKey: .imageFileName)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }
}
