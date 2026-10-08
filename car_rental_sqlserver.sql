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

-- ส่วนที่ 2: เพิ่มข้อมูลตัวอย่างครอบคลุมทุกสถานะและประเภทที่แบบรองรับ
-- 06_InsertExampleData.sql: ตัวอย่างครอบคลุมสถานะและประเภทข้อมูลของระบบเช่ารถ
-- สำหรับ SQL Server ไม่มี GO มีคำอธิบายแต่ละบรรทัด และต้องรันทั้งไฟล์พร้อมกัน
-- เพิ่มการจองใหม่ 100 รายการ พร้อมข้อมูลที่เกี่ยวข้องครบทั้ง 15 ตาราง
-- ใช้ได้ทั้งฐานข้อมูลใหม่ที่มีตารางแล้วและฐานข้อมูลเดิม ไม่ลบหรือแก้ข้อมูลเดิม
-- ชุดนี้ใช้เลขที่จอง DEMO-ALL-001 ถึง DEMO-ALL-100 หากเคยเพิ่มแล้วจะหยุดเพื่อไม่ให้ซ้ำ
-- ใช้ SCOPE_IDENTITY เก็บรหัสจริง จึงไม่จำเป็นต้องเริ่มรหัสที่ 1
-- ข้อมูลจำลอง ณ วันที่ 4 ตุลาคม 2026 เก็บเวลา UTC และจำนวนเงินเป็นบาท
-- หากฐานข้อมูลเดิมมี 100 การจอง รันชุดนี้สำเร็จจะมี 200 การจอง หรือมากกว่าหากเคยเพิ่มเอง
-- 07_TestQuery เดิมอ้างอิงชุดแรก: จำนวนจะเพิ่มและรายการยังดำเนินงานอาจมียอดค้างตามปกติ
-- ครอบคลุมสถานะที่ CHECK อนุญาต ประเภทค่าใช้จ่าย เกียร์ วิธีชำระ สภาพรถ และธุรกรรมประกัน
-- ไม่ครอบคลุมฟีเจอร์ที่ไม่มีในแบบ เช่น ประกันภัยหรือการเปลี่ยนรถระหว่างสัญญา

-- ขั้นที่ 1: เลือกฐานข้อมูลและตั้งค่าการทำงาน
USE car_rental_mini_project; -- ใช้ฐานข้อมูลที่สร้างตารางด้วย 05_CreateDatabase.sql แล้ว
SET NOCOUNT ON; -- ซ่อนข้อความจำนวนแถวของ INSERT แต่ละรายการ
SET XACT_ABORT ON; -- เมื่อคำสั่งผิดพลาดให้ยกเลิก Transaction
BEGIN TRY -- เริ่มบล็อกที่จับข้อผิดพลาดได้
BEGIN TRANSACTION; -- เพิ่มชุดข้อมูลทั้งหมดเป็นหน่วยเดียว ย้อนกลับได้หากไม่สำเร็จ
IF EXISTS (SELECT 1 FROM dbo.booking WITH (UPDLOCK, HOLDLOCK) WHERE booking_no LIKE N'DEMO-ALL-%') -- ตรวจชุดตัวอย่างนี้และล็อกการตรวจจนจบ Transaction
    THROW 50003, 'DEMO-ALL sample set already exists. No duplicate data inserted.', 1; -- หยุดหากเคยเพิ่มชุดนี้แล้ว
DECLARE @branch1 BIGINT, @branch2 BIGINT, @branch3 BIGINT; -- รหัสสาขาที่สร้างในชุดนี้
DECLARE @type1 BIGINT, @type2 BIGINT, @type3 BIGINT, @type4 BIGINT, @type5 BIGINT; -- รหัสประเภทรถ
DECLARE @customer BIGINT, @extra_driver BIGINT, @vehicle BIGINT, @booking BIGINT; -- รหัสลูกค้า ผู้ขับเพิ่ม รถ และการจอง
DECLARE @rental BIGINT, @inspection BIGINT, @payment BIGINT, @deposit BIGINT; -- รหัสสัญญา ตรวจสภาพ ชำระเงิน และเงินประกัน

