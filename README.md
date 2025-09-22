# DishHub - Recipe Sharing App

DishHub là ứng dụng mobile cho phép người dùng chia sẻ, tìm kiếm và quản lý công thức nấu ăn.  
Ứng dụng hướng đến cộng đồng yêu ẩm thực, nơi mọi người có thể đăng tải công thức của mình (kèm ảnh, video), đồng thời khám phá những món ăn mới từ người khác.

---

## Công nghệ sử dụng
- **Flutter** (ngôn ngữ Dart) → xây dựng UI đa nền tảng.
- **Firebase**
  - Firebase Authentication → Đăng nhập bằng Email/Password và Google.
  - Cloud Firestore → Lưu trữ dữ liệu công thức, người dùng, bình luận,...
- **Cloudinary** → Lưu trữ ảnh & video (free storage, thay thế Firebase Storage).
- **BLoC (hoặc MVVM)** → Quản lý state trong ứng dụng.
- **Git/GitHub** → Quản lý mã nguồn, phân công công việc nhóm.

---

## Các vai trò chính

### 1. User (Người dùng)
- Đăng ký, đăng nhập, quản lý tài khoản cá nhân.  
- Tạo, chỉnh sửa, xóa công thức nấu ăn.  
- Tìm kiếm, xem, thích, bình luận và lưu công thức yêu thích.  

### 2. Recipe (Công thức nấu ăn)
- Chứa thông tin chi tiết: tiêu đề, nguyên liệu, hướng dẫn, hình ảnh, video.  
- Liên kết với User (người tạo công thức).  
- Có các thuộc tính: số lượt thích, bình luận, lượt xem.  
- Hỗ trợ phân loại theo danh mục (món chính, tráng miệng, chay,...).  

### 3. Admin (Quản trị viên)
- Quản lý người dùng (chặn, xóa, cấp quyền).  
- Kiểm duyệt công thức, ẩn hoặc xóa nội dung vi phạm.  
- Thống kê, báo cáo hoạt động của ứng dụng.  
- Đảm bảo môi trường chia sẻ công thức an toàn, lành mạnh.  

---

## 👨‍💻 Thành viên nhóm
- **Vũ Hồng Đăng**  
- **Đỗ Minh Nhật**  
- **Vũ Huy Kỳ**

---
