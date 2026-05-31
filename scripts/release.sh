#!/bin/bash

# Dừng script ngay lập tức nếu có bất kỳ lệnh nào bị lỗi
set -e

echo "🚀 Bắt đầu quá trình tự động kiểm tra và chuẩn bị release..."

# 1. Xác nhận nâng version (Thủ công một chút để an toàn)
read -p "Bạn đã cập nhật version trong pubspec.yaml và CHANGELOG, README, ROADMAP chưa? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "❌ Vui lòng cập nhật version trước khi tiếp tục."
    exit 1
fi

# 2. Dọn dẹp rác
echo "🧹 Đang dọn dẹp dự án..."
fvm flutter clean && fvm flutter pub get
cd example && fvm flutter clean && fvm flutter pub get && cd ..

# 3. Format code (Đảm bảo code đẹp)
echo "💅 Đang format code..."
dart format .

# 4. Chạy kiểm tra chất lượng code
echo "🔍 Đang phân tích code (static analysis)..."
fvm flutter analyze

# 5. Chạy Unit Tests
echo "🧪 Đang chạy bộ test..."
fvm flutter test

# 6. Kiểm tra tiêu chuẩn pub.dev (Dry run)
echo "📦 Kiểm tra độ sẵn sàng của package..."
dart pub publish --dry-run

# 7. Xác nhận nâng version (Thủ công một chút để an toàn)
read -p "Bạn đã cập nhật version trong pubspec.yaml và CHANGELOG chưa? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "❌ Vui lòng cập nhật version trước khi tiếp tục."
    exit 1
fi

# Lấy version hiện tại từ pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //')

# 8. Git Workflow
echo "Git: Đang kiểm tra thay đổi và gắn tag $VERSION..."
git add .

# Chỉ commit nếu có thay đổi thực sự
if ! git diff-index --quiet HEAD --; then
    git commit -m "release: v$VERSION"
else
    echo "Thông báo: Không có thay đổi mới để commit, chuyển sang gắn tag."
fi

# Kiểm tra xem tag đã tồn tại chưa trước khi gắn
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
    echo "Cảnh báo: Tag v$VERSION đã tồn tại. Đang bỏ qua bước tạo tag."
else
    git tag -a v$VERSION -m "Release: v$VERSION"
fi

# 9. Push lên GitHub
echo "📤 Đang đẩy code và tags lên GitHub..."
git push origin main
git push origin --tags

echo "✅ Hoàn tất! Package đã sẵn sàng để publish."
echo "👉 Bước cuối cùng: Chạy 'dart pub publish' nếu bạn đã sẵn sàng."