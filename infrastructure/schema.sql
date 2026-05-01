-- PostgreSQL Schema for WhoSingsThis

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE tracks (
    track_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    artist TEXT NOT NULL,
    album TEXT,
    provider TEXT DEFAULT 'spotify', -- e.g., 'spotify', 'apple_music'
    provider_id TEXT, -- The ID in the provider's system
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fingerprints (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hash TEXT NOT NULL, -- Chromaprint or similar hash
    track_id UUID REFERENCES tracks(track_id),
    verified_flag BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE playlists (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL, -- External user ID (e.g., Spotify user ID)
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE playlist_tracks (
    playlist_id UUID REFERENCES playlists(uuid) ON DELETE CASCADE,
    track_id UUID REFERENCES tracks(track_id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, track_id)
);

CREATE INDEX idx_fingerprints_hash ON fingerprints(hash);