-- ขั้นที่ 2: เพิ่มสาขาและประเภทรถ พร้อมเกียร์อัตโนมัติและเกียร์ธรรมดา
INSERT INTO dbo.branch (branch_name, address, phone) -- ระบุฟิลด์ของตาราง branch
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO ALL กรุงเทพฯ', -- branch_name: ชื่อสาขา
    N'ที่อยู่จำลองสาขา กรุงเทพฯ', -- address: ที่อยู่สาขา
    N'020009001' -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
); -- จบการเพิ่มรายการ
SET @branch1 = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.branch (branch_name, address, phone) -- ระบุฟิลด์ของตาราง branch
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO ALL เชียงใหม่', -- branch_name: ชื่อสาขา
    N'ที่อยู่จำลองสาขา เชียงใหม่', -- address: ที่อยู่สาขา
    N'020009002' -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
); -- จบการเพิ่มรายการ
SET @branch2 = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.branch (branch_name, address, phone) -- ระบุฟิลด์ของตาราง branch
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO ALL ภูเก็ต', -- branch_name: ชื่อสาขา
    N'ที่อยู่จำลองสาขา ภูเก็ต', -- address: ที่อยู่สาขา
    N'020009003' -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
); -- จบการเพิ่มรายการ
SET @branch3 = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle_type (type_name, seats, transmission, default_daily_rate) -- ระบุฟิลด์ของตาราง vehicle_type
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO ALL Eco Car', -- type_name: ชื่อประเภทรถ
    5, -- seats: จำนวนที่นั่ง
    N'AUTOMATIC', -- transmission: ระบบเกียร์
    900 -- default_daily_rate: ค่าเช่าเริ่มต้นต่อวัน หน่วยบาท
); -- จบการเพิ่มรายการ
SET @type1 = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle_type (type_name, seats, transmission, default_daily_rate) -- ระบุฟิลด์ของตาราง vehicle_type
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO ALL Sedan', -- type_name: ชื่อประเภทรถ
    5, -- seats: จำนวนที่นั่ง
    N'AUTOMATIC', -- transmission: ระบบเกียร์
    1200 -- default_daily_rate: ค่าเช่าเริ่มต้นต่อวัน หน่วยบาท
); -- จบการเพิ่มรายการ
SET @type2 = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle_type (type_name, seats, transmission, default_daily_rate) -- ระบุฟิลด์ของตาราง vehicle_type
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO ALL SUV', -- type_name: ชื่อประเภทรถ
    7, -- seats: จำนวนที่นั่ง
    N'AUTOMATIC', -- transmission: ระบบเกียร์
    1800 -- default_daily_rate: ค่าเช่าเริ่มต้นต่อวัน หน่วยบาท
); -- จบการเพิ่มรายการ
SET @type3 = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle_type (type_name, seats, transmission, default_daily_rate) -- ระบุฟิลด์ของตาราง vehicle_type
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO ALL Pickup', -- type_name: ชื่อประเภทรถ
    2, -- seats: จำนวนที่นั่ง
    N'MANUAL', -- transmission: ระบบเกียร์
    1100 -- default_daily_rate: ค่าเช่าเริ่มต้นต่อวัน หน่วยบาท
); -- จบการเพิ่มรายการ
SET @type4 = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle_type (type_name, seats, transmission, default_daily_rate) -- ระบุฟิลด์ของตาราง vehicle_type
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO ALL Van', -- type_name: ชื่อประเภทรถ
    10, -- seats: จำนวนที่นั่ง
    N'AUTOMATIC', -- transmission: ระบบเกียร์
    2200 -- default_daily_rate: ค่าเช่าเริ่มต้นต่อวัน หน่วยบาท
); -- จบการเพิ่มรายการ
SET @type5 = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.001: DEMO-ALL-001 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 001', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-001', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000001', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all1@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-001', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-001 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000001', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20360, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-001', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-01-02T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-05T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-001', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-02T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-01-05T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-01-02T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-01-05T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-01-02T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-001', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-02T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 001', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-001', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000001', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver1@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-001', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-001', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-02T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-02T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20010, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-05T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20360, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-001', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-02T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-01-05T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-02T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-001-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-05T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-001-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.002: DEMO-ALL-002 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 002', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-002', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000002', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all2@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-002', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-002 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000002', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20020, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-002', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-11-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-11-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-002', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'PENDING' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.003: DEMO-ALL-003 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 003', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-003', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000003', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all3@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-003', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-003 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000003', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20030, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-003', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-11-04T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-11-07T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-003', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-11-04T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-11-07T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-11-04T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-003', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-11-04T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-003', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.004: DEMO-ALL-004 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 004', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-004', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000004', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all4@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-004', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-004 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000004', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20040, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-004', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-004', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-004', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 004', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-004', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000004', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver4@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-004', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-004', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20040, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20390, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-004', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-004-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    1000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T04:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-004-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'เงินประกันเพิ่มสำหรับอุปกรณ์เสริม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'DEDUCT', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    200, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T15:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-004-DEDUCT', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าชดเชยอุปกรณ์เสริม ไม่รวมใน CHARGE และไม่เรียกเก็บผ่าน PAYMENT ซ้ำ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.005: DEMO-ALL-005 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 005', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-005', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000005', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all5@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-005', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-005 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000005', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20400, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-005', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-005', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-005', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20050, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20400, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-005', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-005-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-005-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.006: DEMO-ALL-006 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 006', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-006', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000006', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all6@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-006', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-006 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000006', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20060, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-006', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-01-07T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-10T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-006', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-07T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-01-10T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-006', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-05T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    NULL, -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'PENDING' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.007: DEMO-ALL-007 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 007', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-007', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000007', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-007', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-007 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000007', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20070, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-007', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-01-08T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-11T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-007', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.008: DEMO-ALL-008 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 008', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-008', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000008', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all8@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-008', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-008 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000008', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20080, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-008', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-01-09T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-12T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-008', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-09T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.009: DEMO-ALL-009 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 009', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-009', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000009', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all9@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-009', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-009 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000009', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20090, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-009', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-11-10T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-11-13T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-009', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-11-10T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-11-13T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-009', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-009', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.010: DEMO-ALL-010 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 010', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-010', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000010', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all10@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-010', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-010 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000010', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20450, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-010', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-01-11T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-14T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-010', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-11T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-01-14T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-01-11T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-01-14T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-01-11T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-010', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-11T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 010', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-010', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000010', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver10@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-010', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-010', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-11T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-11T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20100, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-14T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20450, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-010', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-11T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-11T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-010-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-14T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-010-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-14T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.011: DEMO-ALL-011 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 011', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-011', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000011', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all11@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-011', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-011 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000011', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20460, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-011', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-01-12T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-15T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-011', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-12T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-01-15T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-01-12T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-01-15T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-01-12T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-011', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-12T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 011', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-011', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000011', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver11@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-011', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-011', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-12T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-12T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20110, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-15T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20460, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-011', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-12T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-01-15T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-12T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-011-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-15T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-011-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.012: DEMO-ALL-012 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 012', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-012', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000012', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all12@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-012', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-012 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000012', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20120, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-012', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-11-13T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-11-16T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-012', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'FAILED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.013: DEMO-ALL-013 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 013', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-013', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000013', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all13@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-013', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-013 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000013', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20130, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-013', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-11-14T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-11-17T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-013', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-11-14T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-11-17T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-11-14T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-013', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-11-14T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-013', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.014: DEMO-ALL-014 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 014', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-014', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000014', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-014', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-014 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000014', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20140, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-014', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-014', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-014', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 014', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-014', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000014', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver14@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-014', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-014', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20140, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20490, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-014', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-014-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.015: DEMO-ALL-015 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 015', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-015', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000015', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all15@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-015', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-015 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000015', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20500, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-015', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-015', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-015', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20150, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20500, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-015', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-015-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-015-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.016: DEMO-ALL-016 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 016', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-016', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000016', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all16@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-016', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-016 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000016', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20160, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-016', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-01-17T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-20T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-016', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-17T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-01-20T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-016', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-15T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    '2026-01-20T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.017: DEMO-ALL-017 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 017', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-017', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000017', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all17@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-017', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-017 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000017', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20170, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-017', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-01-18T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-21T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-017', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.018: DEMO-ALL-018 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 018', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-018', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000018', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all18@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-018', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-018 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000018', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20180, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-018', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-01-19T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-22T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-018', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-19T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.019: DEMO-ALL-019 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 019', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-019', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000019', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all19@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-019', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-019 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000019', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20190, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-019', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-11-20T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-11-23T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-019', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-11-20T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-11-23T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-019', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-019', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.020: DEMO-ALL-020 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 020', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-020', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000020', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all20@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-020', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-020 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000020', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20550, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-020', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-01-21T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-24T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-020', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-21T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-01-24T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-01-21T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-01-24T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-01-21T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-020', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-21T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 020', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-020', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000020', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver20@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-020', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-020', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-21T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-21T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20200, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-24T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20550, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-020', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-21T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-21T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-020-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-24T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-020-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-24T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.021: DEMO-ALL-021 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 021', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-021', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000021', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-021', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-021 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000021', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20560, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-021', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-01-22T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-25T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-021', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-22T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-01-25T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-01-22T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-01-25T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-01-22T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-021', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-22T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 021', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-021', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000021', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver21@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-021', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-021', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-22T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-22T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20210, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-25T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20560, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-021', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-22T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-01-25T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-22T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-021-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-25T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-021-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.022: DEMO-ALL-022 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 022', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-022', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000022', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all22@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-022', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-022 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000022', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20220, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-022', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-11-23T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-11-26T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-022', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.023: DEMO-ALL-023 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 023', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-023', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000023', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all23@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-023', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-023 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000023', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20230, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-023', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-11-24T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-11-27T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-023', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-11-24T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-11-27T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-11-24T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-023', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-11-24T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-023', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.024: DEMO-ALL-024 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 024', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-024', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000024', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all24@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-024', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-024 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000024', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20240, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-024', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-024', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-024', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 024', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-024', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000024', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver24@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-024', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-024', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20240, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20590, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-024', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-024-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    1000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T04:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-024-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'เงินประกันเพิ่มสำหรับอุปกรณ์เสริม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'DEDUCT', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    200, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T15:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-024-DEDUCT', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าชดเชยอุปกรณ์เสริม ไม่รวมใน CHARGE และไม่เรียกเก็บผ่าน PAYMENT ซ้ำ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.025: DEMO-ALL-025 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 025', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-025', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000025', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all25@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-025', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-025 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000025', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20600, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-025', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-025', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-025', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20250, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20600, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-025', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-025-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-025-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.026: DEMO-ALL-026 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 026', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-026', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000026', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all26@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-026', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-026 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000026', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20260, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-026', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-01-27T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-30T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-026', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-27T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-01-30T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-026', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-25T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    NULL, -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'FAILED' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.027: DEMO-ALL-027 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 027', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-027', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000027', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all27@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-027', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-027 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000027', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20270, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-027', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-01-28T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-01-31T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-027', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.028: DEMO-ALL-028 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 028', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-028', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000028', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-028', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-028 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000028', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20280, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-028', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-01-29T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-01T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-028', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-29T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.029: DEMO-ALL-029 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 029', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-029', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000029', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all29@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-029', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-029 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000029', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20290, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-029', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-11-30T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-12-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-029', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-11-30T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-12-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-029', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-029', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.030: DEMO-ALL-030 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 030', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-030', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000030', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all30@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-030', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-030 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000030', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20650, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-030', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-01-31T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-030', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-01-31T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-02-03T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-01-31T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-02-03T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-01-31T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-030', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-31T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 030', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-030', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000030', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver30@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-030', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-030', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-01-31T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-01-31T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20300, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-03T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20650, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-030', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-01-31T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-01-31T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-030-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-03T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-030-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-03T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.031: DEMO-ALL-031 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 031', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-031', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000031', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all31@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-031', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-031 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000031', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20660, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-031', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-02-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-04T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-031', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-02-04T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-02-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-02-04T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-02-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-031', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 031', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-031', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000031', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver31@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-031', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-031', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20310, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-04T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20660, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-031', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-02-04T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-031-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-04T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-031-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.032: DEMO-ALL-032 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 032', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-032', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000032', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all32@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-032', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-032 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000032', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20320, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-032', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-12-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-12-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-032', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'PENDING' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.033: DEMO-ALL-033 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 033', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-033', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000033', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all33@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-033', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-033 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000033', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20330, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-033', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-12-04T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-12-07T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-033', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-12-04T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-12-07T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-12-04T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-033', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-12-04T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-033', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.034: DEMO-ALL-034 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 034', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-034', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000034', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all34@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-034', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-034 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000034', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20340, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-034', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-034', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-034', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 034', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-034', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000034', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver34@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-034', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-034', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20340, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20690, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-034', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-034-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.035: DEMO-ALL-035 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 035', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-035', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000035', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-035', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-035 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000035', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20700, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-035', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-035', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-035', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20350, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20700, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-035', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-035-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-035-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.036: DEMO-ALL-036 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 036', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-036', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000036', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all36@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-036', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-036 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000036', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20360, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-036', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-02-06T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-09T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-036', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-06T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-02-09T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-036', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    NULL, -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.037: DEMO-ALL-037 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 037', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-037', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000037', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all37@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-037', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-037 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000037', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20370, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-037', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-02-07T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-10T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-037', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.038: DEMO-ALL-038 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 038', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-038', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000038', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all38@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-038', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-038 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000038', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20380, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-038', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-02-08T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-11T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-038', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-08T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.039: DEMO-ALL-039 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 039', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-039', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000039', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all39@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-039', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-039 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000039', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20390, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-039', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-12-10T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-12-13T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-039', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-12-10T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-12-13T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-039', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-039', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.040: DEMO-ALL-040 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 040', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-040', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000040', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all40@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-040', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-040 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000040', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20750, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-040', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-02-10T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-13T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-040', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-10T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-02-13T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-02-10T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-02-13T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-02-10T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-040', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-10T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 040', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-040', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000040', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver40@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-040', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-040', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-10T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-10T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20400, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-13T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20750, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-040', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-10T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-10T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-040-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-13T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-040-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-13T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.041: DEMO-ALL-041 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 041', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-041', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000041', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all41@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-041', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-041 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000041', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20760, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-041', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-02-11T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-14T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-041', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-11T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-02-14T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-02-11T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-02-14T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-02-11T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-041', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-11T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 041', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-041', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000041', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver41@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-041', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-041', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-11T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-11T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20410, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-14T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20760, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-041', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-11T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-02-14T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-11T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-041-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-14T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-041-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.042: DEMO-ALL-042 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 042', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-042', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000042', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-042', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-042 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000042', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20420, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-042', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-12-13T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-12-16T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-042', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'FAILED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.043: DEMO-ALL-043 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 043', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-043', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000043', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all43@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-043', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-043 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000043', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20430, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-043', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-12-14T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-12-17T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-043', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-12-14T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-12-17T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-12-14T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-043', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-12-14T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-043', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.044: DEMO-ALL-044 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 044', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-044', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000044', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all44@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-044', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-044 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000044', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20440, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-044', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-044', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-044', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 044', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-044', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000044', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver44@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-044', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-044', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20440, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20790, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-044', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-044-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    1000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T04:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-044-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'เงินประกันเพิ่มสำหรับอุปกรณ์เสริม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'DEDUCT', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    200, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T15:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-044-DEDUCT', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าชดเชยอุปกรณ์เสริม ไม่รวมใน CHARGE และไม่เรียกเก็บผ่าน PAYMENT ซ้ำ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.045: DEMO-ALL-045 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 045', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-045', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000045', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all45@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-045', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-045 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000045', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20800, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-045', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-045', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-045', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20450, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20800, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-045', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-045-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-045-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.046: DEMO-ALL-046 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 046', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-046', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000046', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all46@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-046', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-046 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000046', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20460, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-046', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-02-16T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-19T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-046', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-16T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-02-19T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-046', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-14T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    NULL, -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'PENDING' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.047: DEMO-ALL-047 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 047', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-047', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000047', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all47@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-047', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-047 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000047', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20470, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-047', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-02-17T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-20T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-047', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.048: DEMO-ALL-048 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 048', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-048', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000048', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all48@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-048', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-048 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000048', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20480, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-048', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-02-18T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-21T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-048', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-18T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.049: DEMO-ALL-049 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 049', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-049', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000049', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-049', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-049 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000049', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20490, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-049', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-12-20T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-12-23T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-049', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-12-20T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-12-23T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-049', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-049', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.050: DEMO-ALL-050 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 050', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-050', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000050', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all50@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-050', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-050 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000050', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20850, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-050', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-02-20T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-23T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-050', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-20T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-02-23T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-02-20T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-02-23T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-02-20T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-050', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-20T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 050', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-050', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000050', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver50@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-050', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-050', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-20T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-20T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20500, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-23T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20850, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-050', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-20T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-20T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-050-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-23T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-050-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-23T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.051: DEMO-ALL-051 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 051', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-051', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000051', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all51@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-051', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-051 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000051', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20860, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-051', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-02-21T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-02-24T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-051', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-21T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-02-24T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-02-21T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-02-24T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-02-21T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-051', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-21T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 051', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-051', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000051', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver51@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-051', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-051', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-02-21T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-21T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20510, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-02-24T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20860, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-051', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-21T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-02-24T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-21T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-051-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-02-24T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-051-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.052: DEMO-ALL-052 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 052', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-052', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000052', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all52@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-052', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-052 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000052', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20520, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-052', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-12-23T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-12-26T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-052', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.053: DEMO-ALL-053 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 053', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-053', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000053', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all53@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-053', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-053 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000053', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20530, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-053', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-12-24T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-12-27T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-053', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-12-24T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-12-27T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-12-24T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-053', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-12-24T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-053', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.054: DEMO-ALL-054 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 054', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-054', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000054', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all54@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-054', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-054 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000054', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20540, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-054', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-054', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-054', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 054', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-054', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000054', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver54@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-054', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-054', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20540, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20890, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-054', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-054-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.055: DEMO-ALL-055 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 055', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-055', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000055', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all55@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-055', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-055 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000055', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20900, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-055', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-055', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-055', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20550, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20900, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-055', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-055-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-055-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.056: DEMO-ALL-056 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 056', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-056', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000056', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-056', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-056 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000056', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20560, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-056', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-02-26T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-01T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-056', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-02-26T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-01T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-056', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-24T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    '2026-03-01T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.057: DEMO-ALL-057 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 057', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-057', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000057', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all57@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-057', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-057 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000057', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20570, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-057', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-02-27T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-02T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-057', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.058: DEMO-ALL-058 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 058', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-058', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000058', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all58@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-058', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-058 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000058', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20580, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-058', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-02-28T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-058', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-02-28T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.059: DEMO-ALL-059 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 059', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-059', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000059', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all59@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-059', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-059 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000059', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20590, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-059', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-12-30T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-01-02T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-059', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-12-30T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2027-01-02T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-059', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-059', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.060: DEMO-ALL-060 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 060', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-060', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000060', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all60@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-060', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-060 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000060', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20950, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-060', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-03-02T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-05T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-060', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-02T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-05T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-03-02T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-03-05T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-03-02T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-060', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-02T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 060', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-060', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000060', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver60@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-060', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-060', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-02T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-02T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20600, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-05T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20950, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-060', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-02T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-02T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-060-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-05T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-060-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-05T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.061: DEMO-ALL-061 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 061', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-061', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000061', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all61@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-061', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-061 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000061', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20960, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-061', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-03-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-061', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-03-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-03-06T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-03-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-061', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 061', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-061', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000061', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver61@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-061', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-061', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20610, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-06T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20960, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-061', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-03-06T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-061-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-06T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-061-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.062: DEMO-ALL-062 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 062', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-062', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000062', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all62@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-062', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-062 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000062', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20620, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-062', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2027-01-02T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-01-05T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-062', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'PENDING' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.063: DEMO-ALL-063 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 063', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-063', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000063', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-063', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-063 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000063', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20630, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-063', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2027-01-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-01-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-063', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2027-01-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2027-01-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2027-01-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-063', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2027-01-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-063', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.064: DEMO-ALL-064 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 064', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-064', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000064', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all64@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-064', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-064 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000064', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20640, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-064', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-064', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-064', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 064', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-064', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000064', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver64@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-064', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-064', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20640, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20990, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-064', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-064-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    1000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T04:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-064-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'เงินประกันเพิ่มสำหรับอุปกรณ์เสริม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'DEDUCT', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    200, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T15:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-064-DEDUCT', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าชดเชยอุปกรณ์เสริม ไม่รวมใน CHARGE และไม่เรียกเก็บผ่าน PAYMENT ซ้ำ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.065: DEMO-ALL-065 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 065', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-065', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000065', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all65@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-065', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-065 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000065', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21000, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-065', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-065', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-065', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20650, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21000, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-065', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-065-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-065-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.066: DEMO-ALL-066 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 066', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-066', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000066', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all66@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-066', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-066 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000066', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20660, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-066', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-03-08T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-11T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-066', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-08T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-11T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-066', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-06T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    NULL, -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'FAILED' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.067: DEMO-ALL-067 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 067', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-067', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000067', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all67@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-067', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-067 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000067', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20670, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-067', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-03-09T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-12T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-067', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.068: DEMO-ALL-068 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 068', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-068', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000068', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all68@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-068', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-068 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000068', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20680, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-068', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-03-10T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-13T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-068', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-10T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.069: DEMO-ALL-069 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 069', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-069', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000069', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all69@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-069', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-069 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000069', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20690, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-069', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2027-01-09T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-01-12T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-069', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2027-01-09T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2027-01-12T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-069', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-069', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.070: DEMO-ALL-070 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 070', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-070', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000070', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-070', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-070 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000070', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21050, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-070', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-03-12T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-15T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-070', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-12T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-15T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-03-12T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-03-15T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-03-12T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-070', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-12T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 070', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-070', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000070', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver70@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-070', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-070', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-12T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-12T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20700, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-15T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21050, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CARD', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-070', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-12T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-12T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-070-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-15T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-070-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-15T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.071: DEMO-ALL-071 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 071', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-071', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000071', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all71@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-071', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-071 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000071', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21060, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-071', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-03-13T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-16T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-071', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-13T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-16T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-03-13T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-03-16T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-03-13T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-071', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-13T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 071', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-071', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000071', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver71@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-071', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-071', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-13T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-13T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20710, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-16T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21060, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-071', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-13T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-03-16T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-13T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-071-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-16T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-071-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.072: DEMO-ALL-072 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 072', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-072', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000072', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all72@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-072', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-072 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000072', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20720, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-072', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2027-01-12T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-01-15T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-072', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'FAILED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.073: DEMO-ALL-073 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 073', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-073', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000073', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all73@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-073', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-073 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000073', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20730, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-073', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2027-01-13T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-01-16T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-073', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2027-01-13T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2027-01-16T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2027-01-13T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-073', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2027-01-13T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-073', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.074: DEMO-ALL-074 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 074', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-074', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000074', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all74@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-074', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-074 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000074', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20740, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-074', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-074', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-074', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 074', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-074', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000074', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver74@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-074', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-074', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20740, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21090, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-074', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-074-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.075: DEMO-ALL-075 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 075', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-075', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000075', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all75@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-075', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-075 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000075', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21100, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-075', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-075', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-075', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20750, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21100, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-075', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-075-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-075-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.076: DEMO-ALL-076 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 076', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-076', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000076', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all76@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-076', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-076 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000076', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20760, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-076', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-03-18T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-21T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-076', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-18T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-21T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-076', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-16T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    NULL, -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.077: DEMO-ALL-077 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 077', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-077', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000077', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-077', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-077 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000077', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20770, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-077', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-03-19T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-22T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-077', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.078: DEMO-ALL-078 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 078', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-078', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000078', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all78@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-078', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-078 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000078', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20780, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-078', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-03-20T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-23T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-078', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-20T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.079: DEMO-ALL-079 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 079', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-079', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000079', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all79@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-079', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-079 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000079', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20790, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-079', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2027-01-19T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-01-22T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-079', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2027-01-19T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2027-01-22T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-079', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-079', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.080: DEMO-ALL-080 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 080', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-080', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000080', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all80@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-080', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-080 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000080', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21150, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-080', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-03-22T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-25T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-080', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-22T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-25T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-03-22T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-03-25T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-03-22T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-080', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-22T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 080', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-080', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000080', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver80@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-080', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-080', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-22T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-22T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20800, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-25T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21150, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'OTHER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-080', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-22T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-22T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-080-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-25T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-080-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-25T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.081: DEMO-ALL-081 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 081', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-081', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000081', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all81@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-081', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-081 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000081', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21160, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-081', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-03-23T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-26T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-081', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-23T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-26T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-03-23T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-03-26T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-03-23T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-081', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-23T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 081', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-081', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000081', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver81@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-081', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-081', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-03-23T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-23T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20810, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-03-26T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21160, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-081', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-23T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-03-26T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-23T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-081-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-03-26T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-081-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.082: DEMO-ALL-082 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 082', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-082', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000082', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all82@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-082', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-082 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000082', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20820, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-082', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2027-01-22T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-01-25T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-082', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.083: DEMO-ALL-083 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 083', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-083', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000083', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all83@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-083', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-083 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000083', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20830, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-083', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2027-01-23T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-01-26T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-083', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2027-01-23T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2027-01-26T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2027-01-23T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-083', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2027-01-23T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-083', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.084: DEMO-ALL-084 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 084', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-084', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000084', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-084', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-084 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000084', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20840, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-084', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-084', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-084', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 084', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-084', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000084', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver84@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-084', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-084', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20840, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21190, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-084', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-084-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    1000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T04:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-084-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'เงินประกันเพิ่มสำหรับอุปกรณ์เสริม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'DEDUCT', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    200, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T15:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-084-DEDUCT', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าชดเชยอุปกรณ์เสริม ไม่รวมใน CHARGE และไม่เรียกเก็บผ่าน PAYMENT ซ้ำ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.085: DEMO-ALL-085 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 085', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-085', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000085', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all85@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-085', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-085 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000085', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21200, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-085', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-085', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-085', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20850, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21200, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-085', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-085-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-085-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.086: DEMO-ALL-086 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 086', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-086', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000086', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all86@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-086', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-086 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000086', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20860, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-086', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-03-28T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-03-31T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-086', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-03-28T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-03-31T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-086', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-26T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    NULL, -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'PENDING' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.087: DEMO-ALL-087 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 087', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-087', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000087', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all87@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-087', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-087 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000087', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20870, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-087', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-03-29T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-04-01T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-087', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.088: DEMO-ALL-088 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 088', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-088', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000088', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all88@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-088', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-088 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000088', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20880, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-088', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-03-30T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-04-02T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-088', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-03-30T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.089: DEMO-ALL-089 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 089', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-089', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000089', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all89@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-089', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-089 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000089', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20890, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-089', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2027-01-29T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-02-01T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-089', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2027-01-29T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2027-02-01T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-089', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-089', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.090: DEMO-ALL-090 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 090', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-090', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000090', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all90@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-090', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-090 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000090', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21250, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-090', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-04-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-04-04T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-090', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-04-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-04-04T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-04-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-04-04T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-04-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-090', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-04-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 090', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-090', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000090', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver90@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-090', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-090', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-04-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-04-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20900, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-04-04T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21250, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'CASH', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-090', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-04-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-04-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-090-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-04-04T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-090-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-04-04T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.091: DEMO-ALL-091 — ปิดสัญญาปกติ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 091', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-091', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000091', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-091', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-091 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000091', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21260, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-091', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-04-02T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-04-05T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-091', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-04-02T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-04-05T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-04-02T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-04-05T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-04-02T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-091', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-04-02T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 091', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-091', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000091', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver91@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-091', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-091', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-04-02T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-04-02T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20910, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-04-05T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21260, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    900, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    2700, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    196.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    196.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3096.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-091', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-04-02T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนยอดชำระเกิน', -- reason: เหตุผลรายการ
    '2026-04-05T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-04-02T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-091-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-04-05T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-091-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนเต็มจำนวนหลังตรวจรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.092: DEMO-ALL-092 — จองรอชำระเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 092', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-092', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000092', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all92@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-092', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-092 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000092', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20920, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-092', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2027-02-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-02-04T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-10-04T14:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PENDING_PAYMENT' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'DRAFT' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-092', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'PENDING' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.093: DEMO-ALL-093 — ยืนยันและเตรียมรับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 093', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-093', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000093', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all93@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-093', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-093 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000093', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20930, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-093', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2027-02-02T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-02-05T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-093', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2027-02-02T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2027-02-05T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2027-02-02T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'READY' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-093', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2027-02-02T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1800, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    5400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    378.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    378.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-093', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.094: DEMO-ALL-094 — รับรถแล้ว กำลังเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 094', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-094', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000094', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all94@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-094', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-094 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000094', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20940, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'RENTED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-094', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-10-03T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-06T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'PICKED_UP' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-094', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-03T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-06T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-03T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-03T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'ACTIVE' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-094', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 094', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-094', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000094', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver94@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-094', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-094', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-03T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20940, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'ADDITIONAL', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T15:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21290, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    75, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง ADDITIONAL' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    238.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    238.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    3638.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-094', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-03T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'HELD' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-094-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.095: DEMO-ALL-095 — คืนรถแล้ว รอปิดยอด
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 095', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-095', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000095', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all95@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-095', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-095 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000095', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21300, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'PENDING_INSPECTION' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-095', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-10-01T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-10-03T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'RETURNED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-095', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-01T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-10-03T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-10-01T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-10-03T03:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-10-01T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'RETURNED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-095', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-10-01T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-01T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    20950, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-10-03T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21300, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    2, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    4400, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    315.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    315.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    4615.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-095', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-01T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PARTIALLY_SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-01T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-095-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    1000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-10-03T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-095-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'คืนบางส่วน 1,000 บาท รอปิดยอดและคืนส่วนที่เหลือ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ

