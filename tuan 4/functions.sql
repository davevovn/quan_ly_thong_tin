USE qldt;
GO

IF OBJECT_ID('fn_DiemTrungBinhDeTai', 'FN') IS NOT NULL
    DROP FUNCTION fn_DiemTrungBinhDeTai;
GO

CREATE FUNCTION fn_DiemTrungBinhDeTai (@msdt CHAR(6))
RETURNS FLOAT
AS
BEGIN
    DECLARE @diem_tb FLOAT;

    SELECT @diem_tb = AVG(diem)
    FROM (
        SELECT diem FROM gv_hddt WHERE msdt = @msdt
        UNION ALL
        SELECT diem FROM gv_pbdt WHERE msdt = @msdt
        UNION ALL
        SELECT diem FROM gv_uvdt WHERE msdt = @msdt
    ) AS TongHopDiem;

    RETURN ISNULL(@diem_tb, 0);
END;
GO

IF OBJECT_ID('fn_KetQuaDeTai', 'FN') IS NOT NULL
    DROP FUNCTION fn_KetQuaDeTai;
GO

CREATE FUNCTION fn_KetQuaDeTai (@msdt CHAR(6))
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @diem_tb FLOAT;
    DECLARE @ket_qua VARCHAR(10);

    SET @diem_tb = dbo.fn_DiemTrungBinhDeTai(@msdt);

    IF @diem_tb >= 5
        SET @ket_qua = 'DAT';
    ELSE
        SET @ket_qua = 'KHONGDAT';

    RETURN @ket_qua;
END;
GO

IF OBJECT_ID('fn_SinhVienThucHienDeTai', 'IF') IS NOT NULL
    DROP FUNCTION fn_SinhVienThucHienDeTai;
GO

CREATE FUNCTION fn_SinhVienThucHienDeTai (@msdt CHAR(6))
RETURNS TABLE
AS
RETURN
(
    SELECT sv.mssv, sv.tensv
    FROM sinhvien sv
    JOIN sv_detai svdt ON sv.mssv = svdt.mssv
    WHERE svdt.msdt = @msdt
);
GO

IF OBJECT_ID('fn_XepLoaiDeTai', 'FN') IS NOT NULL
    DROP FUNCTION fn_XepLoaiDeTai;
GO

CREATE FUNCTION fn_XepLoaiDeTai (@diem_tb FLOAT)
RETURNS NVARCHAR(20)
AS
BEGIN
    IF @diem_tb >= 9
        RETURN N'Xuất sắc';
    
    IF @diem_tb >= 8
        RETURN N'Giỏi';
        
    IF @diem_tb >= 7
        RETURN N'Khá';
        
    IF @diem_tb >= 6
        RETURN N'Trung bình khá';
        
    IF @diem_tb >= 5
        RETURN N'Trung bình';
        
    IF @diem_tb >= 4
        RETURN N'Yếu';
        
    RETURN N'Kém';
END;
GO
