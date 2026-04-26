const express = require("express");
const path = require("path");
const fs = require("fs/promises");
const db = require("./db");

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || "0.0.0.0";
const PUBLIC_DIR = __dirname;

const MIME_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".sql": "text/plain; charset=utf-8"
};

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/api/categories", async (req, res) => {
  try {
    const [rows] = await db.query(
      `
      SELECT id, name, slug, description, image_url
      FROM categories
      WHERE is_active = 1
      ORDER BY sort_order ASC, id ASC
      `
    );

    res.json({ data: rows });
  } catch (error) {
    console.error("GET /api/categories failed:", error);
    res.status(500).json({ message: "Failed to load categories" });
  }
});

app.get("/api/products/featured", async (req, res) => {
  try {
    const [rows] = await db.query(
      `
      SELECT
        p.id,
        p.name,
        p.slug,
        p.short_description,
        p.is_featured,
        c.name AS category_name,
        c.slug AS category_slug,
        b.name AS brand_name,
        COALESCE(v.sale_price, v.price) AS price,
        v.price AS original_price,
        v.stock_quantity,
        (
          SELECT pi.image_url
          FROM product_images pi
          WHERE pi.product_id = p.id
          ORDER BY pi.is_primary DESC, pi.sort_order ASC, pi.id ASC
          LIMIT 1
        ) AS image_url
      FROM products p
      INNER JOIN categories c ON c.id = p.category_id
      LEFT JOIN brands b ON b.id = p.brand_id
      INNER JOIN product_variants v ON v.product_id = p.id AND v.status = 'active'
      WHERE p.status = 'active' AND p.is_featured = 1
      GROUP BY p.id, p.name, p.slug, p.short_description, p.is_featured, c.name, c.slug, b.name, price, original_price, v.stock_quantity
      ORDER BY p.created_at DESC
      LIMIT 12
      `
    );

    res.json({ data: rows });
  } catch (error) {
    console.error("GET /api/products/featured failed:", error);
    res.status(500).json({ message: "Failed to load featured products" });
  }
});

app.get("/api/homepage", async (req, res) => {
  try {
    const [categories] = await db.query(
      `
      SELECT id, name, slug, description, image_url
      FROM categories
      WHERE is_active = 1
      ORDER BY sort_order ASC, id ASC
      
      `
    );

    const [products] = await db.query(
      `
      SELECT
        p.id,
        p.name,
        p.slug,
        p.short_description,
        c.name AS category_name,
        c.slug AS category_slug,
        COALESCE(v.sale_price, v.price) AS price,
        v.price AS original_price,
        v.stock_quantity,
        (
          SELECT pi.image_url
          FROM product_images pi
          WHERE pi.product_id = p.id
          ORDER BY pi.is_primary DESC, pi.sort_order ASC, pi.id ASC
          LIMIT 1
        ) AS image_url
      FROM products p
      INNER JOIN categories c ON c.id = p.category_id
      INNER JOIN product_variants v ON v.product_id = p.id AND v.status = 'active'
      WHERE p.status = 'active'
      ORDER BY c.sort_order ASC, c.id ASC, p.is_featured DESC, p.is_hot DESC, p.created_at DESC
      `
    );

    res.json({ categories, products });
  } catch (error) {
    console.error("GET /api/homepage failed:", error);
    res.status(500).json({ message: "Failed to load homepage data" });
  }
});

app.use(express.static(PUBLIC_DIR));

app.get("/", async (req, res) => {
  try {
    const filePath = path.join(PUBLIC_DIR, "index.html");
    const html = await fs.readFile(filePath, "utf8");
    res.type("html").send(html);
  } catch (error) {
    console.error("Failed to serve index.html:", error);
    res.status(500).send("Internal Server Error");
  }
});

app.use((req, res) => {
  res.status(404).send("Not found");
});

app.listen(PORT, HOST, () => {
  console.log(`Server running at http://${HOST}:${PORT}`);
});
