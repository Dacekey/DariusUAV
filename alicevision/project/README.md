# Tổng quan Quy trình Tái tạo 3D (AliceVision Pipeline Overview)                                                                                                         

Một quy trình tái tạo 3D tiêu chuẩn của AliceVision/Meshroom trải qua 7 bước chính từ tập hợp ảnh 2D sang mô hình 3D hoàn chỉnh:                                                   
                                                                                                                                                                                     
    flowchart TD                                                                                                                                                                     
        A[1. Camera Init\nĐọc metadata & EXIF] --> B[2. Feature Extraction\nTrích xuất điểm đặc trưng]                                                                               
        B --> C[3. Feature Matching\nSo khớp điểm giữa các ảnh]                                                                                                                      
        C --> D[4. Structure from Motion SfM\nTạo đám mây điểm thô & tính vị trí camera]                                                                                             
        D --> E[5. Depth Map Estimation\nTính bản đồ độ sâu bằng CUDA GPU]                                                                                                           
        E --> F[6. Meshing\nDựng lưới đa giác 3D Mesh]                                                                                                                               
        F --> G[7. Texturing\nPhủ màu vật liệu Textures lên Mesh]                                                                                                                    
                                                                                                                                                                                     
  1. **Camera Initialization (Khởi tạo máy ảnh)**: Quét EXIF metadata từ 176 ảnh chụp để xác định thông số cảm biến (tiêu cự, kích thước cảm biến).                                      
  2. **Feature Extraction (Trích xuất đặc trưng)**: Sử dụng thuật toán (như SIFT, DSFT) để tìm ra hàng nghìn điểm đặc trưng độc nhất trên từng bức ảnh.                                  
  3. **Feature Matching (Ghép nối điểm):** Tìm và ghép cặp các điểm tương đồng xuất hiện trên các ảnh có vùng chồng lấn với nhau.                                                        
  4. **Structure from Motion - SfM (Tái tạo cấu trúc thô)**: Phục hồi lại toạ độ máy ảnh trong không gian 3D lúc chụp và tạo ra đám mây điểm thô (Sparse Point Cloud).
  5. **Depth Map Estimation (Ước lượng độ sâu)**: Chạy trên GPU CUDA (MVS) để tính toán độ sâu cho từng pixel, dựng nên đám mây điểm dày đặc (Dense Point Cloud).
  6. **Meshing (Tạo lưới bề mặt 3D)**: Kết nối các điểm trong không gian thành lưới các tam giác (Triangulated Mesh).
  7. **Texturing (Tạo vân bề mặt)**: Chiếu ngược hình ảnh thực tế từ ảnh chụp lên bề mặt mô hình 3D để tạo ra file  .obj  kèm texture  .png .
  ──────
  ### Phần 3: Hướng dẫn Chự án Thực tế ( P01_first-practice )
  
  Có 2 phương thức chính để bạn chạy toàn bộ dự án này:
  
  #### Cách 1: Chạy tự động bằng lệnh Batch (Khuyên dùng trên môi trường Linux Server/Terminal)
  
  Bạn chỉ cần dùng công cụ  meshroom_batch  được tích hợp sẵn để tự động chạy từ đầu đến cuối toàn bộ pipeline:
  
    cd /home/dacekey/dariusuav/alicevision
  
    # Chạy pipeline tái tạo 3D từ thư mục images vào thư mục output
    ./Meshroom-2023.3.0/meshroom_batch \
        --input ./project/P01_first-practice/images \
        --output ./project/P01_first-practice/output
  
  • Thời gian xử lý: Với 176 ảnh độ phân giải 14-16MB, thời gian chạy sẽ phụ thuộc vào GPU NVIDIA của bạn (thường mất từ 20 phút đến 1 giờ).
  • Kết quả thu được: Sau khi lệnh hoàn thành, trong thư mục  output/  bạn sẽ nhận được các file mô hình 3D hoàn chỉnh ( texturedMesh.obj ,  texturedMesh.mtl , và các file  *.png   
  texture).
  
  #### Cách 2: Chạy qua Giao diện Đồ họa (GUI)
  
  Nếu bạn đang kết nối màn hình đồ hoạ (desktop Linux) hoặc cấu hình X11 forwarding:
  
    cd /home/dacekey/dariusuav/alicevision/Meshroom-2023.3.0
    PYTHONPATH=$PWD ./Meshroom
  
  Sau khi mở giao diện Meshroom:
  
  1. Kéo thả toàn bộ 176 ảnh từ thư mục  images/  vào khung Images bên trái.
  2. Kiểm tra biểu tượng máy ảnh bên trái (nếu hiện màu xanh lá cây nghĩa là metadata đã nhận dạng đúng).
  3. Nhấn nút Start ở phía trên màn hình để bắt đầu tính toán.
