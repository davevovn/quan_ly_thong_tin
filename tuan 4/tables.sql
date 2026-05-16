
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
CREATE TABLE SINHVIEN
  (
     MSSV   CHAR(8) NOT NULL,
     TENSV  NVARCHAR(30) NOT NULL,
     SODT   VARCHAR(10) NULL,
     lop    CHAR(10) NOT NULL,
     DIACHI NCHAR(50) NULL,
     CONSTRAINT PK_SINHVIEN PRIMARY KEY (MSSV)
  );

go

CREATE TABLE DETAI
  (
     MSDT  CHAR(6) NOT NULL,
     TENDT NVARCHAR(30) NOT NULL,
     CONSTRAINT PK_DETAI PRIMARY KEY (MSDT)
  );

go

CREATE TABLE HOCHAM
  (
     MSHH  INT NOT NULL,
     TENHH NVARCHAR(20) NOT NULL,
     CONSTRAINT PK_HOCHAM PRIMARY KEY (MSHH)
  );

go

CREATE TABLE HOCVI
  (
     MSHV  INT NOT NULL,
     TENHV NVARCHAR(20) NOT NULL,
     CONSTRAINT PK_HOCVI PRIMARY KEY (MSHV)
  );

go

CREATE TABLE CHUYENNGANH
  (
     MSCN  INT NOT NULL,
     TENCN NVARCHAR(30) NOT NULL,
     CONSTRAINT PK_CHUYENNGANH PRIMARY KEY (MSCN)
  );

go

-- ===== Lớp 2: Phụ thuộc lớp 1 =====
CREATE TABLE GIAOVIEN
  (
     MSGV   INT NOT NULL,
     TENGV  NVARCHAR(30) NOT NULL,
     DIACHI NVARCHAR(50) NOT NULL,
     SODT   VARCHAR(10) NOT NULL,
     MSHH   INT NULL,
     NAMHH  SMALLDATETIME NOT NULL,
     CONSTRAINT PK_GIAOVIEN PRIMARY KEY (MSGV),
     CONSTRAINT FK_GIAOVIEN_HOCHAM FOREIGN KEY (MSHH) REFERENCES HOCHAM(MSHH)
  );

go

CREATE TABLE SV_DETAI
  (
     MSSV CHAR(8) NOT NULL,
     MSDT CHAR(6) NOT NULL,
     CONSTRAINT PK_SV_DETAI PRIMARY KEY (MSSV, MSDT),
     CONSTRAINT FK_svdt_sv FOREIGN KEY (MSSV) REFERENCES SINHVIEN(MSSV),
     CONSTRAINT FK_svdt_dt FOREIGN KEY (MSDT) REFERENCES DETAI(MSDT)
  );

go

-- ===== Lớp 3: Phụ thuộc GIAOVIEN =====
CREATE TABLE GV_HV_CN
  (
     MSGV INT NOT NULL,
     MSHV INT NOT NULL,
     MSCN INT NOT NULL,
     nam  SMALLDATETIME NOT NULL,
     CONSTRAINT PK_GV_HV_CN PRIMARY KEY (MSGV, MSHV, MSCN),
     CONSTRAINT FK_gvhvcn_gv FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV),
     CONSTRAINT FK_gvhvcn_hv FOREIGN KEY (MSHV) REFERENCES HOCVI(MSHV),
     CONSTRAINT FK_gvhvcn_cn FOREIGN KEY (MSCN) REFERENCES CHUYENNGANH(MSCN)
  );

go

CREATE TABLE GV_HDDT
  (
     MSGV INT NOT NULL,
     MSDT CHAR(6) NOT NULL,
     DIEM FLOAT NOT NULL,
     CONSTRAINT PK_GV_HDDT PRIMARY KEY (MSGV, MSDT),
     CONSTRAINT FK_gvhddt_gv FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV),
     CONSTRAINT FK_gvhddt_dt FOREIGN KEY (MSDT) REFERENCES DETAI(MSDT)
  );

go

CREATE TABLE GV_PBDT
  (
     MSGV INT NOT NULL,
     MSDT CHAR(6) NOT NULL,
     DIEM FLOAT NOT NULL,
     CONSTRAINT PK_GV_PBDT PRIMARY KEY (MSGV, MSDT),
     CONSTRAINT FK_gvpbdt_gv FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV),
     CONSTRAINT FK_gvpbdt_dt FOREIGN KEY (MSDT) REFERENCES DETAI(MSDT)
  );

go

