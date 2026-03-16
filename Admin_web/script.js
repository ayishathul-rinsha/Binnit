// =============================================================
// script.js — Emptico Admin Dashboard  |  Firebase Firestore
// =============================================================

// ─── Auth State Observer ──────────────────────────────────────
firebase.auth().onAuthStateChanged(function (user) {
    if (user) {
        showDashboardForUser(user);
    } else {
        document.getElementById('loginPage').style.display = 'flex';
        document.getElementById('dashboard').classList.remove('active');
    }
});

// ─── Tab Switch (Sign In ↔ Sign Up) ──────────────────────────
function switchTab(tab) {
    const loginForm = document.getElementById('loginForm');
    const signupForm = document.getElementById('signupForm');
    const subtitle = document.getElementById('authSubtitle');
    const box = document.querySelector('.login-box');

    document.getElementById('loginError').textContent = '';
    document.getElementById('signupError').textContent = '';

    if (tab === 'signin') {
        loginForm.classList.remove('hidden');
        signupForm.classList.add('hidden');
        document.getElementById('tabSignIn').classList.add('active');
        document.getElementById('tabSignUp').classList.remove('active');
        subtitle.textContent = 'Admin Dashboard Login';
        box.classList.remove('signup-mode');
    } else {
        loginForm.classList.add('hidden');
        signupForm.classList.remove('hidden');
        document.getElementById('tabSignIn').classList.remove('active');
        document.getElementById('tabSignUp').classList.add('active');
        subtitle.textContent = 'Create Admin Account';
        box.classList.add('signup-mode');
    }
}

// ─── Sign Up ─────────────────────────────────────────────────
// Creates a Firebase Auth account AND stores the profile in
// Firestore → admins/{uid}
document.getElementById('signupForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const name = document.getElementById('signupName').value.trim();
    const email = document.getElementById('signupEmail').value.trim();
    const password = document.getElementById('signupPassword').value;
    const confirm = document.getElementById('signupConfirm').value;
    const btn = document.getElementById('signupBtn');
    const errorEl = document.getElementById('signupError');

    errorEl.textContent = '';

    // Client-side validation
    if (!name) { errorEl.textContent = 'Please enter your full name.'; return; }
    if (password.length < 6) { errorEl.textContent = 'Password must be at least 6 characters.'; return; }
    if (password !== confirm) { errorEl.textContent = 'Passwords do not match.'; return; }

    btn.disabled = true;
    btn.textContent = 'Creating account…';

    firebase.auth().createUserWithEmailAndPassword(email, password)
        .then(function (userCredential) {
            const user = userCredential.user;

            // Save display name to Firebase Auth profile
            const updateProfile = user.updateProfile({ displayName: name });

            // Save full profile to Firestore  →  users/{uid}  with role='admin'
            const saveDoc = db.collection('users').doc(user.uid).set({
                uid: user.uid,
                name: name,
                email: email,
                role: 'admin',
                status: 'Active',
                is_online: false,
                created_at: new Date().toISOString()
            });

            return Promise.all([updateProfile, saveDoc]);
        })
        .then(function () {
            btn.textContent = 'Create Account';
            btn.disabled = false;
            // onAuthStateChanged fires automatically → opens dashboard
        })
        .catch(function (error) {
            btn.disabled = false;
            btn.textContent = 'Create Account';
            const code = error.code;
            let msg = 'Sign up failed. Please try again.';
            if (code === 'auth/email-already-in-use') msg = 'This email is already registered. Please sign in instead.';
            else if (code === 'auth/invalid-email') msg = 'Please enter a valid email address.';
            else if (code === 'auth/weak-password') msg = 'Password is too weak. Use at least 6 characters.';
            else if (code === 'auth/network-request-failed') msg = 'Network error. Please check your connection.';
            errorEl.textContent = msg;
        });
});

