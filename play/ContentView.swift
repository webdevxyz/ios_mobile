import SwiftUI

struct Movie: Identifiable {
    var id = UUID()
    var title: String
}

struct SectionItem: Identifiable {
    var id = UUID()
    var title: String
    var movies: [Movie]
}

struct ContentView: View {
    let sectionData = [
        SectionItem(title: "Comedy", movies: [Movie(title: "Movie 1"), Movie(title: "Movie 2"), Movie(title: "Movie 3")]),
        SectionItem(title: "Action", movies: [Movie(title: "Movie 4"), Movie(title: "Movie 5"), Movie(title: "Movie 6")]),
        SectionItem(title: "Drama", movies: [Movie(title: "Movie 7"), Movie(title: "Movie 8"), Movie(title: "Movie 9")])
    ]

    var body: some View {
        List(sectionData) { section in
            Section(header: Text(section.title)) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(section.movies) { movie in
                            MovieItem(movie: movie)
                        }
                    }
                    .padding()
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct MovieItem: View {
    let movie: Movie
    
    var body: some View {
        VStack {
            Text(movie.title)
                .padding()
                .frame(width: 150, height: 200)
                .background(Color.blue)
                .cornerRadius(10)
                .foregroundColor(.white)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
