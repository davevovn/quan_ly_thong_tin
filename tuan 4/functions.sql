USE qldt;
GO

IF OBJECT_ID('fn_DiemTrungBinhDeTai', 'FN') IS NOT NULL
    DROP FUNCTION fn_DiemTrungBinhDeTai;
GO

CREATE FUNCTION fn_DiemTrungBinhDeTai (@MSDT CHAR(6))
RETURNS FLOAT
AS
BEGIN
    DECLARE @DIEM_tb FLOAT;

    SELECT @DIEM_tb = AVG(DIEM)
    FROM (
        SELECT DIEM FROM GV_HDDT WHERE MSDT = @MSDT
        UNION ALL
        SELECT DIEM FROM GV_PBDT WHERE MSDT = @MSDT
        UNION ALL
        SELECT DIEM FROM GV_UVDT WHERE MSDT = @MSDT
    ) AS TongHopDiem;

    RETURN ISNULL(@DIEM_tb, 0);
END;
GO

IF OBJECT_ID('fn_KetQuaDeTai', 'FN') IS NOT NULL
    DROP FUNCTION fn_KetQuaDeTai;
GO

CREATE FUNCTION fn_KetQuaDeTai (@MSDT CHAR(6))
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @DIEM_tb FLOAT;
    DECLARE @ket_qua VARCHAR(10);

    SET @DIEM_tb = dbo.fn_DiemTrungBinhDeTai(@MSDT);

    IF @DIEM_tb >= 5
        SET @ket_qua = 'DAT';
    ELSE
        SET @ket_qua = 'KHONGDAT';

    RETURN @ket_qua;
END;
GO

IF OBJECT_ID('fn_SinhVienThucHienDeTai', 'IF') IS NOT NULL
    DROP FUNCTION fn_SinhVienThucHienDeTai;
GO

CREATE FUNCTION fn_SinhVienThucHienDeTai (@MSDT CHAR(6))
RETURNS TABLE
AS
RETURN
(
    SELECT sv.MSSV, sv.TENSV
    FROM SINHVIEN sv
    JOIN SV_DETAI svdt ON sv.MSSV = svdt.MSSV
    WHERE svdt.MSDT = @MSDT
);
GO

IF OBJECT_ID('fn_XepLoaiDeTai', 'FN') IS NOT NULL
    DROP FUNCTION fn_XepLoaiDeTai;
GO

CREATE FUNCTION fn_XepLoaiDeTai (@DIEM_tb FLOAT)
RETURNS NVARCHAR(20)
AS
BEGIN
    IF @DIEM_tb >= 9
        RETURN N'Xuất sắc';
    
    IF @DIEM_tb >= 8
        RETURN N'Giỏi';
        
    IF @DIEM_tb >= 7
        RETURN N'Khá';
        
    IF @DIEM_tb >= 6
        RETURN N'Trung bình khá';
        
    IF @DIEM_tb >= 5
        RETURN N'Trung bình';
        
    IF @DIEM_tb >= 4
        RETURN N'Yếu';
        
    RETURN N'Kém';
END;
GO
