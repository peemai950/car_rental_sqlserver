-- ขั้นที่ 1: สร้างฐานข้อมูล
USE master; -- ใช้ฐานข้อมูลระบบก่อนสร้างฐานข้อมูลใหม่
GO -- จบชุดคำสั่งและส่งให้ SQL Server ประมวลผล
IF DB_ID(N'car_rental_mini_project') IS NULL -- ตรวจว่าฐานข้อมูลยังไม่มี
    EXEC(N'CREATE DATABASE car_rental_mini_project'); -- สร้างฐานข้อมูลเมื่อยังไม่มี
GO -- จบขั้นสร้างฐานข้อมูล

-- ขั้นที่ 2: เลือกฐานข้อมูลสำหรับสร้างตาราง
USE car_rental_mini_project; -- เปลี่ยนมาทำงานในฐานข้อมูลระบบเช่ารถ
GO -- ยืนยันฐานข้อมูลก่อนสร้างตาราง

-- ขั้นที่ 3: สร้างตาราง customer (ลูกค้าและผู้ขับขี่)
IF OBJECT_ID(N'dbo.customer', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.customer ( -- กำหนดตารางและรายละเอียดฟิลด์
        customer_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการลูกค้าและผู้ขับขี่; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        full_name NVARCHAR(200) NOT NULL, -- ชื่อและนามสกุล; ต้องมีค่า
        birth_date DATE NULL, -- วันเกิด ใช้ตรวจเกณฑ์อายุ; เว้นว่างเป็น NULL ได้
        identity_document_no NVARCHAR(50) NULL, -- เลขเอกสารระบุตัวตน; เว้นว่างเป็น NULL ได้
        phone NVARCHAR(30) NOT NULL, -- หมายเลขโทรศัพท์ เก็บเป็นข้อความ; ต้องมีค่า
        email NVARCHAR(254) NULL, -- อีเมลติดต่อ; เว้นว่างเป็น NULL ได้
        license_no NVARCHAR(50) NULL, -- เลขใบขับขี่ปัจจุบัน; เว้นว่างเป็น NULL ได้
        license_expiry_date DATE NULL, -- วันหมดอายุใบขับขี่; เว้นว่างเป็น NULL ได้
        status NVARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- สถานะลูกค้าและผู้ขับขี่; ต้องมีค่า; ใช้ค่าเริ่มต้นเมื่อไม่ได้ระบุฟิลด์นี้
        CHECK(status IN ('ACTIVE','SUSPENDED')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.customer: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 4: สร้างตาราง branch (สาขา)
IF OBJECT_ID(N'dbo.branch', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.branch ( -- กำหนดตารางและรายละเอียดฟิลด์
        branch_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการสาขา; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        branch_name NVARCHAR(150) NOT NULL, -- ชื่อสาขา; ต้องมีค่า
        address NVARCHAR(MAX) NOT NULL, -- ที่อยู่สาขา; ต้องมีค่า
        phone NVARCHAR(30) NULL -- หมายเลขโทรศัพท์ เก็บเป็นข้อความ; เว้นว่างเป็น NULL ได้
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.branch: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 5: สร้างตาราง vehicle_type (ประเภทรถ)
IF OBJECT_ID(N'dbo.vehicle_type', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.vehicle_type ( -- กำหนดตารางและรายละเอียดฟิลด์
        vehicle_type_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการประเภทรถ; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        type_name NVARCHAR(100) NOT NULL, -- ชื่อประเภทรถ; ต้องมีค่า
        seats SMALLINT NOT NULL, -- จำนวนที่นั่ง; ต้องมีค่า
        transmission NVARCHAR(20) NOT NULL, -- ระบบเกียร์; ต้องมีค่า
        default_daily_rate DECIMAL(12,2) NOT NULL, -- ค่าเช่าเริ่มต้นต่อวัน หน่วยบาท; ต้องมีค่า
        CHECK(seats>0), -- ค่าที่กำหนดต้องมากกว่าศูนย์
        CHECK(default_daily_rate>=0), -- ค่าที่กำหนดต้องไม่ติดลบ
        CHECK(transmission IN ('AUTOMATIC','MANUAL')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.vehicle_type: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 6: สร้างตาราง vehicle (รถยนต์)
IF OBJECT_ID(N'dbo.vehicle', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.vehicle ( -- กำหนดตารางและรายละเอียดฟิลด์
        vehicle_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการรถยนต์; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        vehicle_type_id BIGINT NOT NULL, -- รหัสอ้างอิงประเภทรถ; ต้องมีค่า
        current_branch_id BIGINT NOT NULL, -- สาขาที่รับผิดชอบรถปัจจุบัน; ต้องมีค่า
        registration_no NVARCHAR(50) NOT NULL UNIQUE, -- ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน; ค่าห้ามซ้ำ; ต้องมีค่า
        vin NVARCHAR(17) NOT NULL UNIQUE, -- เลขตัวถังรถ; ค่าห้ามซ้ำ; ต้องมีค่า
        brand NVARCHAR(80) NOT NULL, -- ยี่ห้อรถ; ต้องมีค่า
        model NVARCHAR(100) NOT NULL, -- รุ่นรถ; ต้องมีค่า
        model_year SMALLINT NOT NULL, -- ปีรุ่นรถ ใช้ปี ค.ศ.; ต้องมีค่า
        current_mileage INT NOT NULL, -- เลขไมล์ล่าสุด หน่วยกิโลเมตร; ต้องมีค่า
        status NVARCHAR(30) NOT NULL, -- สถานะรถยนต์; ต้องมีค่า
        FOREIGN KEY(vehicle_type_id) REFERENCES dbo.vehicle_type(vehicle_type_id), -- เชื่อม vehicle_type_id กับ vehicle_type.vehicle_type_id ต้องอ้างอิงรายการที่มีอยู่
        FOREIGN KEY(current_branch_id) REFERENCES dbo.branch(branch_id), -- เชื่อม current_branch_id กับ branch.branch_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(current_mileage>=0), -- ค่าที่กำหนดต้องไม่ติดลบ
        CHECK(status IN ('AVAILABLE','RENTED','PENDING_INSPECTION','MAINTENANCE','SUSPENDED')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.vehicle: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 7: สร้างตาราง booking (การจอง)
IF OBJECT_ID(N'dbo.booking', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.booking ( -- กำหนดตารางและรายละเอียดฟิลด์
        booking_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการการจอง; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        booking_no NVARCHAR(30) NOT NULL UNIQUE, -- เลขที่การจองสำหรับแสดงผล; ค่าห้ามซ้ำ; ต้องมีค่า
        customer_id BIGINT NOT NULL, -- รหัสอ้างอิงลูกค้าและผู้ขับขี่; ต้องมีค่า
        vehicle_type_id BIGINT NOT NULL, -- รหัสอ้างอิงประเภทรถ; ต้องมีค่า
        pickup_branch_id BIGINT NOT NULL, -- สาขารับรถ; ต้องมีค่า
        return_branch_id BIGINT NOT NULL, -- สาขาคืนรถ; ต้องมีค่า
        planned_pickup_at DATETIME NOT NULL, -- วันเวลารับรถตามแผน (UTC); ต้องมีค่า
        planned_return_at DATETIME NOT NULL, -- วันเวลาคืนรถตามแผน (UTC); ต้องมีค่า
        hold_expires_at DATETIME NULL, -- วันเวลาหมดอายุการกันสิทธิ์จอง (UTC); เว้นว่างเป็น NULL ได้
        agreed_daily_rate DECIMAL(12,2) NOT NULL, -- ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท; ต้องมีค่า
        status NVARCHAR(30) NOT NULL, -- สถานะการจอง; ต้องมีค่า
        FOREIGN KEY(customer_id) REFERENCES dbo.customer(customer_id), -- เชื่อม customer_id กับ customer.customer_id ต้องอ้างอิงรายการที่มีอยู่
        FOREIGN KEY(vehicle_type_id) REFERENCES dbo.vehicle_type(vehicle_type_id), -- เชื่อม vehicle_type_id กับ vehicle_type.vehicle_type_id ต้องอ้างอิงรายการที่มีอยู่
        FOREIGN KEY(pickup_branch_id) REFERENCES dbo.branch(branch_id), -- เชื่อม pickup_branch_id กับ branch.branch_id ต้องอ้างอิงรายการที่มีอยู่
        FOREIGN KEY(return_branch_id) REFERENCES dbo.branch(branch_id), -- เชื่อม return_branch_id กับ branch.branch_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(planned_return_at>planned_pickup_at), -- เวลาคืนตามแผนต้องหลังเวลารับตามแผน
        CHECK(agreed_daily_rate>=0), -- ค่าที่กำหนดต้องไม่ติดลบ
        CHECK(status IN ('PENDING_PAYMENT','CONFIRMED','PICKED_UP','RETURNED','CLOSED','CANCELLED','EXPIRED','NO_SHOW')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.booking: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 8: สร้างตาราง rental (สัญญาเช่า)
IF OBJECT_ID(N'dbo.rental', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.rental ( -- กำหนดตารางและรายละเอียดฟิลด์
        rental_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการสัญญาเช่าและการจัดสรรรถ; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        rental_no NVARCHAR(30) NOT NULL UNIQUE, -- เลขที่สัญญาเช่า; ค่าห้ามซ้ำ; ต้องมีค่า
        booking_id BIGINT NOT NULL UNIQUE, -- รหัสอ้างอิงการจอง; ค่าห้ามซ้ำ; ต้องมีค่า
        vehicle_id BIGINT NOT NULL, -- รหัสอ้างอิงรถยนต์; ต้องมีค่า
        allocated_from DATETIME NOT NULL, -- เริ่มช่วงเวลาที่กันรถ (UTC); ต้องมีค่า
        allocated_until DATETIME NOT NULL, -- สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC); ต้องมีค่า
        actual_pickup_at DATETIME NULL, -- เวลาส่งมอบรถจริง (UTC); เว้นว่างเป็น NULL ได้
        actual_return_at DATETIME NULL, -- เวลารับรถคืนจริง (UTC); เว้นว่างเป็น NULL ได้
        signed_at DATETIME NULL, -- เวลาลงนามสัญญา (UTC); เว้นว่างเป็น NULL ได้
        status NVARCHAR(30) NOT NULL, -- สถานะสัญญาเช่าและการจัดสรรรถ; ต้องมีค่า
        FOREIGN KEY(booking_id) REFERENCES dbo.booking(booking_id), -- เชื่อม booking_id กับ booking.booking_id ต้องอ้างอิงรายการที่มีอยู่
        FOREIGN KEY(vehicle_id) REFERENCES dbo.vehicle(vehicle_id), -- เชื่อม vehicle_id กับ vehicle.vehicle_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(allocated_until>allocated_from), -- สิ้นสุดช่วงกันรถต้องหลังเวลาเริ่ม
        CHECK(actual_return_at IS NULL OR (actual_pickup_at IS NOT NULL AND actual_return_at>=actual_pickup_at)), -- หากคืนรถแล้ว ต้องมีเวลารับรถ และคืนไม่ก่อนเวลารับ
        CHECK(status IN ('DRAFT','READY','ACTIVE','RETURNED','CLOSED','CANCELLED')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.rental: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 9: สร้างตาราง rental_driver (ผู้ขับขี่ในสัญญา)
IF OBJECT_ID(N'dbo.rental_driver', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.rental_driver ( -- กำหนดตารางและรายละเอียดฟิลด์
        rental_driver_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการผู้ขับขี่ในสัญญา; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        rental_id BIGINT NOT NULL, -- รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ; ต้องมีค่า
        customer_id BIGINT NOT NULL, -- รหัสอ้างอิงลูกค้าและผู้ขับขี่; ต้องมีค่า
        is_primary_driver BIT NOT NULL DEFAULT 0, -- ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่; ต้องมีค่า; ใช้ค่าเริ่มต้นเมื่อไม่ได้ระบุฟิลด์นี้
        license_no_snapshot NVARCHAR(50) NOT NULL, -- เลขใบขับขี่ที่ใช้ในสัญญานี้; ต้องมีค่า
        license_expiry_snapshot DATE NOT NULL, -- วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา; ต้องมีค่า
        verified_at DATETIME NULL, -- เวลาตรวจสอบเอกสาร (UTC); เว้นว่างเป็น NULL ได้
        UNIQUE(rental_id,customer_id), -- ป้องกันผู้ขับขี่คนเดิมซ้ำในสัญญาเดียวกัน
        FOREIGN KEY(rental_id) REFERENCES dbo.rental(rental_id), -- เชื่อม rental_id กับ rental.rental_id ต้องอ้างอิงรายการที่มีอยู่
        FOREIGN KEY(customer_id) REFERENCES dbo.customer(customer_id), -- เชื่อม customer_id กับ customer.customer_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(is_primary_driver IN (0,1)) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.rental_driver: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 10: สร้างตาราง inspection (การตรวจสภาพรถ)
IF OBJECT_ID(N'dbo.inspection', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.inspection ( -- กำหนดตารางและรายละเอียดฟิลด์
        inspection_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการการตรวจสภาพรถ; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        rental_id BIGINT NOT NULL, -- รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ; ต้องมีค่า
        inspection_type NVARCHAR(20) NOT NULL, -- ประเภทการตรวจสภาพ; ต้องมีค่า
        inspected_at DATETIME NOT NULL, -- เวลาตรวจสภาพ (UTC); ต้องมีค่า
        mileage INT NOT NULL, -- เลขไมล์ขณะตรวจ หน่วยกิโลเมตร; ต้องมีค่า
        fuel_or_charge_percent DECIMAL(5,2) NOT NULL, -- ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100; ต้องมีค่า
        notes NVARCHAR(MAX) NULL, -- หมายเหตุ; เว้นว่างเป็น NULL ได้
        FOREIGN KEY(rental_id) REFERENCES dbo.rental(rental_id), -- เชื่อม rental_id กับ rental.rental_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(mileage>=0), -- ค่าที่กำหนดต้องไม่ติดลบ
        CHECK(fuel_or_charge_percent BETWEEN 0 AND 100), -- ระดับน้ำมันหรือแบตเตอรี่ต้องอยู่ในช่วง 0 ถึง 100
        CHECK(inspection_type IN ('PICKUP','RETURN','ADDITIONAL')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.inspection: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 11: สร้างตาราง inspection_item (รายละเอียดการตรวจสภาพ)
IF OBJECT_ID(N'dbo.inspection_item', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.inspection_item ( -- กำหนดตารางและรายละเอียดฟิลด์
        inspection_item_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการรายละเอียดการตรวจสภาพ; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        inspection_id BIGINT NOT NULL, -- รหัสอ้างอิงการตรวจสภาพรถ; ต้องมีค่า
        item_name NVARCHAR(150) NOT NULL, -- จุดตรวจหรืออุปกรณ์; ต้องมีค่า
        [condition] NVARCHAR(30) NOT NULL, -- สภาพจุดตรวจหรืออุปกรณ์; ต้องมีค่า
        photo_url NVARCHAR(MAX) NULL, -- ที่อยู่ไฟล์ภาพหลักฐาน; เว้นว่างเป็น NULL ได้
        notes NVARCHAR(MAX) NULL, -- หมายเหตุ; เว้นว่างเป็น NULL ได้
        FOREIGN KEY(inspection_id) REFERENCES dbo.inspection(inspection_id), -- เชื่อม inspection_id กับ inspection.inspection_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK([condition] IN ('NORMAL','DAMAGED','MISSING')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.inspection_item: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 12: สร้างตาราง maintenance (การซ่อมบำรุง)
IF OBJECT_ID(N'dbo.maintenance', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.maintenance ( -- กำหนดตารางและรายละเอียดฟิลด์
        maintenance_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการงานซ่อมและช่วงปิดใช้งาน; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        vehicle_id BIGINT NOT NULL, -- รหัสอ้างอิงรถยนต์; ต้องมีค่า
        blocked_from DATETIME NOT NULL, -- เริ่มช่วงปิดใช้งานรถ (UTC); ต้องมีค่า
        blocked_until DATETIME NULL, -- สิ้นสุดช่วงปิดใช้งานรถ (UTC); เว้นว่างเป็น NULL ได้
        maintenance_type NVARCHAR(50) NOT NULL, -- ประเภทงานซ่อมหรือบำรุงรักษา; ต้องมีค่า
        cost DECIMAL(12,2) NULL, -- ค่าใช้จ่ายงานซ่อม หน่วยบาท; เว้นว่างเป็น NULL ได้
        status NVARCHAR(20) NOT NULL, -- สถานะงานซ่อมและช่วงปิดใช้งาน; ต้องมีค่า
        FOREIGN KEY(vehicle_id) REFERENCES dbo.vehicle(vehicle_id), -- เชื่อม vehicle_id กับ vehicle.vehicle_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(blocked_until IS NULL OR blocked_until>blocked_from), -- เวลาสิ้นสุดปิดใช้งานต้องหลังเวลาเริ่ม หรือยังไม่ระบุได้
        CHECK(cost IS NULL OR cost>=0), -- ค่าที่กำหนดต้องไม่ติดลบ
        CHECK(status IN ('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.maintenance: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 13: สร้างตาราง charge (ค่าใช้จ่าย)
IF OBJECT_ID(N'dbo.charge', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.charge ( -- กำหนดตารางและรายละเอียดฟิลด์
        charge_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการรายการค่าใช้จ่าย; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        booking_id BIGINT NOT NULL, -- รหัสอ้างอิงการจอง; ต้องมีค่า
        charge_type NVARCHAR(30) NOT NULL, -- ประเภทรายการค่าใช้จ่าย; ต้องมีค่า
        description NVARCHAR(255) NOT NULL, -- รายละเอียดรายการค่าใช้จ่าย; ต้องมีค่า
        quantity DECIMAL(10,2) NOT NULL, -- จำนวนหน่วยสำหรับคิดค่าใช้จ่าย; ต้องมีค่า
        unit_price DECIMAL(12,2) NOT NULL, -- ราคาต่อหน่วย หน่วยบาท; ต้องมีค่า
        amount DECIMAL(12,2) NOT NULL, -- จำนวนเงิน หน่วยบาท; ต้องมีค่า
        status NVARCHAR(20) NOT NULL, -- สถานะรายการค่าใช้จ่าย; ต้องมีค่า
        FOREIGN KEY(booking_id) REFERENCES dbo.booking(booking_id), -- เชื่อม booking_id กับ booking.booking_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(quantity>0), -- ค่าที่กำหนดต้องมากกว่าศูนย์
        CHECK(amount=ROUND(quantity*unit_price,2)), -- ยอดเงินเท่ากับจำนวนหน่วยคูณราคาต่อหน่วย ปัดทศนิยม 2 ตำแหน่ง
        CHECK(charge_type IN ('RENTAL','EXTRA_SERVICE','LATE_RETURN','EXCESS_MILEAGE','FUEL','DAMAGE','DISCOUNT','TAX','OTHER')), -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
        CHECK(status IN ('DRAFT','POSTED','VOID')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.charge: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 14: สร้างตาราง payment (การชำระเงิน)
IF OBJECT_ID(N'dbo.payment', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.payment ( -- กำหนดตารางและรายละเอียดฟิลด์
        payment_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการการรับชำระค่าเช่า; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        booking_id BIGINT NOT NULL, -- รหัสอ้างอิงการจอง; ต้องมีค่า
        amount DECIMAL(12,2) NOT NULL, -- จำนวนเงิน หน่วยบาท; ต้องมีค่า
        payment_method NVARCHAR(30) NOT NULL, -- วิธีชำระเงิน; ต้องมีค่า
        reference_no NVARCHAR(100) NULL, -- เลขอ้างอิงธุรกรรมหรือเอกสาร; เว้นว่างเป็น NULL ได้
        paid_at DATETIME NULL, -- เวลารับชำระสำเร็จ (UTC); เว้นว่างเป็น NULL ได้
        status NVARCHAR(20) NOT NULL, -- สถานะการรับชำระค่าเช่า; ต้องมีค่า
        FOREIGN KEY(booking_id) REFERENCES dbo.booking(booking_id), -- เชื่อม booking_id กับ booking.booking_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(amount>0), -- ค่าที่กำหนดต้องมากกว่าศูนย์
        CHECK(payment_method IN ('CASH','BANK_TRANSFER','CARD','OTHER')), -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
        CHECK(status IN ('PENDING','SUCCESS','FAILED','CANCELLED')), -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
        CHECK(status<>'SUCCESS' OR paid_at IS NOT NULL) -- รายการสำเร็จต้องมีวันเวลาที่สำเร็จด้วย
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.payment: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 15: สร้างตาราง refund (การคืนเงิน)
IF OBJECT_ID(N'dbo.refund', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.refund ( -- กำหนดตารางและรายละเอียดฟิลด์
        refund_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการการคืนเงินค่าเช่า; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        payment_id BIGINT NOT NULL, -- รหัสอ้างอิงการรับชำระค่าเช่า; ต้องมีค่า
        amount DECIMAL(12,2) NOT NULL, -- จำนวนเงิน หน่วยบาท; ต้องมีค่า
        reason NVARCHAR(255) NOT NULL, -- เหตุผลรายการ; ต้องมีค่า
        refunded_at DATETIME NULL, -- เวลาคืนเงินสำเร็จ (UTC); เว้นว่างเป็น NULL ได้
        status NVARCHAR(20) NOT NULL, -- สถานะการคืนเงินค่าเช่า; ต้องมีค่า
        FOREIGN KEY(payment_id) REFERENCES dbo.payment(payment_id), -- เชื่อม payment_id กับ payment.payment_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(amount>0), -- ค่าที่กำหนดต้องมากกว่าศูนย์
        CHECK(status IN ('PENDING','SUCCESS','FAILED','CANCELLED')), -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
        CHECK(status<>'SUCCESS' OR refunded_at IS NOT NULL) -- รายการสำเร็จต้องมีวันเวลาที่สำเร็จด้วย
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.refund: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 16: สร้างตาราง security_deposit (เงินประกันรถ)
IF OBJECT_ID(N'dbo.security_deposit', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.security_deposit ( -- กำหนดตารางและรายละเอียดฟิลด์
        deposit_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการเงินประกันรถ; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        rental_id BIGINT NOT NULL, -- รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ; ต้องมีค่า
        required_amount DECIMAL(12,2) NOT NULL, -- เงินประกันที่ต้องวาง หน่วยบาท; ต้องมีค่า
        status NVARCHAR(20) NOT NULL, -- สถานะเงินประกันรถ; ต้องมีค่า
        FOREIGN KEY(rental_id) REFERENCES dbo.rental(rental_id), -- เชื่อม rental_id กับ rental.rental_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(required_amount>0), -- ค่าที่กำหนดต้องมากกว่าศูนย์
        CHECK(status IN ('PENDING','HELD','PARTIALLY_SETTLED','SETTLED','CANCELLED')) -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.security_deposit: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 17: สร้างตาราง deposit_transaction (ความเคลื่อนไหวเงินประกัน)
IF OBJECT_ID(N'dbo.deposit_transaction', N'U') IS NULL -- สร้างเฉพาะเมื่อตารางนี้ยังไม่มี
BEGIN -- เริ่มบล็อกสร้างตาราง
    CREATE TABLE dbo.deposit_transaction ( -- กำหนดตารางและรายละเอียดฟิลด์
        deposit_transaction_id BIGINT PRIMARY KEY IDENTITY(1,1), -- รหัสรายการความเคลื่อนไหวเงินประกัน; คีย์หลัก ห้ามซ้ำและห้ามว่าง; สร้างรหัสเริ่ม 1 เพิ่มครั้งละ 1
        deposit_id BIGINT NOT NULL, -- รหัสอ้างอิงเงินประกันรถ; ต้องมีค่า
        transaction_type NVARCHAR(20) NOT NULL, -- ประเภทความเคลื่อนไหวเงินประกัน; ต้องมีค่า
        amount DECIMAL(12,2) NOT NULL, -- จำนวนเงิน หน่วยบาท; ต้องมีค่า
        transaction_at DATETIME NOT NULL, -- เวลาธุรกรรมสำเร็จ (UTC); ต้องมีค่า
        reference_no NVARCHAR(100) NULL, -- เลขอ้างอิงธุรกรรมหรือเอกสาร; เว้นว่างเป็น NULL ได้
        reason NVARCHAR(255) NULL, -- เหตุผลรายการ; เว้นว่างเป็น NULL ได้
        FOREIGN KEY(deposit_id) REFERENCES dbo.security_deposit(deposit_id), -- เชื่อม deposit_id กับ security_deposit.deposit_id ต้องอ้างอิงรายการที่มีอยู่
        CHECK(amount>0), -- ค่าที่กำหนดต้องมากกว่าศูนย์
        CHECK(transaction_type IN ('RECEIVE','DEDUCT','RETURN')), -- จำกัดค่าที่บันทึกให้เป็นรายการที่กำหนดในวงเล็บ
        CHECK(transaction_type<>'DEDUCT' OR reason IS NOT NULL) -- การหักเงินประกันต้องระบุเหตุผล
    ); -- ปิดรายละเอียดตาราง
END -- จบบล็อกสร้างตาราง
ELSE -- กรณีตารางมีอยู่แล้ว
    PRINT N'ข้าม dbo.deposit_transaction: มีตารางนี้อยู่แล้ว'; -- แจ้งผลโดยไม่แก้ข้อมูลเดิม
GO -- จบขั้นนี้ ก่อนสร้างตารางถัดไป

-- ขั้นที่ 18: ป้องกันผู้ขับขี่หลักมากกว่าหนึ่งคนต่อสัญญา
IF NOT EXISTS ( -- ตรวจว่าดัชนีนี้ยังไม่มี
    SELECT 1 FROM sys.indexes -- อ่านรายการดัชนีในฐานข้อมูล
    WHERE object_id = OBJECT_ID(N'dbo.rental_driver') -- ตรวจเฉพาะตารางผู้ขับขี่
      AND name = N'UX_primary_driver' -- ตรวจชื่อดัชนีที่ต้องการสร้าง
) -- จบเงื่อนไขตรวจดัชนี
BEGIN -- เริ่มสร้างดัชนี
    CREATE UNIQUE INDEX UX_primary_driver -- สร้างดัชนีที่ห้ามค่าซ้ำ
    ON dbo.rental_driver(rental_id) -- ห้าม rental_id ซ้ำเฉพาะแถวที่เข้าเงื่อนไข
    WHERE is_primary_driver = 1; -- ตรวจเฉพาะผู้ขับขี่หลัก
END -- จบบล็อกสร้างดัชนี
ELSE -- กรณีมีดัชนีนี้อยู่แล้ว
    PRINT N'ข้าม UX_primary_driver: มีดัชนีอยู่แล้ว'; -- คงดัชนีเดิมไว้
GO -- จบขั้นสร้างดัชนี
-- ดัชนีนี้บังคับได้ไม่เกินหนึ่งคน ระบบต้องตรวจว่ามีหนึ่งคนก่อนส่งมอบรถด้วย

-- ขั้นที่ 19: ตรวจรายชื่อตารางที่สร้างไว้
SELECT name AS table_name -- แสดงชื่อของแต่ละตาราง
FROM sys.tables -- อ่านข้อมูลตารางในฐานข้อมูลปัจจุบัน
WHERE schema_id = SCHEMA_ID(N'dbo') -- เลือกตารางใน schema dbo
  AND is_ms_shipped = 0 -- ไม่แสดงตารางระบบ
ORDER BY name; -- เรียงชื่อตารางตามตัวอักษร
GO -- จบชุดคำสั่งตรวจสอบ
