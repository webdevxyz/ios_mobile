import SwiftUI
import Foundation

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()

    var body: some View {
        List {
            ForEach(viewModel.sectionData.indices, id: \.self) { sectionIndex in
                let section = viewModel.sectionData[sectionIndex]
                Section(header: Text(section.title)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(section.children.indices, id: \.self) { movieIndex in
                                let movie = section.children[movieIndex]
                                VStack {
                                    Text(movie.title)
                                        .font(.headline)
                                    RemoteImage(url: movie.poster)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 160) // Adjust card size here
                                        .clipped()
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 10) // Adjust padding here
                    }
                    .background(Color.clear) // Remove white background
                }
                .listRowInsets(EdgeInsets()) // Remove extra padding and border from section
                .padding(.vertical, -10) // Remove extra spacing
            }
        }
        .listStyle(PlainListStyle()) // Remove any default list style
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ContentViewModel: ObservableObject {
    @Published var sectionData = [SectionItem]()

    init() {
        fetchData()
    }

    func fetchData() {
        guard let url = URL(string: "https://cms.webdevxyz.com/json/featured.json") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }

            do {
                let sectionData = try JSONDecoder().decode([SectionItem].self, from: data)
                DispatchQueue.main.async {
                    self.sectionData = sectionData
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}

struct Movie: Codable {
    var title: String
    var banner: URL
    var poster: URL
    var duration: String
    var categories: [String]
    var cast: [Cast]
}

struct Cast: Codable {
    var name: String
    var image: URL
    var bio: String
    var type: String
}

struct SectionItem: Codable {
    var title: String
    var children: [Movie]
}

struct RemoteImage: View {
    private var url: URL
    @StateObject private var imageLoader = ImageLoader()

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        Image(uiImage: imageLoader.image ?? UIImage())
            .resizable()
            .scaledToFill()
            .onAppear {
                imageLoader.loadImage(from: url)
            }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var cache = NSCache<NSURL, UIImage>()
    private var dataTask: URLSessionDataTask?

    func loadImage(from url: URL) {
        if let imageFromCache = cache.object(forKey: url as NSURL) {
            self.image = imageFromCache
            return
        }

        dataTask?.cancel()

        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let newImage = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.cache.setObject(newImage, forKey: url as NSURL)
                self.image = newImage
            }
        }

        dataTask?.resume()
    }
}