-- ขั้นที่ 3.096: DEMO-ALL-096 — ยกเลิกการจองและคืนเงิน
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 096', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-096', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000096', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all96@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-096', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-096 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000096', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20960, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-096', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2026-04-07T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-04-10T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    900, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CANCELLED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-096', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-04-07T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-04-10T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CANCELLED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมยกเลิก', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-096', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-04-05T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.refund (payment_id, amount, reason, refunded_at, status) -- ระบุฟิลด์ของตาราง refund
VALUES ( -- เริ่มค่าข้อมูล 
    @payment, -- payment_id: รหัสอ้างอิงการรับชำระค่าเช่า
    100, -- amount: จำนวนเงิน หน่วยบาท
    N'คืนหลังยกเลิก หักค่าธรรมเนียม 200 บาท', -- reason: เหตุผลรายการ
    '2026-04-10T03:00:00', -- refunded_at: เวลาคืนเงินสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการคืนเงินค่าเช่า
); -- จบการเพิ่มรายการ
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'CANCELLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.097: DEMO-ALL-097 — การกันสิทธิ์จองหมดอายุ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 097', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-097', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000097', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all97@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-097', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-097 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000097', -- vin: เลขตัวถังรถ
    N'Honda', -- brand: ยี่ห้อรถ
    N'City', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20970, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-097', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type2, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch1, -- return_branch_id: สาขาคืนรถ
    '2026-04-08T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-04-11T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    '2026-09-01T03:00:00', -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'EXPIRED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่าที่ยกเลิกเพราะสิทธิ์จองหมดอายุ', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3600, -- amount: จำนวนเงิน หน่วยบาท
    N'VOID' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-097', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    NULL, -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'CANCELLED' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.098: DEMO-ALL-098 — ไม่มารับรถ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 098', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-098', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000098', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-098', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-098 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000098', -- vin: เลขตัวถังรถ
    N'Nissan', -- brand: ยี่ห้อรถ
    N'X-Trail', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20980, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-098', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type3, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-04-09T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-04-12T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1800, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'NO_SHOW' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าธรรมเนียมไม่มารับรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-098', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-04-09T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.099: DEMO-ALL-099 — ยืนยันแล้ว กำลังเตรียมสัญญา
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 099', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-099', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000099', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all99@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-099', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-099 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000099', -- vin: เลขตัวถังรถ
    N'Isuzu', -- brand: ยี่ห้อรถ
    N'D-Max', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    20990, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-099', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type4, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch3, -- pickup_branch_id: สาขารับรถ
    @branch3, -- return_branch_id: สาขาคืนรถ
    '2027-02-08T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2027-02-11T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    1100, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CONFIRMED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-099', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2027-02-08T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2027-02-11T05:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    NULL, -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    NULL, -- actual_return_at: เวลารับรถคืนจริง (UTC)
    NULL, -- signed_at: เวลาลงนามสัญญา (UTC)
    N'DRAFT' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-099', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    NULL -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    3300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    231.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    231.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-099', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-10-04T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'PENDING' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป

-- ขั้นที่ 3.100: DEMO-ALL-100 — คืนช้า เกินระยะทาง และมีความเสียหาย
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าจำลองครบกรณี 100', -- full_name: ชื่อและนามสกุล
    N'1990-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-ID-100', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0890000100', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'all100@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-LIC-100', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch2, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-100 กรุงเทพฯ', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOALL0000000100', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Commuter', -- model: รุ่นรถ
    2024, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    21350, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.booking (booking_no, customer_id, vehicle_type_id, pickup_branch_id, return_branch_id, planned_pickup_at, planned_return_at, hold_expires_at, agreed_daily_rate, status) -- ระบุฟิลด์ของตาราง booking
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-100', -- booking_no: เลขที่การจองสำหรับแสดงผล
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    @type5, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- pickup_branch_id: สาขารับรถ
    @branch2, -- return_branch_id: สาขาคืนรถ
    '2026-04-11T03:00:00', -- planned_pickup_at: วันเวลารับรถตามแผน (UTC)
    '2026-04-14T03:00:00', -- planned_return_at: วันเวลาคืนรถตามแผน (UTC)
    NULL, -- hold_expires_at: วันเวลาหมดอายุการกันสิทธิ์จอง (UTC)
    2200, -- agreed_daily_rate: ค่าเช่าต่อวันที่ตกลงไว้ หน่วยบาท
    N'CLOSED' -- status: สถานะการจอง
); -- จบการเพิ่มรายการ
SET @booking = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental (rental_no, booking_id, vehicle_id, allocated_from, allocated_until, actual_pickup_at, actual_return_at, signed_at, status) -- ระบุฟิลด์ของตาราง rental
VALUES ( -- เริ่มค่าข้อมูล 
    N'DEMO-ALL-RT-100', -- rental_no: เลขที่สัญญาเช่า
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-04-11T03:00:00', -- allocated_from: เริ่มช่วงเวลาที่กันรถ (UTC)
    '2026-04-14T08:00:00', -- allocated_until: สิ้นสุดช่วงกันรถ รวมเวลาเตรียมรถ (UTC)
    '2026-04-11T03:00:00', -- actual_pickup_at: เวลาส่งมอบรถจริง (UTC)
    '2026-04-14T06:00:00', -- actual_return_at: เวลารับรถคืนจริง (UTC)
    '2026-04-11T02:45:00', -- signed_at: เวลาลงนามสัญญา (UTC)
    N'CLOSED' -- status: สถานะสัญญาเช่าและการจัดสรรรถ
); -- จบการเพิ่มรายการ
SET @rental = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @customer, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    1, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-LIC-100', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-04-11T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ผู้ขับเพิ่ม 100', -- full_name: ชื่อและนามสกุล
    N'1992-05-10', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-EX-100', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0880000100', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    N'driver100@example.com', -- email: อีเมลติดต่อ
    N'DEMO-ALL-EXLIC-100', -- license_no: เลขใบขับขี่ปัจจุบัน
    N'2030-12-31', -- license_expiry_date: วันหมดอายุใบขับขี่
    N'ACTIVE' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @extra_driver = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.rental_driver (rental_id, customer_id, is_primary_driver, license_no_snapshot, license_expiry_snapshot, verified_at) -- ระบุฟิลด์ของตาราง rental_driver
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    @extra_driver, -- customer_id: รหัสอ้างอิงลูกค้าและผู้ขับขี่
    0, -- is_primary_driver: ผู้ขับขี่หลัก: 1 ใช่ / 0 ไม่ใช่
    N'DEMO-ALL-EXLIC-100', -- license_no_snapshot: เลขใบขับขี่ที่ใช้ในสัญญานี้
    N'2030-12-31', -- license_expiry_snapshot: วันหมดอายุใบขับขี่ ณ เวลาทำสัญญา
    '2026-04-11T02:30:00' -- verified_at: เวลาตรวจสอบเอกสาร (UTC)
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'PICKUP', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-04-11T03:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21000, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    100, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง PICKUP' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'สภาพปกติ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'NORMAL', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ครบ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection (rental_id, inspection_type, inspected_at, mileage, fuel_or_charge_percent, notes) -- ระบุฟิลด์ของตาราง inspection
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    N'RETURN', -- inspection_type: ประเภทการตรวจสภาพ
    '2026-04-14T06:00:00', -- inspected_at: เวลาตรวจสภาพ (UTC)
    21350, -- mileage: เลขไมล์ขณะตรวจ หน่วยกิโลเมตร
    65, -- fuel_or_charge_percent: ระดับน้ำมันหรือแบตเตอรี่ ร้อยละ 0–100
    N'ตรวจสภาพจำลอง RETURN' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