CREATE TABLE GV_UVDT
  (
     MSGV INT NOT NULL,
     MSDT CHAR(6) NOT NULL,
     DIEM FLOAT NOT NULL,
     CONSTRAINT PK_GV_UVDT PRIMARY KEY (MSGV, MSDT),
     CONSTRAINT FK_gvuvdt_gv FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV),
     CONSTRAINT FK_gvuvdt_dt FOREIGN KEY (MSDT) REFERENCES DETAI(MSDT)
  );

go

CREATE TABLE HOIDONG
  (
     MSHD      INT NOT NULL,
     PHONG     INT NOT NULL,
     TGBD      SMALLDATETIME NOT NULL,
     NGAYHD    SMALLDATETIME NULL,
     TINHTRANG NVARCHAR(30) NULL,
     MSGV      INT NULL,
     CONSTRAINT PK_HOIDONG PRIMARY KEY (MSHD),
     CONSTRAINT FK_HOIDONG_GV FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV)
  );

go

-- ===== Lớp 4: Phụ thuộc HOIDONG =====
CREATE TABLE HOIDONG_GV
  (
     MSHD INT NOT NULL,
     MSGV INT NOT NULL,
     CONSTRAINT PK_HOIDONG_GV PRIMARY KEY (MSHD, MSGV),
     CONSTRAINT FK_hdgv_hd FOREIGN KEY (MSHD) REFERENCES HOIDONG(MSHD),
     CONSTRAINT FK_hdgv_gv FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV)
  );

go

CREATE TABLE HOIDONG_DT
  (
     MSHD      INT NOT NULL,
     MSDT      CHAR(6) NOT NULL,
     QUYETDINH NCHAR(10) NULL,
     CONSTRAINT PK_HOIDONG_DT PRIMARY KEY (MSHD, MSDT),
     CONSTRAINT FK_hddt_hd FOREIGN KEY (MSHD) REFERENCES HOIDONG(MSHD),
     CONSTRAINT FK_hddt_dt FOREIGN KEY (MSDT) REFERENCES DETAI(MSDT)
  );

go

-- ============================================================
-- 1.2. INSERT dữ liệu
-- ============================================================
-- ===== Lớp 1 =====
INSERT INTO SINHVIEN
            (MSSV,
             TENSV,
             SODT,
             lop,
             DIACHI)
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

INSERT INTO DETAI
            (MSDT,
             TENDT)
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

INSERT INTO HOCHAM
            (MSHH,
             TENHH)
VALUES      (1,
             N'PHÓ GIÁO SƯ'),
            (2,
             N'GIÁO SƯ');

INSERT INTO HOCVI
            (MSHV,
             TENHV)
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

INSERT INTO CHUYENNGANH
            (MSCN,
             TENCN)
VALUES      (1,
             N'Công nghệ Web'),
            (2,
             N'Mạng xã hội'),
            (3,
             N'Quản lý CNTT'),
            (4,
             N'GIS');

-- ===== Lớp 2 =====
INSERT INTO GIAOVIEN
            (MSGV,
             TENGV,
             DIACHI,
             SODT,
             MSHH,
             NAMHH)
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

INSERT INTO SV_DETAI
            (MSSV,
             MSDT)
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
INSERT INTO GV_HV_CN
            (MSGV,
             MSHV,
             MSCN,
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

INSERT INTO GV_HDDT
            (MSGV,
             MSDT,
             DIEM)
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

INSERT INTO GV_PBDT
            (MSGV,
             MSDT,
             DIEM)
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

INSERT INTO GV_UVDT
            (MSGV,
             MSDT,
             DIEM)
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

INSERT INTO HOIDONG
            (MSHD,
             PHONG,
             TGBD,
             NGAYHD,
             TINHTRANG,
             MSGV)
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
INSERT INTO HOIDONG_GV
            (MSHD,
             MSGV)
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

INSERT INTO HOIDONG_DT
            (MSHD,
             MSDT,
             QUYETDINH)
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
FROM   SINHVIEN;

SELECT *
FROM   DETAI;

SELECT *
FROM   GIAOVIEN;

SELECT *
FROM   HOCHAM;

SELECT *
FROM   HOCVI;

SELECT *
FROM   CHUYENNGANH;

SELECT *
FROM   SV_DETAI;

SELECT *
FROM   GV_HV_CN;

SELECT *
FROM   GV_HDDT;

SELECT *
FROM   GV_PBDT;

SELECT *
FROM   GV_UVDT;

SELECT *
FROM   HOIDONG;

SELECT *
FROM   HOIDONG_GV;

SELECT *
FROM   HOIDONG_DT;

-- ============================================================
-- RESULT
-- ============================================================