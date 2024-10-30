//
//  MainView.swift
//  aki
//
//  Created by Conrad Reeves on 10/30/24.
//

import SwiftUI

// MARK: - Main Navigation Enums
enum NavigationItem: Hashable, Identifiable {
    case home
    case trending
    case genres
    case schedule
    case search
    case animeDetails
    case animeWatch
    case settings
    case libraryItem(LibraryItem)
    case playlist(String)
    
    var id: String {
        switch self {
        case .libraryItem(let item):
            return "library-\(item.rawValue)"
        case .playlist(let name):
            return "playlist-\(name)"
        case .home:
            return "home"
        case .trending:
            return "trending"
        case .genres:
            return "genres"
        case .schedule:
            return "schedule"
        case .search:
            return "search"
        case .animeDetails:
            return "anime-details"
        case .animeWatch:
            return "anime-watch"
        case .settings:
            return "settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home:
            return "house"
        case .trending:
            return "chart.line.uptrend.xyaxis"
        case .genres:
            return "list.bullet"
        case .schedule:
            return "calendar"
        case .search:
            return "magnifyingglass"
        case .animeDetails:
            return "info.circle"
        case .animeWatch:
            return "play.circle"
        case .settings:
            return "gear"
        case .libraryItem(let item):
            return item.icon
        case .playlist:
            return "star.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .trending:
            return "Trending"
        case .genres:
            return "Genres"
        case .schedule:
            return "Schedule"
        case .search:
            return "Search"
        case .animeDetails:
            return "Anime Details"
        case .animeWatch:
            return "Watch"
        case .settings:
            return "Settings"
        case .libraryItem(let item):
            return item.rawValue
        case .playlist(let name):
            return name
        }
    }
}

enum LibraryItem: String, Identifiable, CaseIterable {
    case recentlyWatched = "Recently Watched"
    case movies = "Movies"
    case tvSeries = "TV Series"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .recentlyWatched: return "clock"
        case .movies: return "film"
        case .tvSeries: return "tv"
        }
    }
}

