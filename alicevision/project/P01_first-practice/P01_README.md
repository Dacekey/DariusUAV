# P01_first-practice: Tái tạo 3D Photogrammetry với AliceVision / Meshroom

Dự án này thực hiện quy trình tái tạo mô hình 3D từ tập ảnh chụp 2D (Photogrammetry) tự động hóa bằng pipeline của **AliceVision / Meshroom** ngay trong môi trường Jupyter Notebook (`P01_implement.ipynb`).

---

## 1. Cấu trúc thư mục và Tài liệu chính

```text
P01_first-practice/
├── P01_implement.ipynb       # Notebook chính chứa toàn bộ mã nguồn thực thi pipeline 3D
├── images/                   # Thư mục chứa các ảnh chụp 2D đầu vào
└── output/                   # Thư mục chứa toàn bộ kết quả qua các bước tái tạo
    ├── 3d_interactive_preview.html  # Trình xem 3D tương tác độc lập trên trình duyệt Web
    ├── cache/
    │   ├── 05_sfm/           # Kết quả Structure from Motion (cloud_and_poses.ply)
    │   ├── 07_depthMap/      # Bản đồ độ sâu định dạng OpenEXR (.exr)
    │   ├── 08_depthMapFilter/# Bản đồ pháp tuyến định dạng OpenEXR (.exr)
    │   └── 10_meshFiltering/ # Lưới 3D đã lọc lỗ thủng (mesh_filtered.obj)
    └── texturing/            # Kết quả mô hình 3D hoàn chỉnh cuối cùng
        ├── texturedMesh_light.ply   # Mô hình 3D bản nén tối ưu siêu mượt (~3.5 MB)
        ├── texturedMesh_full.ply    # Mô hình 3D bản độ nét cao đầy đủ (~48 MB)
        └── texturedMesh.obj         # Mô hình 3D gốc dạng text (~125 MB)
```

### Các tài liệu nổi bật:
* **`P01_implement.ipynb`**: Tích hợp sẵn hàm giải mã ảnh độ sâu OpenEXR (`.exr`) siêu bền vững thông qua thư viện `imageio` dự phòng cho `cv2`, đồng thời hiển thị đồ thị 2D/3D trực tiếp ngay dưới từng Cell.
* **`output/3d_interactive_preview.html`**: File xem 3D hoạt động độc lập không cần phần mềm chuyên dụng. Bạn chỉ cần nhấp đúp để mở trong trình duyệt web hoặc VS Code Preview để xoay, zoom mô hình ở tốc độ 60 FPS.

---

## 2. LƯU Ý KỸ THUẬT QUAN TRỌNG: Vì sao nên dùng `.ply` thay cho `.obj`?

Trong quá trình làm việc với các mô hình 3D mật độ cao từ photogrammetry (hàng triệu mặt tam giác), định dạng **`.ply` (Polygon File Format)** thể hiện sự vượt trội hoàn toàn so với định dạng `.obj`:

| Tiêu chí | Định dạng `.obj` (Wavefront OBJ) | Định dạng `.ply` (Stanford PLY - Khuyên dùng) |
| :--- | :--- | :--- |
| **Bản chất lưu trữ** | Dạng văn bản thuần túy (Text/ASCII) | Dạng nhị phân tối ưu (Binary) |
| **Kích thước file** | Rất nặng (~125 MB cho 1.6 triệu tam giác) | Nhỏ gọn hơn **60%** (~48 MB cho cùng độ nét) |
| **Tốc độ mở trên MeshLab** | Chậm, thường gây tràn RAM hoặc sập chương trình | **Siêu tốc chỉ mất ~0.12 giây** |
| **Độ ổn định trình đọc C++**| Dễ gặp lỗi cú pháp `Assertion failed` trên MeshLab | **Ổn định 100%**, không bao giờ bị lỗi bộ đếm |
| **Mở trên VS Code 3D Viewer**| Thường gây treo bộ nhớ WebGL của Electron | Load mượt mà, phản hồi tức thì |

### Khuyến nghị:
Khi xem hoặc xử lý mô hình trên MeshLab cũng như các phần mềm 3D khác, **hãy luôn ưu tiên sử dụng các file định dạng `.ply`** (`texturedMesh_light.ply` hoặc `texturedMesh_full.ply`) để đạt tốc độ xử lý nhanh nhất và tránh tuyệt đối tình trạng Crash / Out of Memory.

---

## 3. Hướng dẫn Cài đặt & Sử dụng MeshLab

**MeshLab** là phần mềm mã nguồn mở chuẩn công nghiệp chuyên dụng để xử lý, chỉnh sửa và kiểm tra lưới tam giác 3D mật độ lớn.

### Bước 1: Cài đặt MeshLab trên Linux / Ubuntu
Mở Terminal và chạy lệnh sau:
```bash
sudo apt update && sudo apt install -y meshlab
```

### Bước 2: Mở mô hình 3D bằng Terminal
Để mở mô hình 3D tức thì mà không cần tìm kiếm đường dẫn thủ công, hãy chạy lệnh sau:

* **Mở phiên bản siêu nhẹ (Tối ưu cho máy cấu hình thấp, load tức thì):**
  ```bash
  meshlab /home/dacekey/dariusuav/alicevision/project/P01_first-practice/output/texturing/texturedMesh_light.ply &
  ```
* **Mở phiên bản độ nét tối đa (1.6 triệu tam giác đầy đủ chi tiết):**
  ```bash
  meshlab /home/dacekey/dariusuav/alicevision/project/P01_first-practice/output/texturing/texturedMesh_full.ply &
  ```

### Bước 3: Các thao tác điều hướng cốt lõi trong MeshLab

* **Thao tác "Cứu cánh" đầu tiên (`Ctrl + H`):**  
  Khi vừa nạp mô hình vào MeshLab, do lệch hệ tọa độ camera ban đầu, màn hình có thể trông trống rỗng. Hãy nhấn ngay tổ hợp phím **`Ctrl + H`** (hoặc nhấp vào nút **Reset View / Fit to Window** trên thanh công cụ). Camera sẽ lập tức thu phóng và đưa toàn bộ mô hình 3D vào chính giữa màn hình của bạn!
* **Xoay mô hình (Rotate):** Nhấp và giữ **Chuột trái**, sau đó di chuyển chuột.
* **Di chuyển khung hình (Pan):** Nhấp và giữ **Chuột phải** (hoặc giữ phím `Ctrl` + chuột trái), sau đó kéo chuột.
* **Phóng to / Thu nhỏ (Zoom):** Cuộn **Nút giữa chuột** lên/xuống.
* **Bật/Tắt chế độ hiển thị khung lưới (Wireframe):** Nhấp vào biểu tượng lưới tam giác trên thanh công cụ để kiểm tra mật độ cấu trúc lưới photogrammetry.
