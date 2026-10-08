-- 11_ViewStatus.sql: ดูสถานะและความหมายข้อมูลระบบเช่ารถ SQL Server
-- อ่านข้อมูลอย่างเดียว ไม่มี GO เลือกรันทีละขั้นหรือรันทั้งหมดได้
-- วันเวลาในผลลัพธ์เป็น UTC บวก 7 ชั่วโมงเมื่อต้องการเทียบเวลาไทย
USE car_rental_mini_project; -- เลือกฐานข้อมูล
SET NOCOUNT ON; -- ลดข้อความจำนวนแถว

-- ขั้นที่ 1: ดูรถแต่ละคันว่าปัจจุบันอยู่สถานะอะไร
SELECT v.vehicle_id, v.registration_no, t.type_name, b.branch_name, v.current_mileage, v.status, -- รหัสรถ ทะเบียน ประเภท สาขาที่รับผิดชอบ เลขไมล์ และสถานะ
    CASE v.status WHEN 'AVAILABLE' THEN N'พร้อมใช้งาน ต้องตรวจช่วงเวลาจองด้วย' WHEN 'RENTED' THEN N'กำลังเช่า' WHEN 'PENDING_INSPECTION' THEN N'รอตรวจสภาพ' WHEN 'MAINTENANCE' THEN N'ซ่อมบำรุง' WHEN 'SUSPENDED' THEN N'ระงับใช้งาน' END AS status_thai -- แปลสถานะรถ
FROM dbo.vehicle AS v -- รถทั้งหมด
JOIN dbo.vehicle_type AS t ON t.vehicle_type_id = v.vehicle_type_id -- เชื่อมประเภทรถ
JOIN dbo.branch AS b ON b.branch_id = v.current_branch_id -- เชื่อมสาขาที่รับผิดชอบ ไม่ใช่ตำแหน่ง GPS
ORDER BY v.vehicle_id; -- เรียงตามรหัสรถ

-- ขั้นที่ 2: ดูการจองแต่ละรายการ พร้อมชื่อลูกค้าและสาขา
SELECT b.booking_id, b.booking_no, c.full_name, t.type_name, p.branch_name AS pickup_branch, q.branch_name AS return_branch, b.planned_pickup_at, b.planned_return_at, b.status, -- ข้อมูลการจอง
    CASE b.status WHEN 'PENDING_PAYMENT' THEN N'รอชำระเงิน' WHEN 'CONFIRMED' THEN N'ยืนยันแล้ว' WHEN 'PICKED_UP' THEN N'รับรถแล้ว' WHEN 'RETURNED' THEN N'คืนรถแล้ว' WHEN 'CLOSED' THEN N'ปิดรายการ' WHEN 'CANCELLED' THEN N'ยกเลิก' WHEN 'EXPIRED' THEN N'สิทธิ์จองหมดอายุ' WHEN 'NO_SHOW' THEN N'ไม่มารับรถ' END AS status_thai -- แปลสถานะการจอง
FROM dbo.booking AS b -- การจองทั้งหมด
JOIN dbo.customer AS c ON c.customer_id = b.customer_id -- ผู้จอง
JOIN dbo.vehicle_type AS t ON t.vehicle_type_id = b.vehicle_type_id -- ประเภทที่จอง
JOIN dbo.branch AS p ON p.branch_id = b.pickup_branch_id -- สาขารับรถ
JOIN dbo.branch AS q ON q.branch_id = b.return_branch_id -- สาขาคืนรถ
ORDER BY b.booking_id DESC; -- รายการล่าสุดก่อน

