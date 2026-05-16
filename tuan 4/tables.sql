
USE master;

go

-- ============================================================
-- 1.0. Tạo Database
-- ============================================================
-- Drop nếu đã tồn tại (để rerun script an toàn)
IF Db_id('QLDT') IS NOT NULL
  BEGIN
      ALTER DATABASE qldt

      SET single_user WITH

      ROLLBACK immediate;

      DROP DATABASE qldt;
  END

go

CREATE DATABASE qldt;

go

USE qldt;

go

-- ============================================================
-- 1.1. CREATE TABLE - 14 quan hệ
-- Thứ tự theo dependency: bảng cha → bảng con
-- ============================================================
-- ===== Lớp 1: Bảng độc lập =====
CREATE TABLE sinhvien
  (
     mssv   CHAR(8) NOT NULL,
     tensv  NVARCHAR(30) NOT NULL,
     sodt   VARCHAR(10) NULL,
     lop    CHAR(10) NOT NULL,
     diachi NCHAR(50) NULL,
     CONSTRAINT pk_sinhvien PRIMARY KEY (mssv)
  );

go

CREATE TABLE detai
  (
     msdt  CHAR(6) NOT NULL,
     tendt NVARCHAR(30) NOT NULL,
     CONSTRAINT pk_detai PRIMARY KEY (msdt)
  );

go

CREATE TABLE hocham
  (
     mshh  INT NOT NULL,
     tenhh NVARCHAR(20) NOT NULL,
     CONSTRAINT pk_hocham PRIMARY KEY (mshh)
  );

go

CREATE TABLE hocvi
  (
     mshv  INT NOT NULL,
     tenhv NVARCHAR(20) NOT NULL,
     CONSTRAINT pk_hocvi PRIMARY KEY (mshv)
  );

go

CREATE TABLE chuyennganh
  (
     mscn  INT NOT NULL,
     tencn NVARCHAR(30) NOT NULL,
     CONSTRAINT pk_chuyennganh PRIMARY KEY (mscn)
  );

go

-- ===== Lớp 2: Phụ thuộc lớp 1 =====
CREATE TABLE giaovien
  (
     msgv   INT NOT NULL,
     tengv  NVARCHAR(30) NOT NULL,
     diachi NVARCHAR(50) NOT NULL,
     sodt   VARCHAR(10) NOT NULL,
     mshh   INT NULL,
     namhh  SMALLDATETIME NOT NULL,
     CONSTRAINT pk_giaovien PRIMARY KEY (msgv),
     CONSTRAINT fk_giaovien_hocham FOREIGN KEY (mshh) REFERENCES hocham(mshh)
  );

go

CREATE TABLE sv_detai
  (
     mssv CHAR(8) NOT NULL,
     msdt CHAR(6) NOT NULL,
     CONSTRAINT pk_sv_detai PRIMARY KEY (mssv, msdt),
     CONSTRAINT fk_svdt_sv FOREIGN KEY (mssv) REFERENCES sinhvien(mssv),
     CONSTRAINT fk_svdt_dt FOREIGN KEY (msdt) REFERENCES detai(msdt)
  );

go

-- ===== Lớp 3: Phụ thuộc GIAOVIEN =====
CREATE TABLE gv_hv_cn
  (
     msgv INT NOT NULL,
     mshv INT NOT NULL,
     mscn INT NOT NULL,
     nam  SMALLDATETIME NOT NULL,
     CONSTRAINT pk_gv_hv_cn PRIMARY KEY (msgv, mshv, mscn),
     CONSTRAINT fk_gvhvcn_gv FOREIGN KEY (msgv) REFERENCES giaovien(msgv),
     CONSTRAINT fk_gvhvcn_hv FOREIGN KEY (mshv) REFERENCES hocvi(mshv),
     CONSTRAINT fk_gvhvcn_cn FOREIGN KEY (mscn) REFERENCES chuyennganh(mscn)
  );

go

CREATE TABLE gv_hddt
  (
     msgv INT NOT NULL,
     msdt CHAR(6) NOT NULL,
     diem FLOAT NOT NULL,
     CONSTRAINT pk_gv_hddt PRIMARY KEY (msgv, msdt),
     CONSTRAINT fk_gvhddt_gv FOREIGN KEY (msgv) REFERENCES giaovien(msgv),
     CONSTRAINT fk_gvhddt_dt FOREIGN KEY (msdt) REFERENCES detai(msdt)
  );

go

CREATE TABLE gv_pbdt
  (
     msgv INT NOT NULL,
     msdt CHAR(6) NOT NULL,
     diem FLOAT NOT NULL,
     CONSTRAINT pk_gv_pbdt PRIMARY KEY (msgv, msdt),
     CONSTRAINT fk_gvpbdt_gv FOREIGN KEY (msgv) REFERENCES giaovien(msgv),
     CONSTRAINT fk_gvpbdt_dt FOREIGN KEY (msdt) REFERENCES detai(msdt)
  );