// ─── Sign In ─────────────────────────────────────────────────
// Firebase Auth validates the credentials — we never store
// passwords ourselves.
document.getElementById('loginForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;
    const btn = document.getElementById('loginBtn');
    const errorEl = document.getElementById('loginError');

    errorEl.textContent = '';
    btn.disabled = true;
    btn.textContent = 'Signing in…';

    firebase.auth().signInWithEmailAndPassword(email, password)
        .then(function () {
            btn.textContent = 'Sign In';
            btn.disabled = false;
            // onAuthStateChanged handles the rest
        })
        .catch(function (error) {
            btn.disabled = false;
            btn.textContent = 'Sign In';
            const code = error.code;
            let msg = 'Login failed. Please try again.';
            if (code === 'auth/user-not-found' || code === 'auth/wrong-password' || code === 'auth/invalid-credential')
                msg = 'Invalid email or password. Please check and try again.';
            else if (code === 'auth/invalid-email') msg = 'Please enter a valid email address.';
            else if (code === 'auth/too-many-requests') msg = 'Too many failed attempts. Please wait and try again.';
            else if (code === 'auth/network-request-failed') msg = 'Network error. Please check your connection.';
            errorEl.textContent = msg;
        });
});

// ─── Show Dashboard After Auth ────────────────────────────────
function showDashboardForUser(user) {
    document.getElementById('loginPage').style.display = 'none';
    document.getElementById('dashboard').classList.add('active');

    // Prefer displayName (set during sign-up), fall back to email prefix
    const displayName = user.displayName
        || user.email.split('@')[0];
    document.getElementById('adminName').textContent =
        displayName.charAt(0).toUpperCase() + displayName.slice(1);

    showPage('overview', document.getElementById('nav-overview'));
    initFirebaseData();
}

// ─── Logout ──────────────────────────────────────────────────
function logout() {
    firebase.auth().signOut().then(function () {
        document.getElementById('dashboard').classList.remove('active');
        document.getElementById('loginPage').style.display = 'flex';
        document.getElementById('email').value = '';
        document.getElementById('password').value = '';
        document.getElementById('loginError').textContent = '';
    }).catch(function (err) { console.error('Logout error:', err); });
}

// ─── Page Navigation ─────────────────────────────────────────
const pageMap = {
    'overview': 'overviewPage',
    'bins': 'binsPage',
    'manual_bin': 'manual_binPage',
    'collections': 'collectionsPage',
    'routes': 'routesPage',
    'users': 'usersPage',
    'requests': 'requestsPage',
    'transactions': 'transactionsPage'
};

function showPage(pageName, navEl) {
    document.querySelectorAll('.page').forEach(p => p.classList.add('hidden'));
    document.querySelectorAll('.menu-item').forEach(m => m.classList.remove('active'));
    const page = document.getElementById(pageMap[pageName]);
    if (page) page.classList.remove('hidden');
    if (navEl) navEl.classList.add('active');
    closeSearchDropdown();
}

// ─── Global Search ───────────────────────────────────────────
const searchIndex = [
    { text: 'Dashboard Overview', page: 'overview', navId: 'nav-overview', icon: '📊', desc: 'System summary & stats' },
    { text: 'Smart Bin Management', page: 'bins', navId: 'nav-bins', icon: '🤖', desc: 'Premium IoT bins' },
    { text: 'Basic Bin Scheduled', page: 'manual_bin', navId: 'nav-manual_bin', icon: '🗑️', desc: 'Manual collection bins' },
    { text: 'Collections Log', page: 'collections', navId: 'nav-collections', icon: '🚛', desc: 'Completed & active collections' },
    { text: 'Route Management', page: 'routes', navId: 'nav-routes', icon: '🗺️', desc: 'Collection routes' },
    { text: 'User Management', page: 'users', navId: 'nav-users', icon: '👥', desc: 'All users & collectors' },
    { text: 'Collection Requests', page: 'requests', navId: 'nav-requests', icon: '📋', desc: 'Pending & resolved requests' },
    { text: 'Transactions', page: 'transactions', navId: 'nav-transactions', icon: '💳', desc: 'Payments & subscriptions' },
];

