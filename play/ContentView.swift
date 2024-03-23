import SwiftUI
import Foundation

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()

    var body: some View {
        List {
            ForEach(viewModel.sectionData.indices, id: \.self) { index in
                let section = viewModel.sectionData[index]
                Section(header: Text(section.title)) {
                    
                    HStack {
                        ForEach(section.children.indices, id: \.self) { movieIndex in
                            let movie = section.children[movieIndex]

                            if let posterURL = movie.poster, let url = URL(string: posterURL) {
                                RemoteImage(url: url)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 200)
                                    .clipped()
                                    .cornerRadius(10)
                            } else {
                                ZStack {
                                    Color.gray
                                        .frame(width: 150, height: 200)
                                        .cornerRadius(10)
                                    
                                    Text(movie.title)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(.white)
                                        .padding()
                                        .cornerRadius(10)
                                        .padding()
                                }
                            }
                        }
                    }

                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
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
    var banner: String?
    var poster: String?
    var duration: String
    var categories: [String]
    var cast: [Cast]
}

struct Cast: Codable {
    var name: String
    var image: String
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