go

CREATE TABLE gv_uvdt
  (
     msgv INT NOT NULL,
     msdt CHAR(6) NOT NULL,
     diem FLOAT NOT NULL,
     CONSTRAINT pk_gv_uvdt PRIMARY KEY (msgv, msdt),
     CONSTRAINT fk_gvuvdt_gv FOREIGN KEY (msgv) REFERENCES giaovien(msgv),
     CONSTRAINT fk_gvuvdt_dt FOREIGN KEY (msdt) REFERENCES detai(msdt)
  );

go

CREATE TABLE hoidong
  (
     mshd      INT NOT NULL,
     phong     INT NOT NULL,
     tgbd      SMALLDATETIME NOT NULL,
     ngayhd    SMALLDATETIME NULL,
     tinhtrang NVARCHAR(30) NULL,
     msgv      INT NULL,
     CONSTRAINT pk_hoidong PRIMARY KEY (mshd),
     CONSTRAINT fk_hoidong_gv FOREIGN KEY (msgv) REFERENCES giaovien(msgv)
  );

go

-- ===== Lớp 4: Phụ thuộc HOIDONG =====
CREATE TABLE hoidong_gv
  (
     mshd INT NOT NULL,
     msgv INT NOT NULL,
     CONSTRAINT pk_hoidong_gv PRIMARY KEY (mshd, msgv),
     CONSTRAINT fk_hdgv_hd FOREIGN KEY (mshd) REFERENCES hoidong(mshd),
     CONSTRAINT fk_hdgv_gv FOREIGN KEY (msgv) REFERENCES giaovien(msgv)
  );

go

CREATE TABLE hoidong_dt
  (
     mshd      INT NOT NULL,
     msdt      CHAR(6) NOT NULL,
     quyetdinh NCHAR(10) NULL,
     CONSTRAINT pk_hoidong_dt PRIMARY KEY (mshd, msdt),
     CONSTRAINT fk_hddt_hd FOREIGN KEY (mshd) REFERENCES hoidong(mshd),
     CONSTRAINT fk_hddt_dt FOREIGN KEY (msdt) REFERENCES detai(msdt)
  );

go

-- ============================================================
-- 1.2. INSERT dữ liệu
-- ============================================================
-- ===== Lớp 1 =====
INSERT INTO sinhvien
            (mssv,
             tensv,
             sodt,
             lop,
             diachi)
VALUES      ('13520001',
             N'Nguyễn Văn An',
             '0906762255',
             'SE103.U32',
             N'THỦ ĐỨC'),
            ('13520002',
             N'Phan Tấn Đạt',
             '0975672350',
             'IE204.T21',
             N'QUẬN 1'),
            ('13520003',
             N'Nguyễn Anh Hải',
             '0947578688',
             'IE205.R12',
             N'QUẬN 9'),
            ('13520004',
             N'Phạm Tài',
             '0956757869',
             'IE202.A22',
             N'QUẬN 1'),
            ('13520005',
             N'Lê Thúy Hằng',
             '0976668688',
             'SE304.E22',
             N'THỦ ĐỨC'),
            ('13520006',
             N'Ưng Hồng Ân',
             '0957475898',
             'IE208.F33',
             N'QUẬN 2');

INSERT INTO detai
            (msdt,
             tendt)
VALUES      ('97001',
             N'Quản lý thư viện'),
            ('97002',
             N'Nhận dạng vân tay'),
            ('97003',
             N'Bán đấu giá trên mạng'),
            ('97004',
             N'Quản lý siêu thị'),
            ('97005',
             N'Xử lý ảnh'),
            ('97006',
             N'Hệ giải toán thông minh');

INSERT INTO hocham
            (mshh,
             tenhh)
VALUES      (1,
             N'PHÓ GIÁO SƯ'),
            (2,
             N'GIÁO SƯ');

INSERT INTO hocvi
            (mshv,
             tenhv)
VALUES      (1,
             N'Kỹ sư'),
            (2,
             N'Cử nhân'),
            (3,
             N'Thạc sĩ'),
            (4,
             N'Tiến sĩ'),
            (5,
             N'Tiến sĩ Khoa học');

INSERT INTO chuyennganh
            (mscn,
             tencn)
VALUES      (1,
             N'Công nghệ Web'),
            (2,
             N'Mạng xã hội'),
            (3,
             N'Quản lý CNTT'),
            (4,
             N'GIS');

-- ===== Lớp 2 =====
INSERT INTO giaovien
            (msgv,
             tengv,
             diachi,
             sodt,
             mshh,
             namhh)
