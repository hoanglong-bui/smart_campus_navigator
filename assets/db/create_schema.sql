-- 1. Kích hoạt hỗ trợ Foreign Key (Quan trọng)
PRAGMA foreign_keys = ON;

-- 2. Bảng Cụm khu vực (Clusters) - 
CREATE TABLE clusters (
    cluster_id TEXT PRIMARY KEY NOT NULL,
    name_en TEXT NOT NULL,
    name_hi TEXT, -- Tên tiếng Hindi
    name_vi TEXT, -- Tên tiếng Việt
    center_lat REAL,
    center_lng REAL,
    radius_km REAL -- Bán kính bao phủ (ví dụ: 2.5 km)
);

-- 3. Bảng Danh mục (Categories)
CREATE TABLE categories (
    category TEXT NOT NULL,
    sub_category TEXT NOT NULL,
    icon_name TEXT,
    PRIMARY KEY (category, sub_category)
);

-- 4. Bảng Meta (Quản lý phiên bản)
CREATE TABLE meta (
    key TEXT PRIMARY KEY NOT NULL,
    value TEXT NOT NULL
);

-- 5. Bảng Dịch vụ Chính (Services - Thông tin cố định)
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
    hours_json TEXT, -- Lưu JSON giờ làm việc để xử lý logic
    verified INTEGER DEFAULT 0,
    active INTEGER DEFAULT 1,
    last_reviewed_by TEXT, -- Người kiểm duyệt/cập nhật cuối cùng
    updated_at INTEGER,
    FOREIGN KEY (cluster_id) REFERENCES clusters (cluster_id),
    FOREIGN KEY (category, sub_category) REFERENCES categories (category, sub_category)
);

-- 6. Bảng Dịch vụ Đa ngôn ngữ (Translations)
CREATE TABLE service_translations (
    translation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id INTEGER NOT NULL,
    language_code TEXT NOT NULL, -- 'en', 'hi', 'vi'
    name TEXT NOT NULL,
    description TEXT,
    address TEXT,
    hours_text TEXT, -- Giờ làm việc dạng văn bản hiển thị
    FOREIGN KEY (service_id) REFERENCES services (service_id) ON DELETE CASCADE,
    UNIQUE (service_id, language_code)
);

-- 7. Bảng Ảo Tìm kiếm Nhanh (FTS5)
CREATE VIRTUAL TABLE service_translations_fts USING fts5(
    name,
    description,
    address,
    content='service_translations',
    content_rowid='translation_id'
);

-- 8. Triggers (Tự động đồng bộ FTS5)
CREATE TRIGGER trg_service_translations_insert AFTER INSERT ON service_translations
BEGIN
    INSERT INTO service_translations_fts (rowid, name, description, address)
    VALUES (new.translation_id, new.name, new.description, new.address);
END;

CREATE TRIGGER trg_service_translations_update AFTER UPDATE ON service_translations
BEGIN
    UPDATE service_translations_fts
    SET name = new.name, description = new.description, address = new.address
    WHERE rowid = old.translation_id;
END;

CREATE TRIGGER trg_service_translations_delete AFTER DELETE ON service_translations
BEGIN
    DELETE FROM service_translations_fts WHERE rowid = old.translation_id;
END;