function globalSearch(query) {
    const dropdown = document.getElementById('searchResults');
    query = query.trim().toLowerCase();
    if (!query) { closeSearchDropdown(); return; }

    const matches = searchIndex.filter(i =>
        i.text.toLowerCase().includes(query) || i.desc.toLowerCase().includes(query)
    ).slice(0, 8);

    dropdown.innerHTML = matches.length === 0
        ? '<div class="search-no-result">No results found for "<b>' + escapeHtml(query) + '</b>"</div>'
        : matches.map(i => `
            <div class="search-result-item" onclick="navigateFromSearch('${i.page}','${i.navId}')">
                <span>${i.icon}</span>
                <span>${highlightMatch(i.text, query)}</span>
                <span class="result-page">${i.page.replace('_', ' ')}</span>
            </div>`).join('');

    dropdown.classList.remove('hidden');
}

function highlightMatch(text, query) {
    const idx = text.toLowerCase().indexOf(query);
    if (idx === -1) return escapeHtml(text);
    return escapeHtml(text.slice(0, idx))
        + '<strong style="color:#10b981">' + escapeHtml(text.slice(idx, idx + query.length)) + '</strong>'
        + escapeHtml(text.slice(idx + query.length));
}
function navigateFromSearch(page, navId) {
    showPage(page, document.getElementById(navId));
    document.getElementById('globalSearch').value = '';
    closeSearchDropdown();
}
function closeSearchDropdown() {
    const d = document.getElementById('searchResults');
    if (d) d.classList.add('hidden');
}
function escapeHtml(str) {
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
document.addEventListener('click', e => {
    if (!e.target.closest('.search-bar-wrapper')) closeSearchDropdown();
});

// ─── Table Filter ─────────────────────────────────────────────
// Supports both a <table id> (selects inner tbody rows)
// and a <tbody id> directly (selects its own rows)
function getRows(tableId) {
    const el = document.getElementById(tableId);
    if (!el) return [];
    // If it's a tbody itself, select its rows directly
    const selector = el.tagName === 'TBODY' ? '#' + tableId + ' tr' : '#' + tableId + ' tbody tr';
    return Array.from(document.querySelectorAll(selector));
}
function filterTable(input, tableId) {
    const q = input.value.toLowerCase();
    getRows(tableId).forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
function filterBySelect(select, tableId, colIndex) {
    const value = select.value.toLowerCase();
    getRows(tableId).forEach(row => {
        const cell = row.cells[colIndex];
        if (!cell) { row.style.display = ''; return; }
        row.style.display = (!value || cell.textContent.toLowerCase().includes(value)) ? '' : 'none';
    });
}

// ─── Action Button Handlers ───────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {
    document.addEventListener('click', function (e) {
        const btn = e.target.closest('button');
        if (!btn) return;
        const text = btn.textContent.trim();

        if (btn.classList.contains('btn-primary') && text === 'View') {
            const row = btn.closest('tr');
            alert(`📋 Viewing details for: ${row ? row.cells[0].textContent.trim() : 'item'}`);
        }
        if (btn.classList.contains('btn-success') && text === 'Collect') {
            const row = btn.closest('tr');
            const label = row ? row.cells[0].textContent.trim() : 'bin';
            if (confirm(`🚛 Schedule collection for ${label}?`)) alert(`✅ Collection scheduled for ${label}`);
        }
        if (btn.classList.contains('btn-success') && text === 'Assign') {
            const row = btn.closest('tr');
            const reqId = row ? row.cells[0].textContent.trim() : 'request';
            if (confirm(`Assign a collector to ${reqId}?`)) {
                row.remove(); updateRequestBadge();
                alert(`✅ Collector assigned to ${reqId}`);
            }
        }
        if (btn.classList.contains('btn-danger') && text === 'Delete') {
            const row = btn.closest('tr');
            const name = row ? row.cells[0].textContent.trim() : 'user';
            if (confirm(`⚠️ Are you sure you want to delete ${name}?`)) {
                row.remove(); alert(`🗑️ ${name} has been removed.`);
            }
        }
        if (btn.classList.contains('btn-danger') && text === 'Cancel') {
            const row = btn.closest('tr');
            const reqId = row ? row.cells[0].textContent.trim() : 'request';
            if (confirm(`Cancel ${reqId}?`)) {
                row.remove(); updateRequestBadge();
                alert(`❌ ${reqId} has been cancelled.`);
            }
        }
        if (btn.classList.contains('btn-primary') && text === 'Edit') {
            const row = btn.closest('tr');
            const name = row ? row.cells[0].textContent.trim() : 'user';
            alert(`✏️ Editing profile for: ${name}\n(Full editor coming soon!)`);
        }
        if (btn.classList.contains('btn-warning') && text === 'Report') {
            const row = btn.closest('tr');
            alert(`📊 Generating report for ${row ? row.cells[0].textContent.trim() : 'item'}…`);
        }
        if (btn.classList.contains('btn-warning') && text === 'Edit') {
            const row = btn.closest('tr');
            alert(`🗺️ Opening route editor for ${row ? row.cells[0].textContent.trim() : 'route'}…`);
        }
        if (btn.classList.contains('btn-primary') && text === 'View Map') {
            const row = btn.closest('tr');
            const name = row ? row.cells[1].textContent.trim() : 'route';
            alert(`🗺️ Opening map for: ${name}\n(Map integration coming soon!)`);
        }
    });
});

