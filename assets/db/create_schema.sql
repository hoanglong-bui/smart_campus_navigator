-- 1. Kích hoạt hỗ trợ Foreign Key
PRAGMA foreign_keys = ON;

--SPLIT

-- 2. Bảng Cụm khu vực (Clusters)
CREATE TABLE clusters (
    cluster_id TEXT PRIMARY KEY NOT NULL,
    name_en TEXT NOT NULL,
    name_hi TEXT,
    name_vi TEXT,
    center_lat REAL,
    center_lng REAL,
    radius_km REAL
);

--SPLIT

-- 3. Bảng Danh mục (Categories)
CREATE TABLE categories (
    category TEXT NOT NULL,
    sub_category TEXT NOT NULL,
    icon_name TEXT,
    PRIMARY KEY (category, sub_category)
);

--SPLIT

-- 4. Bảng Meta
CREATE TABLE meta (
    key TEXT PRIMARY KEY NOT NULL,
    value TEXT NOT NULL
);

--SPLIT

-- 5. Bảng Dịch vụ Chính
CREATE TABLE services (
    service_id INTEGER PRIMARY KEY,
    cluster_id TEXT,
    category TEXT NOT NULL,
    sub_category TEXT NOT NULL,
    latitude REAL NOT NULL CHECK(latitude >= -90 AND latitude <= 90),
    longitude REAL NOT NULL CHECK(longitude >= -180 AND longitude <= 180),
    phone TEXT,
    email TEXT,
    website TEXT,
    hours_json TEXT,
    verified INTEGER DEFAULT 0,
    active INTEGER DEFAULT 1,
    last_reviewed_by TEXT,
    updated_at INTEGER,
    FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id),
    FOREIGN KEY (category, sub_category) REFERENCES categories (category, sub_category)
);

--SPLIT

-- 6. Bảng Dịch vụ Đa ngôn ngữ
CREATE TABLE service_translations (
    translation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id INTEGER NOT NULL,
    language_code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT,
    hours_text TEXT,
    FOREIGN KEY (service_id) REFERENCES services (service_id) ON DELETE CASCADE,
    UNIQUE (service_id, language_code)
);

--SPLIT

-- 7. Bảng Ảo Tìm kiếm (FTS5)
CREATE VIRTUAL TABLE service_translations_fts USING fts5(
    name,
    description,
    address,
    content='service_translations',
    content_rowid='translation_id'
);

--SPLIT

-- 8. Triggers (Tự động đồng bộ FTS5)
CREATE TRIGGER trg_service_translations_insert AFTER INSERT ON service_translations
BEGIN
    INSERT INTO service_translations_fts (rowid, name, description, address)
    VALUES (new.translation_id, new.name, new.description, new.address);
END;

--SPLIT

CREATE TRIGGER trg_service_translations_update AFTER UPDATE ON service_translations
BEGIN
    UPDATE service_translations_fts
    SET name = new.name, description = new.description, address = new.address
    WHERE rowid = old.translation_id;
END;

--SPLIT

CREATE TRIGGER trg_service_translations_delete AFTER DELETE ON service_translations
BEGIN
    DELETE FROM service_translations_fts WHERE rowid = old.translation_id;
END;

--SPLIT

-- 9. Bảng Danh sách Quy trình (Guides)
CREATE TABLE guides (
    guide_id TEXT PRIMARY KEY NOT NULL,
    title_en TEXT NOT NULL,
    title_hi TEXT,
    title_vi TEXT,
    description_en TEXT,
    description_hi TEXT,
    description_vi TEXT,
    target_user TEXT,
    icon_name TEXT
);

--SPLIT

-- 10. Bảng Các bước thực hiện (Guide Steps)
CREATE TABLE guide_steps (
    step_id INTEGER PRIMARY KEY AUTOINCREMENT,
    guide_id TEXT NOT NULL,
    step_order INTEGER NOT NULL,
    title_en TEXT NOT NULL,
    title_hi TEXT,
    title_vi TEXT,
    description_en TEXT,
    description_hi TEXT,
    description_vi TEXT,
    linked_service_id INTEGER,
    
    FOREIGN KEY (guide_id) REFERENCES guides (guide_id) ON DELETE CASCADE,
    FOREIGN KEY (linked_service_id) REFERENCES services (service_id)
);