SET @inspection = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กันชนหน้า', -- item_name: จุดตรวจหรืออุปกรณ์
    N'DAMAGED', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'รอยใหม่ตอนคืนรถ' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.inspection_item (inspection_id, item_name, [condition], photo_url, notes) -- ระบุฟิลด์ของตาราง inspection_item
VALUES ( -- เริ่มค่าข้อมูล 
    @inspection, -- inspection_id: รหัสอ้างอิงการตรวจสภาพรถ
    N'กุญแจสำรอง', -- item_name: จุดตรวจหรืออุปกรณ์
    N'MISSING', -- condition: สภาพจุดตรวจหรืออุปกรณ์
    NULL, -- photo_url: ที่อยู่ไฟล์ภาพหลักฐาน
    N'ไม่พบกุญแจสำรองตอนคืน' -- notes: หมายเหตุ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'RENTAL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าเช่ารายวัน', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    2200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    6600, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXTRA_SERVICE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ผู้ขับเพิ่มหรือบริการเสริม', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    200, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    200, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DISCOUNT', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ส่วนลดค่าบริการ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    -100, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    -100, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'LATE_RETURN', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนช้า 3 ชั่วโมง', -- description: รายละเอียดรายการค่าใช้จ่าย
    3, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    150, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    450, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'EXCESS_MILEAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าระยะทางส่วนเกิน 50 กิโลเมตร', -- description: รายละเอียดรายการค่าใช้จ่าย
    50, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    5, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    250, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'FUEL', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าชดเชยน้ำมันตอนคืนรถ', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    500, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    500, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'DAMAGE', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าความเสียหายและอุปกรณ์สูญหาย รวมเรียกเก็บครั้งเดียว', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    1000, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    1000, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'OTHER', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ค่าคืนต่างสาขา', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    300, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    300, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.charge (booking_id, charge_type, description, quantity, unit_price, amount, status) -- ระบุฟิลด์ของตาราง charge
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    N'TAX', -- charge_type: ประเภทรายการค่าใช้จ่าย
    N'ภาษีสมมติ 7% เพื่อสาธิตการคำนวณ ไม่ใช่ข้อสรุปภาษีธุรกิจจริง', -- description: รายละเอียดรายการค่าใช้จ่าย
    1, -- quantity: จำนวนหน่วยสำหรับคิดค่าใช้จ่าย
    644.00, -- unit_price: ราคาต่อหน่วย หน่วยบาท
    644.00, -- amount: จำนวนเงิน หน่วยบาท
    N'POSTED' -- status: สถานะรายการค่าใช้จ่าย
); -- จบการเพิ่มรายการ
INSERT INTO dbo.payment (booking_id, amount, payment_method, reference_no, paid_at, status) -- ระบุฟิลด์ของตาราง payment
VALUES ( -- เริ่มค่าข้อมูล 
    @booking, -- booking_id: รหัสอ้างอิงการจอง
    9844.00, -- amount: จำนวนเงิน หน่วยบาท
    N'BANK_TRANSFER', -- payment_method: วิธีชำระเงิน
    N'DEMO-ALL-PAY-100', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    '2026-04-11T03:00:00', -- paid_at: เวลารับชำระสำเร็จ (UTC)
    N'SUCCESS' -- status: สถานะการรับชำระค่าเช่า
); -- จบการเพิ่มรายการ
SET @payment = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.security_deposit (rental_id, required_amount, status) -- ระบุฟิลด์ของตาราง security_deposit
VALUES ( -- เริ่มค่าข้อมูล 
    @rental, -- rental_id: รหัสอ้างอิงสัญญาเช่าและการจัดสรรรถ
    3000, -- required_amount: เงินประกันที่ต้องวาง หน่วยบาท
    N'SETTLED' -- status: สถานะเงินประกันรถ
); -- จบการเพิ่มรายการ
SET @deposit = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RECEIVE', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-04-11T03:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-100-RECEIVE', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'รับเงินประกันก่อนส่งมอบรถ' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.deposit_transaction (deposit_id, transaction_type, amount, transaction_at, reference_no, reason) -- ระบุฟิลด์ของตาราง deposit_transaction
VALUES ( -- เริ่มค่าข้อมูล 
    @deposit, -- deposit_id: รหัสอ้างอิงเงินประกันรถ
    N'RETURN', -- transaction_type: ประเภทความเคลื่อนไหวเงินประกัน
    3000, -- amount: จำนวนเงิน หน่วยบาท
    '2026-04-14T06:00:00', -- transaction_at: เวลาธุรกรรมสำเร็จ (UTC)
    N'DEMO-ALL-DEP-100-RETURN', -- reference_no: เลขอ้างอิงธุรกรรมหรือเอกสาร
    N'ค่าใช้จ่ายชำระผ่าน PAYMENT แล้ว จึงคืนเงินประกันเต็ม' -- reason: เหตุผลรายการ
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-04-14T09:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    NULL, -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ซ่อมความเสียหาย', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'IN_PROGRESS' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 4: เพิ่มลูกค้าระงับสิทธิ์และรถที่ระงับใช้งาน โดยไม่จัดสรรให้การเช่า
INSERT INTO dbo.customer (full_name, birth_date, identity_document_no, phone, email, license_no, license_expiry_date, status) -- ระบุฟิลด์ของตาราง customer
VALUES ( -- เริ่มค่าข้อมูล 
    N'ลูกค้าตัวอย่างระงับสิทธิ์', -- full_name: ชื่อและนามสกุล
    N'1985-01-01', -- birth_date: วันเกิด ใช้ตรวจเกณฑ์อายุ
    N'DEMO-ALL-SUSPENDED', -- identity_document_no: เลขเอกสารระบุตัวตน
    N'0899999999', -- phone: หมายเลขโทรศัพท์ เก็บเป็นข้อความ
    NULL, -- email: อีเมลติดต่อ
    NULL, -- license_no: เลขใบขับขี่ปัจจุบัน
    NULL, -- license_expiry_date: วันหมดอายุใบขับขี่
    N'SUSPENDED' -- status: สถานะลูกค้าและผู้ขับขี่
); -- จบการเพิ่มรายการ
SET @customer = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-SP-1', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOSPARE00000001', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2023, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    25000, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'SUSPENDED' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-SP-2', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOSPARE00000002', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2023, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    25000, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'MAINTENANCE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-10-04T03:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    '2026-10-05T03:00:00', -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ตรวจระยะตามนัด', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'SCHEDULED' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ
INSERT INTO dbo.vehicle (vehicle_type_id, current_branch_id, registration_no, vin, brand, model, model_year, current_mileage, status) -- ระบุฟิลด์ของตาราง vehicle
VALUES ( -- เริ่มค่าข้อมูล 
    @type1, -- vehicle_type_id: รหัสอ้างอิงประเภทรถ
    @branch1, -- current_branch_id: สาขาที่รับผิดชอบรถปัจจุบัน
    N'DEMO-ALL-SP-3', -- registration_no: ทะเบียนพร้อมจังหวัดหรือเขตจดทะเบียน
    N'DEMOSPARE00000003', -- vin: เลขตัวถังรถ
    N'Toyota', -- brand: ยี่ห้อรถ
    N'Yaris', -- model: รุ่นรถ
    2023, -- model_year: ปีรุ่นรถ ใช้ปี ค.ศ.
    25000, -- current_mileage: เลขไมล์ล่าสุด หน่วยกิโลเมตร
    N'AVAILABLE' -- status: สถานะรถยนต์
); -- จบการเพิ่มรายการ
SET @vehicle = SCOPE_IDENTITY(); -- เก็บรหัสจริงที่เพิ่งสร้าง เพื่อเชื่อมข้อมูลถัดไป
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-09-01T03:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    '2026-09-02T03:00:00', -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'ตรวจระยะเสร็จแล้ว', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    1500, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'COMPLETED' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ
INSERT INTO dbo.maintenance (vehicle_id, blocked_from, blocked_until, maintenance_type, cost, status) -- ระบุฟิลด์ของตาราง maintenance
VALUES ( -- เริ่มค่าข้อมูล 
    @vehicle, -- vehicle_id: รหัสอ้างอิงรถยนต์
    '2026-11-01T03:00:00', -- blocked_from: เริ่มช่วงปิดใช้งานรถ (UTC)
    '2026-11-02T03:00:00', -- blocked_until: สิ้นสุดช่วงปิดใช้งานรถ (UTC)
    N'นัดซ่อมที่ยกเลิก', -- maintenance_type: ประเภทงานซ่อมหรือบำรุงรักษา
    NULL, -- cost: ค่าใช้จ่ายงานซ่อม หน่วยบาท
    N'CANCELLED' -- status: สถานะงานซ่อมและช่วงปิดใช้งาน
); -- จบการเพิ่มรายการ

-- ขั้นที่ 5: ยืนยันข้อมูลและจัดการข้อผิดพลาด
COMMIT TRANSACTION; -- ยืนยันรายการทั้งหมดเมื่อเพิ่มสำเร็จ
END TRY -- จบการทำงานปกติ
BEGIN CATCH -- รับข้อผิดพลาดจาก TRY
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION; -- ย้อนข้อมูลทั้งชุดหากยังมี Transaction
    THROW; -- แสดงสาเหตุข้อผิดพลาดให้ตรวจสอบ
END CATCH; -- จบการจัดการข้อผิดพลาด

-- ขั้นที่ 6: ตรวจสถานะการจองเฉพาะชุดใหม่ CLOSED และ CONFIRMED อย่างละ 20 สถานะอื่นอย่างละ 10
SELECT status, COUNT(*) AS booking_count -- แสดงสถานะและจำนวนการจอง
FROM dbo.booking WHERE booking_no LIKE N'DEMO-ALL-%' -- ตรวจเฉพาะชุดครอบคลุมกรณีนี้
GROUP BY status ORDER BY status; -- รวมและเรียงตามสถานะ
-- CONFIRMED มี 20 รายการ เพราะรวมสัญญา READY และ DRAFT; CLOSED มี 20 รายการ
-- สถานะอื่นมีสถานะละ 10 รายการ รวมทั้งหมด 100 รายการ


-- ส่วนที่ 3: ตรวจสอบข้อมูล
-- 07_TestQuery.sql: ตรวจสอบข้อมูลตัวอย่างระบบเช่ารถ สำหรับ SQL Server
-- ไม่มี GO และอ่านข้อมูลเท่านั้น ไม่เพิ่ม แก้ไข หรือลบข้อมูล
-- รันทั้งหมด หรือเลือกแต่ละขั้นจนถึง ; แล้วกด F5 โดยรันขั้นที่ 1 ก่อน
-- ชุดใหม่มีรายการรอชำระ เงินประกันค้าง และสัญญายกเลิก ผลบางขั้นจึงมีแถวตามสถานการณ์ปกติ

-- ขั้นที่ 1: เลือกฐานข้อมูล
USE car_rental_mini_project; -- ใช้ฐานข้อมูลระบบเช่ารถ

-- ขั้นที่ 2: นับจำนวนแถวทั้ง 15 ตาราง
-- จำนวนแถวขึ้นกับข้อมูลเดิมและชุดตัวอย่างที่เพิ่ม ชุด DEMO-ALL ใหม่มี 1,320 แถวรวมทุกตาราง
SELECT 'branch' AS table_name, COUNT(*) AS row_count FROM dbo.branch -- จำนวนสาขา ฐานข้อมูลใหม่คาดหวัง 3 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'vehicle_type', COUNT(*) FROM dbo.vehicle_type -- จำนวนประเภทรถ ฐานข้อมูลใหม่คาดหวัง 5 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'customer', COUNT(*) FROM dbo.customer -- จำนวนลูกค้า ฐานข้อมูลใหม่คาดหวัง 131 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'vehicle', COUNT(*) FROM dbo.vehicle -- จำนวนรถ ฐานข้อมูลใหม่คาดหวัง 103 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'booking', COUNT(*) FROM dbo.booking -- จำนวนการจอง ฐานข้อมูลใหม่คาดหวัง 100 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'rental', COUNT(*) FROM dbo.rental -- จำนวนสัญญา ฐานข้อมูลใหม่คาดหวัง 70 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'rental_driver', COUNT(*) FROM dbo.rental_driver -- ผู้ขับขี่ในสัญญา ฐานข้อมูลใหม่คาดหวัง 90 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'inspection', COUNT(*) FROM dbo.inspection -- การตรวจสภาพ ฐานข้อมูลใหม่คาดหวัง 80 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'inspection_item', COUNT(*) FROM dbo.inspection_item -- รายละเอียดตรวจ ฐานข้อมูลใหม่คาดหวัง 160 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'maintenance', COUNT(*) FROM dbo.maintenance -- งานซ่อม ฐานข้อมูลใหม่คาดหวัง 13 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'charge', COUNT(*) FROM dbo.charge -- รายการค่าใช้จ่าย ฐานข้อมูลใหม่คาดหวัง 290 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'payment', COUNT(*) FROM dbo.payment -- รายการชำระ ฐานข้อมูลใหม่คาดหวัง 100 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'refund', COUNT(*) FROM dbo.refund -- รายการคืนเงิน ฐานข้อมูลใหม่คาดหวัง 20 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'security_deposit', COUNT(*) FROM dbo.security_deposit -- เงินประกัน ฐานข้อมูลใหม่คาดหวัง 75 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้
UNION ALL SELECT 'deposit_transaction', COUNT(*) FROM dbo.deposit_transaction; -- ความเคลื่อนไหวเงินประกัน ฐานข้อมูลใหม่คาดหวัง 80 แถว; หากมีข้อมูลเดิมจำนวนจะมากกว่านี้

-- ขั้นที่ 3: ตรวจค่าใช้จ่ายเทียบกับเงินรับสุทธิหลังหักเงินคืน
-- แสดงเฉพาะการจองที่ยอดต่างกัน ในงานจริงอาจเป็นยอดค้างปกติของการจองที่ยังไม่ชำระ
SELECT b.booking_id -- แสดงรหัสการจองที่ยอดไม่ตรงกัน
FROM dbo.booking AS b -- ใช้การจองทั้งหมดเป็นข้อมูลตั้งต้น
LEFT JOIN ( -- เชื่อมยอดค่าใช้จ่าย และคงการจองที่ยังไม่มีค่าใช้จ่าย
    SELECT booking_id, SUM(amount) AS total -- รวมยอดค่าใช้จ่ายต่อการจอง
    FROM dbo.charge -- อ่านรายการค่าใช้จ่าย
    WHERE status = 'POSTED' -- นับเฉพาะรายการที่ลงบัญชีแล้ว
    GROUP BY booking_id -- รวมเป็นหนึ่งแถวต่อการจอง
) AS c ON c.booking_id = b.booking_id -- ผูกยอดค่าใช้จ่ายกับการจอง
LEFT JOIN ( -- คำนวณเงินรับสุทธิแยกตามการจอง
    SELECT p.booking_id, SUM(p.amount - COALESCE(f.total, 0)) AS total -- เงินรับลบเงินคืน ถ้าไม่มีเงินคืนให้ใช้ศูนย์
    FROM dbo.payment AS p -- อ่านรายการชำระเงิน
    LEFT JOIN ( -- รวมคืนเงินต่อรายการชำระก่อน เพื่อไม่ให้ยอดรับถูกนับซ้ำ
        SELECT payment_id, SUM(amount) AS total -- รวมเงินคืนตามรายการชำระต้นทาง
        FROM dbo.refund -- อ่านรายการคืนเงิน
        WHERE status = 'SUCCESS' -- นับเฉพาะการคืนสำเร็จ
        GROUP BY payment_id -- รวมเป็นหนึ่งแถวต่อการชำระ
    ) AS f ON f.payment_id = p.payment_id -- เชื่อมยอดคืนกับการชำระ
    WHERE p.status = 'SUCCESS' -- นับเฉพาะการรับเงินสำเร็จ
    GROUP BY p.booking_id -- รวมเป็นหนึ่งแถวต่อการจอง
) AS p ON p.booking_id = b.booking_id -- เชื่อมยอดรับสุทธิกับการจอง
WHERE COALESCE(c.total, 0) <> COALESCE(p.total, 0); -- แสดงเฉพาะยอดต่างกัน

-- ขั้นที่ 4: ตรวจเงินประกันที่ยังมียอดคงเหลือ
-- สูตรยอดรับ - ยอดหัก - ยอดคืน ชุดใหม่มี HELD และ PARTIALLY_SETTLED จึงพบยอดคงเหลือได้
-- ตรวจเฉพาะรายการที่มีธุรกรรม ไม่ครอบคลุมเงินประกันที่ยังไม่มีความเคลื่อนไหว
SELECT deposit_id -- แสดงเงินประกันที่ยอดยังไม่เป็นศูนย์
FROM dbo.deposit_transaction -- อ่านความเคลื่อนไหวเงินประกัน
GROUP BY deposit_id -- รวมรายการของเงินประกันเดียวกัน
HAVING SUM( -- กรองกลุ่มจากยอดคงเหลือ
    CASE WHEN transaction_type = 'RECEIVE' THEN amount -- เงินรับเป็นยอดบวก
         ELSE -amount END -- เงินหักและเงินคืนเป็นยอดลบ
) <> 0; -- แสดงเฉพาะยอดคงเหลือไม่เป็นศูนย์

-- ขั้นที่ 5: ตรวจการจัดสรรรถคันเดียวกันในช่วงเวลาซ้อนกัน
-- ช่วงหนึ่งสิ้นสุดตรงเวลาที่อีกช่วงเริ่มถือว่าไม่ซ้อน
SELECT a.rental_id AS first_rental_id, b.rental_id AS second_rental_id -- แสดงคู่สัญญาที่ซ้อนกัน
FROM dbo.rental AS a -- สัญญารายการแรก
JOIN dbo.rental AS b -- เปรียบเทียบกับสัญญาอื่นในตารางเดียวกัน
    ON a.vehicle_id = b.vehicle_id -- ต้องเป็นรถคันเดียวกัน
   AND a.rental_id < b.rental_id -- ไม่เทียบกับตัวเองและไม่แสดงคู่เดิมซ้ำ
   AND a.allocated_from < b.allocated_until -- สัญญาแรกเริ่มก่อนสัญญาที่สองสิ้นสุด
   AND b.allocated_from < a.allocated_until -- สัญญาที่สองเริ่มก่อนสัญญาแรกสิ้นสุดด้วย
WHERE a.status <> 'CANCELLED' -- ไม่นับสัญญาแรกที่ยกเลิก
  AND b.status <> 'CANCELLED'; -- ไม่นับสัญญาที่สองที่ยกเลิก

-- ขั้นที่ 6: ตรวจว่าผู้ขับขี่หลักมีหนึ่งคนต่อสัญญา
-- สำหรับสัญญาร่างในงานจริง อาจยังไม่มีผู้ขับหลัก ต้องตรวจให้ครบก่อนส่งมอบรถ
SELECT r.rental_id -- แสดงสัญญาที่จำนวนผู้ขับหลักไม่เท่ากับหนึ่ง
FROM dbo.rental AS r -- อ่านสัญญาทั้งหมด
LEFT JOIN dbo.rental_driver AS d ON d.rental_id = r.rental_id -- รวมสัญญาที่ยังไม่มีผู้ขับขี่ด้วย
GROUP BY r.rental_id -- รวมข้อมูลแยกตามสัญญา
HAVING SUM(CASE WHEN d.is_primary_driver = 1 THEN 1 ELSE 0 END) <> 1; -- นับผู้ขับหลักและแสดงจำนวนที่ผิดเงื่อนไข

-- ขั้นที่ 7: ตรวจช่วงเช่าที่ซ้อนกับช่วงปิดซ่อม
-- blocked_until เป็น NULL หมายถึงยังไม่ทราบเวลาสิ้นสุด ใช้เวลาสูงสุดแทนในการเปรียบเทียบ
SELECT r.rental_id, m.maintenance_id -- แสดงคู่สัญญาและงานซ่อมที่เวลาซ้อนกัน
FROM dbo.rental AS r -- อ่านสัญญาเช่า
JOIN dbo.maintenance AS m -- เปรียบเทียบกับงานซ่อมบำรุง
    ON m.vehicle_id = r.vehicle_id -- ตรวจเฉพาะรถคันเดียวกัน
   AND r.allocated_from < COALESCE(m.blocked_until, CONVERT(DATETIME, '9999-12-31T23:59:59', 126)) -- เช่าเริ่มก่อนช่วงปิดซ่อมสิ้นสุด
   AND m.blocked_from < r.allocated_until -- ปิดซ่อมเริ่มก่อนช่วงกันรถสิ้นสุด
WHERE r.status <> 'CANCELLED' -- ไม่นับสัญญาที่ถูกยกเลิก
  AND m.status <> 'CANCELLED'; -- ไม่นับงานซ่อมที่ถูกยกเลิก

-- Query ช่วยตรวจข้อมูล แต่ไม่ป้องกันรายการผิดเงื่อนไขตั้งแต่ตอนบันทึก
-- ระบบใช้งานจริงต้องตรวจความพร้อมรถและยอดเงินใน Transaction เพิ่มเติม