// ─── Request Badge ────────────────────────────────────────────
function updateRequestBadge() {
    const remaining = document.querySelectorAll('#requestsTable tbody tr:not(.loading-row)').length;
    const badge = document.getElementById('requestsBadge');
    if (badge) badge.textContent = remaining;
}

// ─── Firestore Live Data ──────────────────────────────────────
// All tables listen with onSnapshot for real-time updates.
// Structure mirrors Firestore collection names.
function initFirebaseData() {

    const getFillColor = l => l >= 80 ? '#ef4444' : l >= 60 ? '#f59e0b' : '#10b981';

    // Helper: set table to loading state
    function setLoading(tbodyId, cols) {
        const el = document.getElementById(tbodyId);
        if (!el) return null;
        const tbody = el.tagName === 'TBODY' ? el : el.querySelector('tbody');
        if (tbody) tbody.innerHTML = `<tr class="loading-row"><td colspan="${cols}">Loading from Firestore…</td></tr>`;
        return tbody;
    }

    // Helper: listen to a Firestore collection and render rows
    function listenCollection(collectionName, tbodyId, cols, rowBuilder) {
        const tbody = setLoading(tbodyId, cols);
        db.collection(collectionName).onSnapshot(snapshot => {
            if (!tbody) return;
            tbody.innerHTML = '';
            if (snapshot.empty) {
                tbody.innerHTML = `<tr class="loading-row"><td colspan="${cols}">No data found in Firestore.</td></tr>`;
                return;
            }
            snapshot.forEach(doc => {
                const tr = rowBuilder(doc.id, doc.data());
                if (tr) tbody.appendChild(tr);
            });
        }, err => {
            console.error(`Error fetching ${collectionName}:`, err);
            if (tbody) tbody.innerHTML = `<tr class="loading-row"><td colspan="${cols}">Error loading data.</td></tr>`;
        });
    }

    // ── 1. Smart Bins ─────────────────────────────────────────
    const smartTbody = setLoading('smartBinsTable', 6);
    const activityTbody = setLoading('binActivityTable', 5);

    db.collection('smart_bins').onSnapshot(snapshot => {
        if (smartTbody) smartTbody.innerHTML = '';
        if (activityTbody) activityTbody.innerHTML = '';

        if (snapshot.empty) {
            if (smartTbody) smartTbody.innerHTML = '<tr class="loading-row"><td colspan="6">No smart bins in Firestore.</td></tr>';
            if (activityTbody) activityTbody.innerHTML = '<tr class="loading-row"><td colspan="5">No activity yet.</td></tr>';
            return;
        }

        snapshot.forEach(doc => {
            const bin = doc.data();
            const fillLvl = bin.fillLevel || 0;
            const fillHTML = `<div class="fill-bar"><div class="fill-inner" style="width:${fillLvl}%;background:${getFillColor(fillLvl)}"></div><span>${fillLvl}%</span></div>`;
            const statusHTML = `<span class="status ${bin.status === 'Online' ? 'online' : 'offline'}">${bin.status || 'Unknown'}</span>`;

            if (smartTbody) {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${bin.id || doc.id}</td>
                    <td>${bin.location || 'Unknown'}</td>
                    <td>${bin.type || 'General'}</td>
                    <td>${fillHTML}</td>
                    <td>${statusHTML}</td>
                    <td>
                        <button class="btn btn-primary"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>View</button>
                        <button class="btn btn-success"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>Collect</button>
                    </td>`;
                smartTbody.appendChild(tr);
            }

            if (activityTbody) {
                const trA = document.createElement('tr');
                trA.innerHTML = `
                    <td>${bin.id || doc.id}</td>
                    <td>${bin.location || 'Unknown'}</td>
                    <td>${fillHTML}</td>
                    <td>${statusHTML}</td>
                    <td>${bin.lastUpdated || 'Just now'}</td>`;
                activityTbody.appendChild(trA);
            }
        });
    });

    // ── 2. Normal Bins ────────────────────────────────────────
    const normalTbody = setLoading('normalBinsTable', 6);
    const overviewTbody = setLoading('overviewNormalBinsTable', 5);

    db.collection('normal_bins').onSnapshot(snapshot => {
        if (normalTbody) normalTbody.innerHTML = '';
        if (overviewTbody) overviewTbody.innerHTML = '';

        if (snapshot.empty) {
            if (normalTbody) normalTbody.innerHTML = '<tr class="loading-row"><td colspan="6">No normal bins in Firestore.</td></tr>';
            if (overviewTbody) overviewTbody.innerHTML = '<tr class="loading-row"><td colspan="5">No data found.</td></tr>';
            return;
        }

        snapshot.forEach(doc => {
            const bin = doc.data();
            const sc = bin.status === 'Collected' ? 'online' : bin.status === 'Pending' ? 'pending' : 'offline';

            if (normalTbody) {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${bin.location || 'Unknown'}</td>
                    <td>${bin.type || 'General'}</td>
                    <td>${bin.scheduledDate || '-'}</td>
                    <td>${bin.scheduledTime || '-'}</td>
                    <td><span class="status ${sc}">${bin.status || 'Pending'}</span></td>
                    <td>
                        <button class="btn btn-primary"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>View</button>
                        <button class="btn btn-success"><svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>Collect</button>
                    </td>`;
                normalTbody.appendChild(tr);
            }

            if (overviewTbody) {
                const trO = document.createElement('tr');
                trO.innerHTML = `
                    <td>${bin.location || 'Unknown'}</td>
                    <td>${bin.type || 'General'}</td>
                    <td>${bin.scheduledDate || '-'}</td>
                    <td>${bin.collector || 'Unassigned'}</td>
                    <td><span class="status ${sc}">${bin.status || 'Pending'}</span></td>`;
                overviewTbody.appendChild(trO);
            }
        });
    });

    // ── 3. Collections Log — Collectors (users where role='collector') ─
    const collLogTbody = setLoading('collectionsTableBody', 9);
    db.collection('users')
        .where('role', 'in', ['collector', 'Collector', 'COLLECTOR'])
        .onSnapshot(snapshot => {
            if (!collLogTbody) return;
            collLogTbody.innerHTML = '';
            if (snapshot.empty) {
                collLogTbody.innerHTML = '<tr class="loading-row"><td colspan="9">No collectors found in Firestore.</td></tr>';
                return;
            }
            snapshot.forEach(doc => {
                const u = doc.data();

                // Map any status value → CSS class
                const statusLower = (u.status || '').toLowerCase();
                const sc = (statusLower === 'approved' || statusLower === 'active') ? 'online'
                    : statusLower === 'pending' ? 'pending' : 'offline';

                // Vehicle type from nested object
                const vehicleType = (u.vehicle && u.vehicle.vehicle_type)
                    ? u.vehicle.vehicle_type.replace(/_/g, ' ')
                    : '-';

                // Date — prefer created_at, fall back to joined
                const dateStr = u.joined || (u.created_at
                    ? new Date(u.created_at).toLocaleDateString('en-GB')
                    : '-');

                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${u.name || '-'}</td>
                    <td>${u.email || '-'}</td>
                    <td>${u.phone || '-'}</td>
                    <td>${u.city || u.zone || '-'}</td>
                    <td><span class="status ${sc}">${u.status || '-'}</span></td>
                    <td>${u.rating !== undefined ? u.rating : '-'}</td>
                    <td>${u.total_pickups !== undefined ? u.total_pickups : '-'}</td>
                    <td>${vehicleType}</td>
                    <td>
                        <button class="btn btn-primary"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>View</button>
                        <button class="btn btn-warning"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>Edit</button>
                    </td>`;
                collLogTbody.appendChild(tr);
            });
        }, err => {
            console.error('Error fetching collectors:', err);
            if (collLogTbody) collLogTbody.innerHTML = `<tr class="loading-row"><td colspan="9">⚠️ ${err.message}</td></tr>`;
        });



    // ── 4. Routes ─────────────────────────────────────────────
    listenCollection('routes', 'routesTable', 8, (id, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Active' ? 'online' : item.status === 'In Progress' ? 'pending' : 'offline';
        tr.innerHTML = `
            <td>${item.id || id}</td><td>${item.name || '-'}</td><td>${item.zone || '-'}</td>
            <td>${item.bins || 0}</td><td>${item.distance || 0}</td><td>${item.assignedCollector || '-'}</td>
            <td><span class="status ${s}">${item.status || 'Idle'}</span></td>
            <td>
                <button class="btn btn-primary"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>View Map</button>
                <button class="btn btn-warning"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>Edit</button>
            </td>`;
        return tr;
    });

    // ── 5 & 6. Users — table + live stat counts ───────────────
    // Single snapshot covers all users (all roles) — counts derived client-side
    const usersTbody = setLoading('usersTableBody', 7);

    db.collection('users').onSnapshot(snapshot => {
        if (!usersTbody) return;
        usersTbody.innerHTML = '';

        // ── Count accumulators ──────────────────────────────
        let total = 0;
        let active = 0;
        let premium = 0;
        let collectors = 0;

        if (snapshot.empty) {
            usersTbody.innerHTML = '<tr class="loading-row"><td colspan="7">No users found in Firestore.</td></tr>';
        } else {
            snapshot.forEach(doc => {
                const u = doc.data();
                const role = (u.role || '').toLowerCase();

                // ── Tally counts ───────────────────────────
                total++;
                const statusL = (u.status || '').toLowerCase();
                if (statusL === 'active' || statusL === 'approved') active++;
                const planL = (u.plan || '').toLowerCase();
                if (planL === 'premium') premium++;
                if (role === 'collector') collectors++;

                // ── Build table row ────────────────────────
                const sc = (statusL === 'active' || statusL === 'approved') ? 'online'
                    : statusL === 'pending' ? 'pending' : 'offline';
                const planLbl = planL === 'premium' ? '★ Premium' : (u.plan || 'Free');

                // Date: prefer joined, fall back to created_at
                const dateStr = u.joined || (u.created_at
                    ? new Date(u.created_at).toLocaleDateString('en-GB')
                    : '-');

                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${u.name || '-'}</td>
                    <td>${u.email || '-'}</td>
                    <td>${u.role || 'user'}</td>
                    <td>${planLbl}</td>
                    <td><span class="status ${sc}">${u.status || '-'}</span></td>
                    <td>${dateStr}</td>
                    <td>
                        <button class="btn btn-warning"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>Edit</button>
                        <button class="btn btn-danger"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>Delete</button>
                    </td>`;
                usersTbody.appendChild(tr);
            });
        }

        // ── Update stat cards ──────────────────────────────
        const totalEl = document.getElementById('statTotalUsers');
        const activeEl = document.getElementById('statActiveUsers');
        const rateEl = document.getElementById('statActiveRate');
        const premiumEl = document.getElementById('statPremiumUsers');
        const collectEl = document.getElementById('statCollectors');
        const totalChange = document.getElementById('statTotalUsersChange');

        if (totalEl) totalEl.textContent = total.toLocaleString();
        if (activeEl) activeEl.textContent = active.toLocaleString();
        if (collectEl) collectEl.textContent = collectors.toLocaleString();
        if (premiumEl) premiumEl.textContent = premium.toLocaleString();

        const rate = total > 0 ? Math.round((active / total) * 100) : 0;
        if (rateEl) rateEl.textContent = `${rate}% active rate`;
        if (totalChange) totalChange.textContent = `${total} total in system`;

    }, err => {
        console.error('Error fetching users:', err);
        if (usersTbody) usersTbody.innerHTML = `<tr class="loading-row"><td colspan="7">⚠️ ${err.message}</td></tr>`;
    });



    // ── 7. Requests ───────────────────────────────────────────
    listenCollection('requests', 'requestsTable', 7, (id, item) => {
        const tr = document.createElement('tr');
        const pCls = item.priority === 'High' ? 'high' : item.priority === 'Medium' ? 'medium' : 'low';
        tr.innerHTML = `
            <td>${item.id || id}</td><td>${item.location || '-'}</td>
            <td><span class="priority ${pCls}">${item.priority || 'Low'}</span></td>
            <td>${item.user || '-'}</td>
            <td><span class="status pending">${item.status || 'Pending'}</span></td>
            <td>${item.date || '-'}</td>
            <td>
                <button class="btn btn-success"><svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><polyline points="17 11 19 13 23 9"/></svg>Assign</button>
                <button class="btn btn-danger"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>Cancel</button>
            </td>`;
        setTimeout(updateRequestBadge, 50);
        return tr;
    });

    // ── 8. Resolved Requests ──────────────────────────────────
    listenCollection('resolved_requests', 'resolvedRequestsTable', 5, (id, item) => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${item.id || id}</td><td>${item.location || '-'}</td>
            <td>${item.assignedTo || '-'}</td><td>${item.resolvedOn || '-'}</td>
            <td><span class="status online">Resolved</span></td>`;
        return tr;
    });

    // ── 9. Transactions ───────────────────────────────────────
    listenCollection('transactions', 'txHistoryTable', 7, (id, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Success' ? 'online' : item.status === 'Pending' ? 'pending' : 'offline';
        tr.innerHTML = `
            <td>${item.id || id}</td><td>${item.name || '-'}</td><td>${item.email || '-'}</td>
            <td>${item.type || '-'}</td>
            <td><span class="status ${s}">${item.status || 'Pending'}</span></td>
            <td>${item.amount || '-'}</td><td>${item.date || '-'}</td>`;
        return tr;
    });

    // ── 10. Subscriptions ─────────────────────────────────────
    listenCollection('subscriptions', 'subscriptionsTable', 7, (id, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Active' ? 'online' : item.status === 'Pending' ? 'pending' : 'offline';
        const planStyle = item.plan === 'Premium' ? 'border-color:#7c3aed;color:#7c3aed' : '';
        tr.innerHTML = `
            <td>${item.id || id}</td><td>${item.user || '-'}</td>
            <td><span class="badge-label" style="${planStyle}">${item.plan || 'Free'}</span></td>
            <td>${item.started || '-'}</td>
            <td><span class="status ${s}">${item.status || 'Active'}</span></td>
            <td>${item.renewal || '—'}</td><td>${item.amount || '-'}</td>`;
        return tr;
    });
}

console.log('✅ Emptico Admin Dashboard initialized!');