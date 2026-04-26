-- =========================================================
-- DATABASE: computer_store
-- ENGINE: InnoDB
-- CHARSET: utf8mb4
-- COLLATION: utf8mb4_unicode_ci
-- =========================================================

CREATE DATABASE IF NOT EXISTS computer_store
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE computer_store;

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- =========================================================
-- 1. USERS, ROLES, PERMISSIONS
-- =========================================================

CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NULL,
  password_hash VARCHAR(255) NOT NULL,
  avatar_url VARCHAR(500) NULL,
  status ENUM('active', 'inactive', 'banned') NOT NULL DEFAULT 'active',
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_phone (phone),
  KEY idx_users_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE roles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  description VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_roles_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE permissions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  description VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_permissions_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE role_permissions (
  role_id BIGINT UNSIGNED NOT NULL,
  permission_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  CONSTRAINT fk_role_permissions_role
    FOREIGN KEY (role_id) REFERENCES roles(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_role_permissions_permission
    FOREIGN KEY (permission_id) REFERENCES permissions(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_roles (
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_user_roles_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_roles_role
    FOREIGN KEY (role_id) REFERENCES roles(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 2. USER ADDRESSES
-- =========================================================

CREATE TABLE user_addresses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  recipient_name VARCHAR(255) NOT NULL,
  recipient_phone VARCHAR(20) NOT NULL,
  province VARCHAR(255) NOT NULL,
  district VARCHAR(255) NOT NULL,
  ward VARCHAR(255) NOT NULL,
  street_address VARCHAR(500) NOT NULL,
  is_default TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_addresses_user_id (user_id),
  KEY idx_user_addresses_default (user_id, is_default),
  CONSTRAINT fk_user_addresses_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 3. CATEGORIES, BRANDS
-- =========================================================

CREATE TABLE categories (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  parent_id BIGINT UNSIGNED NULL,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  description TEXT NULL,
  image_url VARCHAR(500) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_slug (slug),
  KEY idx_categories_parent_id (parent_id),
  KEY idx_categories_active (is_active),
  CONSTRAINT fk_categories_parent
    FOREIGN KEY (parent_id) REFERENCES categories(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE brands (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  logo_url VARCHAR(500) NULL,
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_brands_slug (slug),
  KEY idx_brands_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 4. PRODUCTS
-- =========================================================

CREATE TABLE products (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_id BIGINT UNSIGNED NOT NULL,
  brand_id BIGINT UNSIGNED NULL,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  short_description VARCHAR(1000) NULL,
  description LONGTEXT NULL,
  status ENUM('draft', 'active', 'inactive', 'out_of_stock') NOT NULL DEFAULT 'draft',
  is_featured TINYINT(1) NOT NULL DEFAULT 0,
  is_new TINYINT(1) NOT NULL DEFAULT 0,
  is_hot TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_slug (slug),
  KEY idx_products_category_id (category_id),
  KEY idx_products_brand_id (brand_id),
  KEY idx_products_status (status),
  KEY idx_products_featured (is_featured),
  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_products_brand
    FOREIGN KEY (brand_id) REFERENCES brands(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_images (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(500) NOT NULL,
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_images_product_id (product_id),
  KEY idx_product_images_primary (product_id, is_primary),
  CONSTRAINT fk_product_images_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_variants (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  sku VARCHAR(100) NOT NULL,
  barcode VARCHAR(100) NULL,
  price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  sale_price DECIMAL(12,2) NULL,
  cost_price DECIMAL(12,2) NULL,
  stock_quantity INT NOT NULL DEFAULT 0,
  weight DECIMAL(10,3) NULL,
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_variants_sku (sku),
  KEY idx_product_variants_product_id (product_id),
  KEY idx_product_variants_status (status),
  KEY idx_product_variants_stock (stock_quantity),
  CONSTRAINT fk_product_variants_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_attributes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_attributes_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_variant_attributes (
  variant_id BIGINT UNSIGNED NOT NULL,
  attribute_id BIGINT UNSIGNED NOT NULL,
  attribute_value VARCHAR(255) NOT NULL,
  PRIMARY KEY (variant_id, attribute_id),
  KEY idx_pva_attribute_id (attribute_id),
  CONSTRAINT fk_pva_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pva_attribute
    FOREIGN KEY (attribute_id) REFERENCES product_attributes(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 5. SPECIFICATIONS
-- =========================================================

CREATE TABLE spec_groups (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE specifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  spec_group_id BIGINT UNSIGNED NOT NULL,
  spec_name VARCHAR(255) NOT NULL,
  spec_value VARCHAR(1000) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_specifications_product_id (product_id),
  KEY idx_specifications_group_id (spec_group_id),
  CONSTRAINT fk_specifications_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_specifications_group
    FOREIGN KEY (spec_group_id) REFERENCES spec_groups(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 6. CARTS, WISHLIST
-- =========================================================

CREATE TABLE carts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  session_id VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_carts_user_id (user_id),
  KEY idx_carts_session_id (session_id),
  CONSTRAINT fk_carts_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cart_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cart_id BIGINT UNSIGNED NOT NULL,
  variant_id BIGINT UNSIGNED NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cart_variant (cart_id, variant_id),
  KEY idx_cart_items_variant_id (variant_id),
  CONSTRAINT fk_cart_items_cart
    FOREIGN KEY (cart_id) REFERENCES carts(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_cart_items_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE wishlists (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_wishlists_user_id (user_id),
  CONSTRAINT fk_wishlists_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE wishlist_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  wishlist_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_wishlist_product (wishlist_id, product_id),
  KEY idx_wishlist_items_product_id (product_id),
  CONSTRAINT fk_wishlist_items_wishlist
    FOREIGN KEY (wishlist_id) REFERENCES wishlists(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_wishlist_items_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 7. ORDERS
-- =========================================================

CREATE TABLE orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_code VARCHAR(50) NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  customer_name VARCHAR(255) NOT NULL,
  customer_phone VARCHAR(20) NOT NULL,
  customer_email VARCHAR(255) NULL,
  shipping_address VARCHAR(500) NOT NULL,
  shipping_province VARCHAR(255) NOT NULL,
  shipping_district VARCHAR(255) NOT NULL,
  shipping_ward VARCHAR(255) NOT NULL,
  shipping_note VARCHAR(1000) NULL,
  payment_method VARCHAR(100) NOT NULL,
  payment_status ENUM('pending', 'paid', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
  order_status ENUM('pending', 'confirmed', 'processing', 'shipping', 'completed', 'cancelled', 'returned') NOT NULL DEFAULT 'pending',
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  shipping_fee DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  coupon_code VARCHAR(100) NULL,
  placed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_orders_order_code (order_code),
  KEY idx_orders_user_id (user_id),
  KEY idx_orders_order_status (order_status),
  KEY idx_orders_payment_status (payment_status),
  KEY idx_orders_placed_at (placed_at),
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  variant_id BIGINT UNSIGNED NULL,
  product_name VARCHAR(255) NOT NULL,
  variant_name VARCHAR(255) NULL,
  sku VARCHAR(100) NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  total_price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_items_order_id (order_id),
  KEY idx_order_items_variant_id (variant_id),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_items_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_status_history (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  from_status VARCHAR(50) NULL,
  to_status VARCHAR(50) NOT NULL,
  note VARCHAR(1000) NULL,
  changed_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_status_history_order_id (order_id),
  KEY idx_order_status_history_changed_by (changed_by),
  CONSTRAINT fk_order_status_history_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_status_history_changed_by
    FOREIGN KEY (changed_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 8. PAYMENTS
-- =========================================================

CREATE TABLE payments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  payment_method VARCHAR(100) NOT NULL,
  transaction_code VARCHAR(255) NULL,
  amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  status ENUM('pending', 'success', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
  paid_at DATETIME NULL,
  gateway_response JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_payments_order_id (order_id),
  KEY idx_payments_status (status),
  KEY idx_payments_transaction_code (transaction_code),
  CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 9. SHIPPING
-- =========================================================

CREATE TABLE shipping_methods (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(100) NOT NULL,
  description VARCHAR(500) NULL,
  fee DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  estimated_days_min INT NOT NULL DEFAULT 0,
  estimated_days_max INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_shipping_methods_code (code),
  KEY idx_shipping_methods_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipping_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  carrier_name VARCHAR(255) NULL,
  tracking_code VARCHAR(255) NULL,
  status VARCHAR(100) NOT NULL,
  note VARCHAR(1000) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_shipping_logs_order_id (order_id),
  KEY idx_shipping_logs_tracking_code (tracking_code),
  CONSTRAINT fk_shipping_logs_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 10. COUPONS, PROMOTIONS
-- =========================================================

CREATE TABLE coupons (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(100) NOT NULL,
  name VARCHAR(255) NOT NULL,
  type ENUM('percent', 'fixed') NOT NULL,
  value DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  min_order_value DECIMAL(12,2) NULL,
  max_discount_amount DECIMAL(12,2) NULL,
  usage_limit INT NULL,
  usage_per_user INT NULL,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_coupons_code (code),
  KEY idx_coupons_active_dates (is_active, start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE coupon_usages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  coupon_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  order_id BIGINT UNSIGNED NOT NULL,
  used_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_coupon_usages_coupon_id (coupon_id),
  KEY idx_coupon_usages_user_id (user_id),
  KEY idx_coupon_usages_order_id (order_id),
  CONSTRAINT fk_coupon_usages_coupon
    FOREIGN KEY (coupon_id) REFERENCES coupons(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_coupon_usages_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_coupon_usages_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE promotions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  discount_type ENUM('percent', 'fixed') NOT NULL,
  discount_value DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_promotions_active_dates (is_active, start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE promotion_products (
  promotion_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (promotion_id, product_id),
  CONSTRAINT fk_promotion_products_promotion
    FOREIGN KEY (promotion_id) REFERENCES promotions(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_promotion_products_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 11. REVIEWS, QUESTIONS
-- =========================================================

CREATE TABLE reviews (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  order_item_id BIGINT UNSIGNED NULL,
  rating TINYINT UNSIGNED NOT NULL,
  title VARCHAR(255) NULL,
  content TEXT NOT NULL,
  is_verified_purchase TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_reviews_product_id (product_id),
  KEY idx_reviews_user_id (user_id),
  KEY idx_reviews_order_item_id (order_item_id),
  KEY idx_reviews_status (status),
  CONSTRAINT fk_reviews_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_reviews_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_reviews_order_item
    FOREIGN KEY (order_item_id) REFERENCES order_items(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE review_images (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  review_id BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(500) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_review_images_review_id (review_id),
  CONSTRAINT fk_review_images_review
    FOREIGN KEY (review_id) REFERENCES reviews(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE product_questions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  question TEXT NOT NULL,
  answer TEXT NULL,
  answered_by BIGINT UNSIGNED NULL,
  status ENUM('pending', 'answered', 'hidden') NOT NULL DEFAULT 'pending',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_questions_product_id (product_id),
  KEY idx_product_questions_user_id (user_id),
  KEY idx_product_questions_answered_by (answered_by),
  KEY idx_product_questions_status (status),
  CONSTRAINT fk_product_questions_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_questions_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_product_questions_answered_by
    FOREIGN KEY (answered_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 12. BLOG / POSTS
-- =========================================================

CREATE TABLE post_categories (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_post_categories_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE post_tags (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_post_tags_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE posts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_id BIGINT UNSIGNED NULL,
  author_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  excerpt VARCHAR(1000) NULL,
  content LONGTEXT NOT NULL,
  thumbnail_url VARCHAR(500) NULL,
  status ENUM('draft', 'published', 'archived') NOT NULL DEFAULT 'draft',
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_posts_slug (slug),
  KEY idx_posts_category_id (category_id),
  KEY idx_posts_author_id (author_id),
  KEY idx_posts_status (status),
  CONSTRAINT fk_posts_category
    FOREIGN KEY (category_id) REFERENCES post_categories(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_posts_author
    FOREIGN KEY (author_id) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE post_tag_relations (
  post_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (post_id, tag_id),
  CONSTRAINT fk_post_tag_relations_post
    FOREIGN KEY (post_id) REFERENCES posts(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_post_tag_relations_tag
    FOREIGN KEY (tag_id) REFERENCES post_tags(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 13. BANNERS / HOMEPAGE
-- =========================================================

CREATE TABLE banners (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  image_url VARCHAR(500) NOT NULL,
  link_url VARCHAR(500) NULL,
  position ENUM('home_top', 'home_middle', 'sidebar', 'popup') NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  start_date DATETIME NULL,
  end_date DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_banners_position (position),
  KEY idx_banners_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE homepage_sections (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  section_type VARCHAR(100) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_homepage_sections_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 14. AUDIT LOGS, SYSTEM SETTINGS
-- =========================================================

CREATE TABLE admin_activity_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  admin_id BIGINT UNSIGNED NOT NULL,
  action VARCHAR(255) NOT NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  before_data JSON NULL,
  after_data JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_admin_activity_logs_admin_id (admin_id),
  KEY idx_admin_activity_logs_entity (entity_type, entity_id),
  KEY idx_admin_activity_logs_created_at (created_at),
  CONSTRAINT fk_admin_activity_logs_admin
    FOREIGN KEY (admin_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE system_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  setting_key VARCHAR(255) NOT NULL,
  setting_value LONGTEXT NOT NULL,
  data_type VARCHAR(50) NOT NULL DEFAULT 'string',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_system_settings_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 15. WAREHOUSES / INVENTORY
-- =========================================================

CREATE TABLE warehouses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(500) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_warehouses_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inventory_movements (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  warehouse_id BIGINT UNSIGNED NOT NULL,
  variant_id BIGINT UNSIGNED NOT NULL,
  movement_type ENUM('in', 'out', 'adjust') NOT NULL,
  quantity INT NOT NULL,
  reference_type VARCHAR(100) NULL,
  reference_id BIGINT UNSIGNED NULL,
  note VARCHAR(1000) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_inventory_movements_warehouse_id (warehouse_id),
  KEY idx_inventory_movements_variant_id (variant_id),
  KEY idx_inventory_movements_reference (reference_type, reference_id),
  CONSTRAINT fk_inventory_movements_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_inventory_movements_variant
    FOREIGN KEY (variant_id) REFERENCES product_variants(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 16. WARRANTIES
-- =========================================================

CREATE TABLE warranties (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_item_id BIGINT UNSIGNED NOT NULL,
  warranty_code VARCHAR(100) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status ENUM('active', 'expired', 'claimed', 'void') NOT NULL DEFAULT 'active',
  note VARCHAR(1000) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_warranties_code (warranty_code),
  UNIQUE KEY uq_warranties_order_item (order_item_id),
  CONSTRAINT fk_warranties_order_item
    FOREIGN KEY (order_item_id) REFERENCES order_items(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE warranty_claims (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  warranty_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  issue_description TEXT NOT NULL,
  status ENUM('pending', 'processing', 'approved', 'rejected', 'resolved') NOT NULL DEFAULT 'pending',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_warranty_claims_warranty_id (warranty_id),
  KEY idx_warranty_claims_user_id (user_id),
  KEY idx_warranty_claims_status (status),
  CONSTRAINT fk_warranty_claims_warranty
    FOREIGN KEY (warranty_id) REFERENCES warranties(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_warranty_claims_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO brands (name, slug, description) VALUES
('Apple', 'apple', 'Thương hiệu Apple'),
('ASUS', 'asus', 'Thương hiệu ASUS'),
('Lenovo', 'lenovo', 'Thương hiệu Lenovo'),
('MSI', 'msi', 'Thương hiệu MSI'),
('Logitech', 'logitech', 'Thương hiệu Logitech')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO categories (parent_id, name, slug, description, is_active, sort_order) VALUES
(NULL, 'Laptop', 'laptop', 'Máy tính xách tay cho học tập và làm việc', 1, 1),
(NULL, 'PC Gaming', 'pc-gaming', 'Máy tính để bàn cấu hình cao cho gaming', 1, 2),
(NULL, 'Màn hình', 'man-hinh', 'Màn hình cho làm việc và giải trí', 1, 3),
(NULL, 'Linh kiện', 'linh-kien', 'CPU, RAM, SSD, VGA và các linh kiện khác', 1, 4),
(NULL, 'Phụ kiện', 'phu-kien', 'Bàn phím, chuột, tai nghe và phụ kiện', 1, 5)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), is_active = VALUES(is_active), sort_order = VALUES(sort_order);

INSERT INTO users (full_name, email, phone, password_hash, avatar_url, status) VALUES
('Admin Store', 'admin@computerstore.local', '0900000001', '$2y$10$adminsamplehash', NULL, 'active'),
('Nguyen Van A', 'a@computerstore.local', '0900000002', '$2y$10$customersamplehash', NULL, 'active')
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name), phone = VALUES(phone), status = VALUES(status);

INSERT INTO products (category_id, brand_id, name, slug, short_description, description, status, is_featured, is_new, is_hot) VALUES
(1, 1, 'MacBook Air M2', 'macbook-air-m2', 'Laptop mỏng nhẹ cho học tập và làm việc.', 'MacBook Air M2 hiệu năng tốt, pin lâu, phù hợp học tập và văn phòng.', 'active', 1, 1, 1),
(1, 2, 'ASUS Vivobook 15', 'asus-vivobook-15', 'Laptop phổ thông màn hình lớn.', 'ASUS Vivobook 15 phù hợp nhu cầu học tập và giải trí hằng ngày.', 'active', 1, 1, 0),
(1, 3, 'Lenovo Legion 5', 'lenovo-legion-5', 'Laptop gaming hiệu năng cao.', 'Lenovo Legion 5 phục vụ gaming và đồ họa với hiệu năng ổn định.', 'active', 1, 0, 1),
(2, 4, 'Gaming PC RTX 4060', 'gaming-pc-rtx-4060', 'Bộ PC gaming mạnh mẽ.', 'Cấu hình gaming tối ưu cho chơi game và streaming.', 'active', 1, 0, 1),
(3, 2, 'Màn hình ASUS 24 inch', 'man-hinh-asus-24-inch', 'Màn hình 24 inch tần số quét cao.', 'Phù hợp làm việc, giải trí và gaming cơ bản.', 'active', 0, 1, 0),
(5, 5, 'Bàn phím cơ RGB', 'ban-phim-co-rgb', 'Bàn phím cơ LED RGB.', 'Bàn phím cơ cho game thủ và người dùng văn phòng yêu thích cảm giác gõ tốt.', 'active', 0, 1, 0),
(5, 5, 'Chuột gaming Logitech G502', 'chuot-gaming-logitech-g502', 'Chuột gaming nhiều nút bấm.', 'Chuột gaming có cảm biến chính xác, phù hợp chơi FPS và MOBA.', 'active', 1, 1, 0),
(4, 4, 'RAM DDR4 16GB 3200MHz', 'ram-ddr4-16gb-3200mhz', 'Thanh RAM cho nâng cấp hiệu năng.', 'RAM DDR4 16GB phù hợp nâng cấp laptop hoặc PC văn phòng và gaming nhẹ.', 'active', 1, 1, 0),
(4, 4, 'SSD NVMe 1TB', 'ssd-nvme-1tb', 'Ổ cứng SSD tốc độ cao.', 'SSD NVMe 1TB giúp khởi động máy và tải ứng dụng nhanh hơn.', 'active', 1, 0, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), short_description = VALUES(short_description), description = VALUES(description), status = VALUES(status), is_featured = VALUES(is_featured), is_new = VALUES(is_new), is_hot = VALUES(is_hot);

INSERT INTO product_variants (product_id, sku, barcode, price, sale_price, cost_price, stock_quantity, weight, status) VALUES
(1, 'MBA-M2-8-256', NULL, 24990000.00, 22990000.00, 21000000.00, 12, 1.240, 'active'),
(2, 'VIVO-15-R5-16-512', NULL, 15990000.00, 14990000.00, 13500000.00, 18, 1.700, 'active'),
(3, 'LEGION5-R7-16-1TB', NULL, 28990000.00, 27990000.00, 25500000.00, 8, 2.400, 'active'),
(4, 'PC-RTX4060-I5-16-1TB', NULL, 32500000.00, 30990000.00, 29000000.00, 6, 8.000, 'active'),
(5, 'MON-ASUS-24-165', NULL, 3690000.00, 3290000.00, 2900000.00, 24, 3.200, 'active'),
(6, 'KB-RGB-RED', NULL, 1450000.00, 1290000.00, 1100000.00, 34, 0.900, 'active'),
(7, 'MOU-G502-HERO', NULL, 1190000.00, 1090000.00, 920000.00, 40, 0.121, 'active'),
(8, 'RAM-16GB-3200', NULL, 990000.00, 890000.00, 760000.00, 55, 0.060, 'active'),
(9, 'SSD-NVME-1TB', NULL, 1890000.00, 1690000.00, 1450000.00, 30, 0.080, 'active')
ON DUPLICATE KEY UPDATE price = VALUES(price), sale_price = VALUES(sale_price), cost_price = VALUES(cost_price), stock_quantity = VALUES(stock_quantity), status = VALUES(status);

INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(1, '/assets/images/products/laptop/macbook-air-m2/01-main.jpg', 1, 1),
(2, '/assets/images/products/laptop/asus-vivobook-15/01-main.jpg', 1, 1),
(3, '/assets/images/products/laptop/lenovo-legion-5/01-main.jpg', 1, 1),
(4, '/assets/images/products/pc-gaming/gaming-pc-rtx-4060/01-main.jpg', 1, 1),
(5, '/assets/images/products/man-hinh/man-hinh-asus-24-inch/01-main.jpg', 1, 1),
(6, '/assets/images/products/phu-kien/ban-phim-co-rgb/01-main.jpg', 1, 1),
(7, '/assets/images/products/phu-kien/chuot-gaming-logitech-g502/01-main.jpg', 1, 1),
(8, '/assets/images/products/linh-kien/ram-ddr4-16gb-3200mhz/01-main.jpg', 1, 1),
(9, '/assets/images/products/linh-kien/ssd-nvme-1tb/01-main.jpg', 1, 1)
ON DUPLICATE KEY UPDATE image_url = VALUES(image_url), is_primary = VALUES(is_primary), sort_order = VALUES(sort_order);

INSERT INTO spec_groups (id, name) VALUES
(1, 'CPU'),
(2, 'RAM'),
(3, 'Storage'),
(4, 'Display'),
(5, 'Graphics')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO specifications (product_id, spec_group_id, spec_name, spec_value, sort_order) VALUES
(1, 1, 'Chip', 'Apple M2', 1),
(1, 2, 'RAM', '8GB', 2),
(1, 3, 'SSD', '256GB', 3),
(2, 1, 'CPU', 'AMD Ryzen 5', 1),
(2, 2, 'RAM', '16GB', 2),
(3, 1, 'CPU', 'AMD Ryzen 7', 1),
(3, 5, 'GPU', 'NVIDIA RTX 3060', 2),
(4, 1, 'CPU', 'Intel Core i5', 1),
(4, 5, 'GPU', 'NVIDIA RTX 4060', 2),
(7, 5, 'Sensor', 'HERO 25K', 1),
(7, 4, 'Buttons', '11 nút lập trình', 2),
(8, 2, 'Dung lượng', '16GB', 1),
(8, 3, 'Tốc độ', '3200MHz', 2),
(9, 3, 'Dung lượng', '1TB', 1),
(9, 3, 'Giao tiếp', 'NVMe PCIe Gen4', 2)
ON DUPLICATE KEY UPDATE spec_value = VALUES(spec_value), sort_order = VALUES(sort_order);

INSERT INTO promotions (name, description, discount_type, discount_value, start_date, end_date, is_active) VALUES
('Khuyến mãi laptop', 'Giảm giá cho laptop và phụ kiện', 'percent', 20.00, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1)
ON DUPLICATE KEY UPDATE description = VALUES(description), discount_value = VALUES(discount_value), is_active = VALUES(is_active);

INSERT INTO promotion_products (promotion_id, product_id) VALUES
(1, 1),
(1, 2),
(1, 6)
ON DUPLICATE KEY UPDATE promotion_id = VALUES(promotion_id);

INSERT INTO banners (title, image_url, link_url, position, sort_order, is_active) VALUES
('Khuyến mãi hôm nay', 'assets/images/products/pc-gaming/gaming-pc-rtx-4060/01-main.png', '#promotions', 'home_top', 1, 1)
ON DUPLICATE KEY UPDATE image_url = VALUES(image_url), link_url = VALUES(link_url), sort_order = VALUES(sort_order), is_active = VALUES(is_active);

INSERT INTO homepage_sections (name, section_type, sort_order, is_active) VALUES
('Hero Banner', 'hero', 1, 1),
('Danh mục nổi bật', 'categories', 2, 1),
('Sản phẩm nổi bật', 'featured_products', 3, 1),
('Khuyến mãi', 'promotions', 4, 1),
('Tin tức', 'news', 5, 1)
ON DUPLICATE KEY UPDATE section_type = VALUES(section_type), sort_order = VALUES(sort_order), is_active = VALUES(is_active);