-- ขั้นที่ 3: ดูสัญญา รถที่จัดสรร และจำนวนผู้ขับขี่
SELECT r.rental_id, r.rental_no, b.booking_no, c.full_name, v.registration_no, r.actual_pickup_at, r.actual_return_at, b.planned_return_at, r.status, -- ข้อมูลสัญญา
    CASE r.status WHEN 'DRAFT' THEN N'ร่างสัญญา' WHEN 'READY' THEN N'พร้อมรับรถ' WHEN 'ACTIVE' THEN N'กำลังเช่า' WHEN 'RETURNED' THEN N'คืนรถแล้ว รอปิดยอด' WHEN 'CLOSED' THEN N'ปิดสัญญา' WHEN 'CANCELLED' THEN N'ยกเลิกสัญญา' END AS status_thai, -- แปลสถานะสัญญา
    (SELECT COUNT(*) FROM dbo.rental_driver AS d WHERE d.rental_id = r.rental_id) AS driver_count, -- นับผู้ขับทั้งหมดโดยไม่ทำให้แถวสัญญาซ้ำ
    CASE WHEN r.status = 'ACTIVE' AND GETUTCDATE() > b.planned_return_at THEN N'เลยกำหนดคืน' ELSE N'ไม่ใช่สัญญากำลังเช่าที่เลยกำหนด' END AS return_alert -- เตือนเฉพาะสัญญาที่ยังเช่าอยู่
FROM dbo.rental AS r -- สัญญาทั้งหมด
JOIN dbo.booking AS b ON b.booking_id = r.booking_id -- การจองต้นทาง
JOIN dbo.customer AS c ON c.customer_id = b.customer_id -- ผู้จอง
JOIN dbo.vehicle AS v ON v.vehicle_id = r.vehicle_id -- รถที่ใช้จริง
ORDER BY r.rental_id DESC; -- ล่าสุดก่อน

-- ขั้นที่ 4: ดูยอดค่าเช่า รับเงิน คืนเงิน และยอดคงค้างแต่ละการจอง
SELECT b.booking_id, b.booking_no, b.status, COALESCE(c.total,0) AS posted_charges, COALESCE(p.total,0) AS successful_payments, COALESCE(f.total,0) AS successful_refunds, -- รวมยอดแต่ละประเภทก่อนเชื่อม เพื่อไม่คูณซ้ำ
    COALESCE(c.total,0) - COALESCE(p.total,0) + COALESCE(f.total,0) AS outstanding_balance, -- ยอดค่าใช้จ่ายลบเงินรับบวกเงินคืน
    CASE WHEN COALESCE(c.total,0) - COALESCE(p.total,0) + COALESCE(f.total,0) > 0 THEN N'มียอดค้างชำระ' WHEN COALESCE(c.total,0) - COALESCE(p.total,0) + COALESCE(f.total,0) < 0 THEN N'รับเงินเกินยอดค่าใช้จ่ายที่ลงบัญชี' ELSE N'ยอดตรงกัน' END AS balance_status -- ไม่ได้แปลว่าปิดสัญญาแล้ว ต้องดูสถานะประกอบ
FROM dbo.booking AS b -- การจองทั้งหมด
LEFT JOIN (SELECT booking_id, SUM(amount) AS total FROM dbo.charge WHERE status='POSTED' GROUP BY booking_id) AS c ON c.booking_id=b.booking_id -- รวมรายการค่าใช้จ่ายที่ลงบัญชี
LEFT JOIN (SELECT booking_id, SUM(amount) AS total FROM dbo.payment WHERE status='SUCCESS' GROUP BY booking_id) AS p ON p.booking_id=b.booking_id -- รวมเงินรับสำเร็จ
LEFT JOIN (SELECT p.booking_id, SUM(f.amount) AS total FROM dbo.refund AS f JOIN dbo.payment AS p ON p.payment_id=f.payment_id WHERE f.status='SUCCESS' GROUP BY p.booking_id) AS f ON f.booking_id=b.booking_id -- รวมเงินคืนสำเร็จ
ORDER BY b.booking_id DESC; -- ล่าสุดก่อน

-- ขั้นที่ 5: ดูเงินประกันและยอดที่ยังถือไว้
SELECT d.deposit_id, r.rental_no, d.required_amount, d.status, COALESCE(x.balance,0) AS deposit_balance, -- ยอดคงเหลือไม่รวมค่าเช่า
    CASE d.status WHEN 'PENDING' THEN N'รอวางเงินประกัน' WHEN 'HELD' THEN N'ถือเงินประกันอยู่' WHEN 'PARTIALLY_SETTLED' THEN N'คืนหรือหักบางส่วน' WHEN 'SETTLED' THEN N'สะสางครบแล้ว' WHEN 'CANCELLED' THEN N'ยกเลิกเงินประกัน' END AS status_thai -- แปลสถานะเงินประกัน