VALUES      (201,
             N'Trần Trung',
             N'Bến Tre',
             '35353535',
             1,
             '1996-01-01'),
            (202,
             N'Nguyễn Văn An',
             N'Tiềng Giang',
             '67868688',
             1,
             '1996-01-01'),
            (203,
             N'Trần Thu Trang',
             N'Cần Thơ',
             '74758687',
             1,
             '1996-01-01'),
            (204,
             N'Nguyễn Thị Loan',
             N'TP. HCM',
             '56575868',
             2,
             '2005-01-01'),
            (205,
             N'Chu Tiến',
             N'Hà Nội',
             '46466646',
             2,
             '2005-01-01');

INSERT INTO sv_detai
            (mssv,
             msdt)
VALUES      ('13520001',
             '97004'),
            ('13520002',
             '97005'),
            ('13520003',
             '97001'),
            ('13520004',
             '97002'),
            ('13520005',
             '97003'),
            ('13520006',
             '97005');

-- ===== Lớp 3 =====
INSERT INTO gv_hv_cn
            (msgv,
             mshv,
             mscn,
             nam)
VALUES      (201,
             1,
             1,
             '2013-01-01'),
            (201,
             1,
             2,
             '2013-01-01'),
            (201,
             2,
             1,
             '2014-01-01'),
            (202,
             3,
             2,
             '2013-01-01'),
            (203,
             2,
             4,
             '2014-01-01'),
            (204,
             3,
             2,
             '2014-01-01');

INSERT INTO gv_hddt
            (msgv,
             msdt,
             diem)
VALUES      (201,
             '97001',
             8),
            (202,
             '97002',
             7),
            (205,
             '97001',
             9),
            (204,
             '97004',
             7),
            (203,
             '97005',
             9);

INSERT INTO gv_pbdt
            (msgv,
             msdt,
             diem)
VALUES      (201,
             '97005',
             8),
            (202,
             '97001',
             7),
            (205,
             '97004',
             9),
            (204,
             '97003',
             7),
            (203,
             '97002',
             9);

INSERT INTO gv_uvdt
            (msgv,
             msdt,
             diem)
VALUES      (205,
             '97005',
             8),
            (202,
             '97005',
             7),
            (204,
             '97005',
             9),
            (203,
             '97001',
             7),
            (204,
             '97001',
             9),
            (205,
             '97001',
             8),
            (203,
             '97003',
             7),
            (201,
             '97003',
             9),
            (202,
             '97003',
             7),
            (201,
             '97004',
             9),
            (202,
             '97004',
             8),
            (203,
             '97004',
             7),
            (201,
             '97002',
             9),
            (204,
             '97002',
             7),
            (205,
             '97002',
             9),
            (201,
             '97006',
             9),
            (202,
             '97006',
             7),
            (204,
             '97006',
             9);

INSERT INTO hoidong
            (mshd,
             phong,
             tgbd,
             ngayhd,
             tinhtrang,
             msgv)
VALUES      (1,
             2,
             '2014-11-29 07:00:00',
             '2014-11-29',
             N'Thật',
             201),
            (2,
             102,
             '2014-12-05 07:00:00',
             '2014-12-05',
             N'Thật',
             202),
            (3,
             3,
             '2014-12-06 08:00:00',
             '2014-12-06',
             N'Thật',
             203);

-- ===== Lớp 4 =====
INSERT INTO hoidong_gv
            (mshd,
             msgv)
VALUES      (1,
             201),
            (1,
             202),
            (1,
             203),
            (1,
             204),
            (2,
             203),
            (2,
             202),
            (2,
             205),
            (2,
             204),
            (3,
             201),
            (3,
             202),
            (3,
             203),
            (3,
             204);

INSERT INTO hoidong_dt
            (mshd,
             msdt,
             quyetdinh)
VALUES      (1,
             '97001',
             N'Được'),
            (1,
             '97002',
             N'Được'),
            (2,
             '97001',
             N'Không'),
            (2,
             '97004',
             N'Không'),
            (1,
             '97005',
             N'Được'),
            (3,
             '97001',
             N'Không'),
            (3,
             '97002',
             N'Được');

go

-- ============================================================
-- RESULT
-- ============================================================
SELECT *
FROM   sinhvien;

SELECT *
FROM   detai;

SELECT *
FROM   giaovien;

SELECT *
FROM   hocham;

SELECT *
FROM   hocvi;

SELECT *
FROM   chuyennganh;

SELECT *
FROM   sv_detai;

SELECT *
FROM   gv_hv_cn;

SELECT *
FROM   gv_hddt;

SELECT *
FROM   gv_pbdt;

SELECT *
FROM   gv_uvdt;

SELECT *
FROM   hoidong;

SELECT *
FROM   hoidong_gv;

SELECT *
FROM   hoidong_dt;

-- ============================================================
-- RESULT
-- ============================================================