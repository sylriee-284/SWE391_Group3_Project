<%@ page language="java" pageEncoding="UTF-8" %>
<style>
    /* Navbar */
    .navbar {
        width: 100%;
        background-color: #2c3e50;
        color: white;
        padding: 10px 20px;
        text-align: left;
        position: fixed;
        top: 0;
        left: 0;
        z-index: 1000;
    }

    .navbar .menu-toggle {
        font-size: 24px;
        color: white;
        background-color: transparent;
        border: none;
        cursor: pointer;
        display: inline-block;
        transition: background-color 0.3s, padding 0.3s;
    }

    .navbar .menu-toggle:hover {
        background-color: #34495e;
        padding: 8px 12px;
        border-radius: 5px;
    }
</style>

<!-- Navbar -->
<div class="navbar">
    <!-- Nút Toggle Sidebar chỉ còn biểu tượng ☰ -->
    <button class="menu-toggle" onclick="toggleSidebar()">☰</button>
</div>
