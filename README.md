# BlossomMovie

An iOS 18+ SwiftUI application for browsing movies and TV shows using The Movie Database (TMDB) API.

## Setup

### API Configuration

Before building, you need to configure your API keys:

1. **Copy the template file:**
   ```bash
   cp BlossomMovie/APIConfig.json.template BlossomMovie/APIConfig.json
   ```

2. **Get your API keys:**
   - TMDB API key: https://www.themoviedb.org/?language=en-US
   - YouTube API key: https://console.cloud.google.com/

3. **Edit `BlossomMovie/APIConfig.json`** and replace the placeholder values:
   - Replace `YOUR_TMDB_API_KEY_HERE` with your TMDB API key
   - Replace `YOUR_YOUTUBE_API_KEY_HERE` with your YouTube API key

### Build

Open `BlossomMovie.xcodeproj` in Xcode and build the project, or use the command line:

```bash
xcodebuild -project BlossomMovie.xcodeproj -scheme BlossomMovie -configuration Debug build
```

## Architecture

The project follows Clean Architecture principles with a feature-based folder structure. See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation.