// MARK: - Main View
struct MainView: View {
    @State private var selectedNavigation: NavigationItem? = .home
    @State private var searchText: String = ""
    @State private var isLibraryExpanded = true
    @State private var isPlaylistsExpanded = true
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selectedNavigation: $selectedNavigation,
                    searchText: $searchText,
                    isLibraryExpanded: $isLibraryExpanded,
                    isPlaylistsExpanded: $isPlaylistsExpanded,
                    navigationPath: $navigationPath)  // Add this
        } detail: {
            NavigationStack(path: $navigationPath) {
                ContentView(selectedNavigation: $selectedNavigation, navigationPath: $navigationPath)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Sidebar
struct Sidebar: View {
    @Binding var selectedNavigation: NavigationItem?
    @Binding var searchText: String
    @Binding var isLibraryExpanded: Bool
    @Binding var isPlaylistsExpanded: Bool
    @Binding var navigationPath: NavigationPath  // Add this
    @FocusState private var isSearchFocused: Bool
        
    var body: some View {
        List(selection: $selectedNavigation) {
            HStack {
                TextField("", text: $searchText, prompt: Text("Search"))
                    .focused($isSearchFocused)
                    .onChange(of: isSearchFocused) { _, isFocused in
                        if isFocused {
                            selectedNavigation = .search
                        }
                    }
                    .onSubmit {
                        print("Searched for: \(searchText)")
                    }
                    .textFieldStyle(.roundedBorder)
            }
//            .overlay(
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.secondary)
//                    .padding(.leading, 6),
//                alignment: .leading
//            )
            .onTapGesture {
                selectedNavigation = .search
            }
            
            mainNavigation
            
            librarySection
            
            playlistsSection
            
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                navigationPath.append(NavigationItem.settings)
                selectedNavigation = .settings
            } label: {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text("John Doe")
                        Text("View Profile")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.plain)
        }
    }
    
    private var mainNavigation: some View {
        Section {
            ForEach([NavigationItem.home, .trending, .genres, .schedule], id: \.self) { item in
                Label(item.title, systemImage: item.icon)
                    .tag(item)
            }
        }
    }
    
    private var librarySection: some View {
        Section(isExpanded: $isLibraryExpanded) {
            ForEach(LibraryItem.allCases) { item in
                NavigationLink(value: NavigationItem.libraryItem(item)) {
                    Label(item.rawValue, systemImage: item.icon)
                }
            }
        } header: {
            Text("Library")
        }
    }
    
    private var playlistsSection: some View {
        Section(isExpanded: $isPlaylistsExpanded) {
            NavigationLink(value: NavigationItem.playlist("My Top 25 Rated")) {
                Label("My Top 25 Rated", systemImage: "star.fill")
            }
        } header: {
            Text("Playlists")
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @Binding var selectedNavigation: NavigationItem?
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            if let navigation = selectedNavigation {
                switch navigation {
                case .home:
                    HomeView(navigationPath: $navigationPath)
                case .trending:
                    TrendingView()
                case .genres:
                    GenresView()
                case .schedule:
                    ScheduleView()
                case .search:
                    SearchView()
                case .libraryItem(let item):
                    LibraryView(item: item)
                case .playlist(let name):
                    PlaylistView(name: name)
                case .settings:
                    SettingsView()
                        .navigationTitle("Settings")
                case .animeDetails:
                    AnimeDetailsView(navigationPath: $navigationPath)
                case .animeWatch:
                    AnimeWatchView()
                }
            } else {
                HomeView(navigationPath: $navigationPath)
            }
        }
        .navigationDestination(for: NavigationItem.self) { item in
            switch item {
            case .animeDetails:
                AnimeDetailsView(navigationPath: $navigationPath)
            case .animeWatch:
                AnimeWatchView()
            case .libraryItem(let libraryItem):
                LibraryView(item: libraryItem)
            case .playlist(let name):
                PlaylistView(name: name)
            case .settings:
                SettingsView()
            default:
                EmptyView()
            }
        }
        .toolbar {
            if selectedNavigation == .search {
                ToolbarItemGroup {
                    Menu {
                        Button("Action", action: {})
                        Button("Comedy", action: {})
                        Button("Drama", action: {})
                    } label: {
                        Label("Genre", systemImage: "tag")
                    }
                    
                    Menu {
                        Button("TV", action: {})
                        Button("Movie", action: {})
                        Button("OVA", action: {})
                    } label: {
                        Label("Type", systemImage: "tv")
                    }
                    
                    Picker("Rating", selection: .constant("All")) {
                        Text("All").tag("All")
                        Text("PG-13").tag("PG-13")
                        Text("R").tag("R")
                    }
                    
                    Menu {
                        Button("Currently Airing", action: {})
                        Button("Finished Airing", action: {})
                        Button("Not Yet Aired", action: {})
                    } label: {
                        Label("Status", systemImage: "clock")
                    }
                }
            }
        }
    }
}

// MARK: - Placeholder Views
struct HomeView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            Text("Home View")
            Button("Open Anime Details") {
                navigationPath.append(NavigationItem.animeDetails)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TrendingView: View {
    var body: some View {
        Text("Trending View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GenresView: View {
    var body: some View {
        Text("Genres View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ScheduleView: View {
    var body: some View {
        Text("Schedule View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SearchView: View {
    @State private var localSearchText: String = ""
    @State private var selectedGenres: Set<String> = []
    @State private var selectedTypes: Set<String> = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search anime...", text: $localSearchText)
                    .textFieldStyle(.plain)
                    .font(.title2)
                
                if !localSearchText.isEmpty {
                    Button(action: { localSearchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color(.textBackgroundColor)))
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                if localSearchText.isEmpty {
                    Text("Recent Searches")
                        .font(.headline)
                    
                    ForEach(["One Piece", "Naruto", "Death Note"], id: \.self) { search in
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text(search)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            localSearchText = search
                        }
                    }
                } else {
                    searchResults
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchResults: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 200), spacing: 16)
            ], spacing: 16) {
                ForEach(0..<20, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(Text("Anime Title"))
                }
            }
            .padding()
        }
    }
}

struct AnimeDetailsView: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            Text("Anime Details")
            
            Button("Watch Now") {
                navigationPath.append(NavigationItem.animeWatch)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Anime Title")
    }
}

struct AnimeWatchView: View {
    var body: some View {
        Text("Anime Watch View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Now Playing")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Settings")
    }
}

struct LibraryView: View {
    let item: LibraryItem
    
    var body: some View {
        Text("\(item.rawValue) View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(item.rawValue)
    }
}

struct PlaylistView: View {
    let name: String
    
    var body: some View {
        Text("\(name) View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(name)
    }
}

// MARK: - Preview
#Preview {
    MainView()
}
