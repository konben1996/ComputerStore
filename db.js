const mysql = require("mysql2");

const pool = mysql.createPool({
  host: process.env.MYSQL_HOST || "mysql",
  port: Number(process.env.MYSQL_PORT || 3306),
  user: process.env.MYSQL_USER || "computer_store",
  password: process.env.MYSQL_PASSWORD || "computer_store",
  database: process.env.MYSQL_DATABASE || "computer_store",
  charset: "utf8mb4",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
}).promise();

module.exports = pool;
