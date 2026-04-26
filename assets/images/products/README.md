# Quy ước thư mục ảnh sản phẩm

Cấu trúc dùng cho project này:

```text
assets/images/products/{category-slug}/{product-slug}/
```

Ví dụ:

```text
assets/images/products/laptop/macbook-air-m2/01-main.jpg
assets/images/products/laptop/macbook-air-m2/02-gallery.jpg
assets/images/products/pc-gaming/gaming-pc-rtx-4060/01-main.jpg
```

## Quy tắc đặt tên

- Tên thư mục danh mục dùng `category.slug`
- Tên thư mục sản phẩm dùng `product.slug`
- Chỉ dùng chữ thường, số và dấu gạch ngang `-`
- Không dùng dấu tiếng Việt trong tên thư mục
- Ảnh chính nên đặt `01-main.jpg`
- Ảnh phụ nên đặt `02-gallery.jpg`, `03-back.jpg`, ...

## Mapping đề xuất từ database

- `categories.slug` → thư mục danh mục
- `products.slug` → thư mục sản phẩm
- `product_images.image_url` → đường dẫn ảnh tương ứng trong thư mục đó

Ví dụ logic hiển thị:

```js
const imagePath = `assets/images/products/${categorySlug}/${productSlug}/01-main.jpg`;
```

## Gợi ý vận hành

- Khi thêm danh mục mới, tạo thư mục con theo slug của danh mục
- Khi thêm sản phẩm mới, tạo thư mục con theo slug của sản phẩm
- Dùng `slug` từ database để tránh lỗi tên file có dấu hoặc ký tự đặc biệt
