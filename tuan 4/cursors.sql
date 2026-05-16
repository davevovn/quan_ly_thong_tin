USE qldt;
GO

IF OBJECT_ID('DETAI_DIEM', 'U') IS NULL
BEGIN
    CREATE TABLE DETAI_DIEM (
        MSDT CHAR(6) PRIMARY KEY,
        DIEMTB FLOAT,
        CONSTRAINT FK_DETAI_DIEM_DETAI FOREIGN KEY (MSDT) REFERENCES DETAI(msdt)
    );
END
GO

IF OBJECT_ID('sp_TinhDiemTrungBinhDeTai', 'P') IS NOT NULL
    DROP PROCEDURE sp_TinhDiemTrungBinhDeTai;
GO

CREATE PROCEDURE sp_TinhDiemTrungBinhDeTai
AS
BEGIN
    DECLARE @msdt CHAR(6);
    DECLARE @diem_tb FLOAT;

    DECLARE cur_DeTai CURSOR FOR
        SELECT msdt FROM DETAI;

    OPEN cur_DeTai;
    FETCH NEXT FROM cur_DeTai INTO @msdt;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Sử dụng hàm đã viết để tính điểm trung bình
        SET @diem_tb = dbo.fn_DiemTrungBinhDeTai(@msdt);

        IF EXISTS (SELECT 1 FROM DETAI_DIEM WHERE MSDT = @msdt)
        BEGIN
            UPDATE DETAI_DIEM
            SET DIEMTB = @diem_tb
            WHERE MSDT = @msdt;
        END
        ELSE
        BEGIN
            INSERT INTO DETAI_DIEM (MSDT, DIEMTB)
            VALUES (@msdt, @diem_tb);
        END

        FETCH NEXT FROM cur_DeTai INTO @msdt;
    END

    CLOSE cur_DeTai;
    DEALLOCATE cur_DeTai;
END;
GO

EXEC sp_TinhDiemTrungBinhDeTai;
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('DETAI_DIEM') AND name = 'XEPLOAI'
)
BEGIN
    ALTER TABLE DETAI_DIEM
    ADD XEPLOAI NVARCHAR(20);
END
GO

IF OBJECT_ID('sp_CapNhatXepLoaiDeTai', 'P') IS NOT NULL
    DROP PROCEDURE sp_CapNhatXepLoaiDeTai;
GO

CREATE PROCEDURE sp_CapNhatXepLoaiDeTai
AS
BEGIN
    DECLARE @msdt CHAR(6);
    DECLARE @diem_tb FLOAT;
    DECLARE @xep_loai NVARCHAR(20);

    DECLARE cur_XepLoai CURSOR FOR
        SELECT MSDT, DIEMTB FROM DETAI_DIEM;

    OPEN cur_XepLoai;
    FETCH NEXT FROM cur_XepLoai INTO @msdt, @diem_tb;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Sử dụng function để lấy kết quả xếp loại
        SET @xep_loai = dbo.fn_XepLoaiDeTai(@diem_tb);

        UPDATE DETAI_DIEM
        SET XEPLOAI = @xep_loai
        WHERE MSDT = @msdt;

        FETCH NEXT FROM cur_XepLoai INTO @msdt, @diem_tb;
    END

    CLOSE cur_XepLoai;
    DEALLOCATE cur_XepLoai;
END;
GO

EXEC sp_CapNhatXepLoaiDeTai;
GO

SELECT * FROM DETAI_DIEM;
GO
