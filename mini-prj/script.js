// script.js

// Login functionality
document.getElementById('loginForm').addEventListener('submit', function(e) {
    e.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    // Simple authentication (in production, use proper backend authentication)
    if (email && password) {
        // Hide login page
        document.getElementById('loginPage').style.display = 'none';
        
        // Show dashboard
        document.getElementById('dashboard').classList.add('active');
        
        // Set admin name
        const adminName = email.split('@')[0];
        document.getElementById('adminName').textContent = adminName.charAt(0).toUpperCase() + adminName.slice(1);
    } else {
        alert('Please enter valid credentials');
    }
});

// Page navigation function
function showPage(pageName) {
    // Hide all pages
    const pages = document.querySelectorAll('.page');
    pages.forEach(page => page.classList.add('hidden'));

    // Remove active class from all menu items
    const menuItems = document.querySelectorAll('.menu-item');
    menuItems.forEach(item => item.classList.remove('active'));

    // Page mapping
    const pageMap = {
        'overview': 'overviewPage',
        'bins': 'binsPage',
        'users': 'usersPage',
        'requests': 'requestsPage',
        'collections': 'overviewPage',  // Can create separate page later
        'routes': 'overviewPage',        // Can create separate page later
        'analytics': 'overviewPage'      // Can create separate page later
    };

    // Show selected page
    const pageId = pageMap[pageName];
    if (pageId) {
        document.getElementById(pageId).classList.remove('hidden');
    }

    // Add active class to clicked menu item
    event.currentTarget.classList.add('active');
}

// Logout functionality
function logout() {
    // Hide dashboard
    document.getElementById('dashboard').classList.remove('active');
    
    // Show login page
    document.getElementById('loginPage').style.display = 'flex';
    
    // Clear form fields
    document.getElementById('email').value = '';
    document.getElementById('password').value = '';
}

// Simulate real-time bin fill level updates
function updateBinLevels() {
    const fillLevels = document.querySelectorAll('#binActivityTable td:nth-child(3)');
    
    fillLevels.forEach(cell => {
        const currentLevel = parseInt(cell.textContent);
        
        // Randomly increase fill level (simulate bins filling up)
        if (currentLevel < 95) {
            const increase = Math.floor(Math.random() * 3);
            const newLevel = Math.min(currentLevel + increase, 100);
            cell.textContent = newLevel + '%';
            
            // Change status to offline if level is very high (simulate alert)
            if (newLevel >= 95) {
                const statusCell = cell.nextElementSibling;
                statusCell.innerHTML = '<span class="status offline">Critical</span>';
            }
        }
    });
}

// Update last updated time
function updateTimestamps() {
    const timestamps = document.querySelectorAll('#binActivityTable td:nth-child(5)');
    
    timestamps.forEach((cell, index) => {
        const times = ['1 min ago', '3 mins ago', '5 mins ago', '10 mins ago'];
        cell.textContent = times[Math.floor(Math.random() * times.length)];
    });
}

// Start real-time updates when dashboard is loaded
setInterval(updateBinLevels, 5000);  // Update every 5 seconds
setInterval(updateTimestamps, 10000); // Update every 10 seconds

// Update statistics dynamically
function updateStatistics() {
    const statValues = document.querySelectorAll('.stat-card .value');
    
    // Simulate data changes
    statValues.forEach((value, index) => {
        if (index === 1) { // Active Collections
            const current = parseInt(value.textContent);
            const change = Math.random() > 0.5 ? 1 : -1;
            const newValue = Math.max(0, current + change);
            value.textContent = newValue;
        }
    });
}

setInterval(updateStatistics, 15000); // Update stats every 15 seconds

// Add button click handlers
document.addEventListener('DOMContentLoaded', function() {
    // Add click handlers for action buttons
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('btn-primary') && e.target.textContent === 'View') {
            const row = e.target.closest('tr');
            const binId = row.cells[0].textContent;
            alert(`Viewing details for ${binId}`);
        }
        
        if (e.target.classList.contains('btn-success') && e.target.textContent === 'Collect') {
            const row = e.target.closest('tr');
            const binId = row.cells[0].textContent;
            if (confirm(`Schedule collection for ${binId}?`)) {
                alert(`Collection scheduled for ${binId}`);
            }
        }
        
        if (e.target.classList.contains('btn-success') && e.target.textContent === 'Assign') {
            const row = e.target.closest('tr');
            const requestId = row.cells[0].textContent;
            if (confirm(`Assign collector to ${requestId}?`)) {
                row.remove();
                alert(`Collector assigned to ${requestId}`);
            }
        }
        
        if (e.target.classList.contains('btn-danger') && e.target.textContent === 'Delete') {
            const row = e.target.closest('tr');
            const userName = row.cells[0].textContent;
            if (confirm(`Are you sure you want to delete ${userName}?`)) {
                row.remove();
                alert(`${userName} has been deleted`);
            }
        }
        
        if (e.target.classList.contains('btn-danger') && e.target.textContent === 'Cancel') {
            const row = e.target.closest('tr');
            const requestId = row.cells[0].textContent;
            if (confirm(`Cancel ${requestId}?`)) {
                row.remove();
                alert(`${requestId} has been cancelled`);
            }
        }
    });
});

// Notification system
function checkNotifications() {
    const notifications = document.querySelectorAll('.badge');
    
    // Simulate notification updates
    notifications.forEach(badge => {
        const current = parseInt(badge.textContent);
        if (Math.random() > 0.7) {
            badge.textContent = current + 1;
        }
    });
}

setInterval(checkNotifications, 30000); // Check every 30 seconds

console.log('SmartBin Admin Dashboard initialized successfully!');