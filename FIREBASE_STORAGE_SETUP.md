# Firebase Storage Setup Instructions

## 🔥 Cấu hình Firebase Storage Rules

Để khắc phục lỗi "Permission denied" khi upload video, bạn cần cấu hình Firebase Storage Rules như sau:

### 1. Vào Firebase Console

1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Chọn project của bạn
3. Vào **Storage** → **Rules**

### 2. Cập nhật Storage Rules

Thay thế nội dung rules hiện tại bằng:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to upload videos
    match /videos/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Allow all authenticated users to read videos (for public access)
    match /videos/{userId}/{fileName} {
      allow read: if request.auth != null;
    }

    // Allow admins to manage all videos
    match /videos/{allPaths=**} {
      allow read, write: if request.auth != null &&
        (request.auth.token.admin == true ||
         request.auth.token.role == 'admin');
    }
  }
}
```

### 3. Publish Rules

Nhấn **Publish** để áp dụng rules mới.

## 🔐 Kiểm tra Authentication

Đảm bảo user đã đăng nhập trước khi upload:

```dart
// Kiểm tra trong code
if (FirebaseAuth.instance.currentUser == null) {
  // Yêu cầu user đăng nhập
  print('Please login first');
}
```

## 🧪 Test Firebase Storage

Bạn có thể test permissions bằng cách:

1. Chạy app và đăng nhập
2. Thử upload một video nhỏ
3. Kiểm tra console logs để xem có lỗi gì không

## 🛠️ Troubleshooting

### Nếu vẫn gặp lỗi 403:

1. **Kiểm tra Authentication**: Đảm bảo user đã đăng nhập
2. **Kiểm tra Rules**: Đảm bảo rules đã được publish
3. **Kiểm tra Path**: Đảm bảo path upload đúng format `/videos/{userId}/{fileName}`
4. **Restart App**: Thử restart app sau khi thay đổi rules

### Rules cho Development (tạm thời):

Nếu muốn test nhanh, có thể dùng rules này (KHÔNG sử dụng cho production):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📝 Notes

- Video sẽ được lưu trong folder `/videos/{userId}/` để tổ chức theo user
- File size giới hạn: 100MB
- Supported formats: mp4, avi, mov, mkv, wmv, flv, webm
- Metadata được tự động thêm khi upload
