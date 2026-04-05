# UniTEA - Trà Sữa Thức Giấc

UniTEA là nền tảng quản lý cửa hàng kinh doanh đồ uống và thức ăn trực tuyến toàn diện, mang lại trải nghiệm đặt hàng mượt mà cho khách hàng và bộ công cụ quản lý chuyên sâu cho cửa hàng. Được xây dựng trên nền tảng kỹ thuật hiện đại với Next.js 15, Tailwind CSS và hệ sinh thái Supabase (PostgreSQL, Auth, Storage, Realtime).

## 🚀 Tính Năng Nổi Bật

### 🧑‍💻 Dành cho Khách hàng (User)
- **Menu Sản phẩm Trực quan:** Duyệt qua danh mục thức ăn, đồ uống, xem chi tiết và hình ảnh hấp dẫn. Lọc danh sách theo từng danh mục.
- **Giỏ Hàng & Đặt Hàng:** Đặt hàng cực kỳ dễ dàng (cho phép chọn số lượng, ghi chú riêng). 
- **Theo Dõi Đơn Hàng (Real-time):** Giao diện `/history` giúp khách hàng theo dõi sát sao tình trạng hiện tại của đơn hàng (Đang chờ, Đang chuẩn bị, Hoàn thành...) mà không cần phải Refresh trang.
- **Hỗ trợ qua mã QR:** Trực tiếp quét mã QR tại bàn để nhắn tin với nhân viên dù không cần phải đăng ký tài khoản (hỗ trợ nhập định danh cá nhân Ẩn danh).

### 👨‍💼 Dành cho Cửa hàng (Admin)
- **Hệ thống Quản lý Bảng điều khiển (Dashboard):** 
  - Khởi tạo Token mã QR động định danh cho từng bàn kinh doanh.
  - Theo dõi danh sách Phiên truy cập quét mã, kết nối trực tiếp, có thể chủ động **Dừng/Vô hiệu hóa phiên** trong trường hợp hết hạn.
- **Live Chat (Chăm sóc Khách hàng):** Trò chuyện, phản hồi thắc mắc, gửi hình ảnh qua lại theo giời gian thực với Khách đang ngồi tại bàn.
- **Kho Hàng & Sản phẩm:** 
  - Quản lý thêm/Sửa/Xóa (ẩn/soft-delete) thức ăn đồ uống.
  - Thêm ảnh trực quan cho sản phẩm được hỗ trợ bởi Supabase Storage Buckets.
- **Quản lý Đơn hàng (Real-time):** Tiếp nhận đơn hàng. Xác nhận hoặc Từ chối đơn theo luồng nghiệp vụ.
- **Tự động Trừ và Hoàn Kho (Database Triggers):** Khi khách chốt đơn, CSDL sẽ kích hoạt hàm tự động trừ đi số lượng sẵn có trong kho để chống vượt định mức. Nếu đơn bị Admin từ chối, lượng trống trong kho sẽ lập tức được cộng hoàn.
- **Bảo mật An toàn:** Hệ thống quy định phân quyền mức hàng ngang (Row Level Security - RLS). Khách hàng chỉ truy cập được dữ liệu mua bán của chính mình, các yêu cầu nhạy cảm chỉ tiếp nhận nếu đến từ phân quyền `STORE_ADMIN`.

## 🛠️ Công Nghệ Sử Dụng

- **Framework:** Next.js 15 (App Router), React 19
- **Ngôn ngữ:** TypeScript
- **Style & UI:** Tailwind CSS, Lucide React Icons
- **Backend/BaaS:** Supabase (PostgreSQL)
  - **Auth:** Quản lý tài khoản và phiên làm việc (Mật khẩu / Ẩn danh).
  - **Realtime (WebSockets):** Đồng bộ tin nhắn, đồng bộ danh sách QR và cập nhật trạng thái đơn đặt hàng chỉ trong tích tắc.
  - **Storage:** Hệ thống ảnh tối ưu dung lượng cho thực đơn.

## 📦 Cài Đặt (Local Development)

### 1. Nhân bản dự án
```bash
git clone https://github.com/in4SECxMinDandy/UniTEA.git
cd UniTEA
```

### 2. Cài đặt Dependencies
```bash
npm install
```

### 3. Cấu hình Môi trường
Tạo tệp `.env.local` ở thư mục gốc của dự án và khai báo cấu hình Supabase:
```env
NEXT_PUBLIC_SUPABASE_URL=your-supabase-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

### 4. Bắt đầu Development Server
Khởi chạy dự án tại localhost:
```bash
npm run dev
```

Mở trình duyệt, truy cập `http://localhost:3000`.

## 📚 Cấu Trúc Khối Cơ Sở Dữ Liệu
Dự án được bảo mật nghiêm ngặt bằng **PostgreSQL RLS**. Cấu trúc Migration nổi bật:
- `014` - `016`: Xây dựng luồng Order, RLS cho Orders, Query phân loại hồ sơ tài khoản và **Function Trigger Trừ/Hoàn tồn kho tự động**.
- `011`, `017`: Phân quyền danh tính tài khoản Ẩn Danh, chặn các khách hàng đang trò chuyện nhưng phiên QR đã bị khóa lại bởi Quản trị viên. 

---
_Đây là sản phẩm hướng đến một dịch vụ quản lý khép kín F&B năng động, đáp ứng tốc độ cao nhưng vẫn giữ được kiến trúc trong sạch và dễ vận hành._
