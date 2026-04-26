document.addEventListener("DOMContentLoaded", async () => {
  const yearElement = document.querySelector("[data-year]");

  if (yearElement) {
    yearElement.textContent = new Date().getFullYear();
  }

  const loadComponent = async (selector, url) => {
    const container = document.querySelector(selector);

    if (!container) {
      return;
    }

    try {
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error(`Failed to load ${url}: ${response.status}`);
      }

      container.innerHTML = await response.text();
    } catch (error) {
      console.error(error);
    }
  };

  const formatCurrency = (value) => {
    if (value === null || value === undefined) {
      return "Liên hệ";
    }

    return Number(value).toLocaleString("vi-VN") + "đ";
  };

  const createCategorySection = (category, products) => `
    <section class="section" id="category-${category.slug}">
      <div class="container">
        <div class="section-heading">
          <h2>${category.name}</h2>
          <p>${category.description || "Danh mục sản phẩm của cửa hàng."}</p>
        </div>

        <div class="product-grid">
          ${
            products.length
              ? products.map(createProductCard).join("")
              : `<div class="card">Chưa có sản phẩm nào cho danh mục này.</div>`
          }
        </div>
      </div>
    </section>
  `;

  const createProductCard = (product) => `
    <article class="product-card">
      <span class="product-tag">${product.category_name || "Sản phẩm"}</span>
      <div class="product-image" aria-hidden="true">
        ${product.image_url ? `<img src="${product.image_url}" alt="${product.name}" />` : ""}
      </div>
      <h3>${product.name}</h3>
      <p>${product.short_description || "Sản phẩm nổi bật từ MySQL."}</p>
      <div class="product-pricing">
        <strong>${formatCurrency(product.price)}</strong>
        ${product.original_price && Number(product.original_price) > Number(product.price) ? `<span class="sale-price">${formatCurrency(product.original_price)}</span>` : ""}
      </div>
      <div class="product-rating">★★★★★ ${product.stock_quantity > 0 ? "Còn hàng" : "Hết hàng"}</div>
      <div class="product-actions">
        <a class="btn" href="#home">Thêm vào giỏ</a>
        <a class="btn btn-secondary" href="#home">Xem chi tiết</a>
      </div>
    </article>
  `;

  const renderHomepageData = async () => {
    const productsGrid = document.querySelector("#featured-products-grid");
    const categoriesContainer = document.querySelector("#categories-container");

    if (!productsGrid || !categoriesContainer) {
      return;
    }

    productsGrid.innerHTML = `<div class="card">Đang tải sản phẩm...</div>`;

    try {
      const response = await fetch("/api/homepage");

      if (!response.ok) {
        throw new Error(`Failed to load homepage data: ${response.status}`);
      }

      const payload = await response.json();
      const categories = Array.isArray(payload.categories) ? payload.categories : [];
      const products = Array.isArray(payload.products) ? payload.products : [];

      const groupedProducts = categories.map((category) => {
        const productsInCategory = products.filter((product) => product.category_slug === category.slug);
        return createCategorySection(category, productsInCategory);
      });

      categoriesContainer.innerHTML = groupedProducts.length
        ? groupedProducts.join("")
        : `
          <div class="container">
            <div class="card">Chưa có danh mục nào trong MySQL.</div>
          </div>
        `;

      productsGrid.innerHTML = products.length
        ? products.map(createProductCard).join("")
        : `<div class="card">Chưa có sản phẩm nào trong MySQL.</div>`;
    } catch (error) {
      console.error(error);
      categoriesContainer.innerHTML = `
        <div class="container">
          <div class="card">Không tải được danh mục từ MySQL.</div>
        </div>
      `;
      productsGrid.innerHTML = `<div class="card">Không tải được sản phẩm từ MySQL.</div>`;
    }
  };

  await Promise.all([
    loadComponent("#site-header", "components/header/header.html"),
    loadComponent("#site-footer", "components/footer/footer.html"),
    renderHomepageData()
  ]);

  const siteHeader = document.querySelector(".site-header");
  const navToggle = document.querySelector(".nav-toggle");
  const mainNavigation = document.querySelector("#main-navigation");
  const navOverlay = document.querySelector(".nav-overlay");
  const navClose = document.querySelector(".nav-close");

  if (siteHeader) {
    let lastScrollY = window.scrollY;
    let ticking = false;

    const updateHeaderState = () => {
      const currentScrollY = window.scrollY;
      const scrollingDown = currentScrollY > lastScrollY;
      const pastThreshold = currentScrollY > 80;

      siteHeader.classList.toggle("is-scrolled", currentScrollY > 8);
      siteHeader.classList.toggle("is-hidden", scrollingDown && pastThreshold);
      lastScrollY = currentScrollY;
      ticking = false;
    };

    updateHeaderState();
    window.addEventListener(
      "scroll",
      () => {
        if (!ticking) {
          window.requestAnimationFrame(updateHeaderState);
          ticking = true;
        }
      },
      { passive: true }
    );
  }

  if (navToggle && mainNavigation && navOverlay && navClose) {
    const openMenu = () => {
      navToggle.setAttribute("aria-expanded", "true");
      mainNavigation.classList.add("is-open");
      navOverlay.hidden = false;
      document.body.classList.add("nav-open");
    };

    const closeMenu = () => {
      navToggle.setAttribute("aria-expanded", "false");
      mainNavigation.classList.remove("is-open");
      navOverlay.hidden = true;
      document.body.classList.remove("nav-open");
    };

    navToggle.addEventListener("click", () => {
      const isExpanded = navToggle.getAttribute("aria-expanded") === "true";
      if (isExpanded) {
        closeMenu();
      } else {
        openMenu();
      }
    });

    navClose.addEventListener("click", closeMenu);
    navOverlay.addEventListener("click", closeMenu);

    mainNavigation.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", closeMenu);
    });
  }
});