FROM dbo.security_deposit AS d -- รายการเงินประกัน
JOIN dbo.rental AS r ON r.rental_id=d.rental_id -- สัญญาที่เกี่ยวข้อง
LEFT JOIN (SELECT deposit_id, SUM(CASE WHEN transaction_type='RECEIVE' THEN amount ELSE -amount END) AS balance FROM dbo.deposit_transaction GROUP BY deposit_id) AS x ON x.deposit_id=d.deposit_id -- เงินรับลบเงินหักและเงินคืน
ORDER BY d.deposit_id DESC; -- ล่าสุดก่อน

-- ขั้นที่ 6: ดูรายการชำระและคืนเงิน พร้อมคำอ่านสถานะ
SELECT payment_id, booking_id, amount, payment_method, paid_at, status, -- ข้อมูลชำระเงิน
    CASE status WHEN 'PENDING' THEN N'รอดำเนินการ' WHEN 'SUCCESS' THEN N'สำเร็จ' WHEN 'FAILED' THEN N'ไม่สำเร็จ' WHEN 'CANCELLED' THEN N'ยกเลิก' END AS status_thai -- แปลสถานะการชำระ
FROM dbo.payment ORDER BY payment_id DESC; -- แสดงเงินรับล่าสุดก่อน
SELECT refund_id, payment_id, amount, reason, refunded_at, status, -- ข้อมูลคืนเงิน
    CASE status WHEN 'PENDING' THEN N'รอดำเนินการ' WHEN 'SUCCESS' THEN N'สำเร็จ' WHEN 'FAILED' THEN N'ไม่สำเร็จ' WHEN 'CANCELLED' THEN N'ยกเลิก' END AS status_thai -- แปลสถานะการคืน
FROM dbo.refund ORDER BY refund_id DESC; -- แสดงเงินคืนล่าสุดก่อน

-- ขั้นที่ 7: ดูงานซ่อมและช่วงปิดใช้งานของรถ
SELECT m.maintenance_id, v.registration_no, m.maintenance_type, m.blocked_from, m.blocked_until, m.cost, m.status, -- ข้อมูลงานซ่อม
    CASE m.status WHEN 'SCHEDULED' THEN N'นัดหมายแล้ว' WHEN 'IN_PROGRESS' THEN N'กำลังซ่อม' WHEN 'COMPLETED' THEN N'ซ่อมเสร็จ' WHEN 'CANCELLED' THEN N'ยกเลิกงาน' END AS status_thai -- แปลสถานะงานซ่อม
FROM dbo.maintenance AS m JOIN dbo.vehicle AS v ON v.vehicle_id=m.vehicle_id -- เชื่อมทะเบียนรถ
ORDER BY m.maintenance_id DESC; -- ล่าสุดก่อน

-- ขั้นที่ 8: ค้นการจองหนึ่งรายการ เปลี่ยน NULL เป็นรหัสที่ต้องการดู
DECLARE @booking_id BIGINT = NULL; -- เช่นกรอก 1 หรือรหัสที่ 10_RentCar.sql แสดงหลังบันทึก
SELECT * FROM dbo.booking WHERE booking_id=@booking_id; -- รายละเอียดการจอง
SELECT * FROM dbo.rental WHERE booking_id=@booking_id; -- สัญญาของการจองนี้
SELECT * FROM dbo.charge WHERE booking_id=@booking_id; -- ค่าใช้จ่ายทุกรายการและสถานะ
SELECT * FROM dbo.payment WHERE booking_id=@booking_id; -- การชำระทุกครั้ง
SELECT f.* FROM dbo.refund AS f JOIN dbo.payment AS p ON p.payment_id=f.payment_id WHERE p.booking_id=@booking_id; -- คืนเงินที่เกี่ยวข้อง
SELECT d.* FROM dbo.security_deposit AS d JOIN dbo.rental AS r ON r.rental_id=d.rental_id WHERE r.booking_id=@booking_id; -- เงินประกันที่เกี่ยวข้อง
