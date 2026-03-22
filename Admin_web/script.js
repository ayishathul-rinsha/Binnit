// =============================================================
// script.js â€” Emptico Admin Dashboard  |  Firebase Firestore
// =============================================================

// â”€â”€â”€ Auth State Observer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
firebase.auth().onAuthStateChanged(function (user) {
    if (user) {
        showDashboardForUser(user);
    } else {
        document.getElementById('loginPage').style.display = 'flex';
        document.getElementById('dashboard').classList.remove('active');
    }
});

// â”€â”€â”€ Tab Switch (Sign In â†” Sign Up) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€ Sign Up â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Creates a Firebase Auth account AND stores the profile in
// Firestore â†’ admins/{uid}
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
    btn.textContent = 'Creating accountâ€¦';

    firebase.auth().createUserWithEmailAndPassword(email, password)
        .then(function (userCredential) {
            const user = userCredential.user;

            // Save display name to Firebase Auth profile
            const updateProfile = user.updateProfile({ displayName: name });

            // Save full profile to Firestore  â†’  admins/{uid}  with role='admin'
            const saveDoc = db.collection('admins').doc(user.uid).set({
                uid: user.uid,
                name: name,
                email: email,
                role: 'admin',
                status: 'Active',
                created_at: new Date().toISOString()
            });

            return Promise.all([updateProfile, saveDoc]);
        })
        .then(function () {
            btn.textContent = 'Create Account';
            btn.disabled = false;
            // onAuthStateChanged fires automatically â†’ opens dashboard
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

// â”€â”€â”€ Sign In â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Firebase Auth validates the credentials â€” we never store
// passwords ourselves.
document.getElementById('loginForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;
    const btn = document.getElementById('loginBtn');
    const errorEl = document.getElementById('loginError');

    errorEl.textContent = '';
    btn.disabled = true;
    btn.textContent = 'Signing inâ€¦';

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

// â”€â”€â”€ Show Dashboard After Auth â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€ Logout â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function logout() {
    firebase.auth().signOut().then(function () {
        document.getElementById('dashboard').classList.remove('active');
        document.getElementById('loginPage').style.display = 'flex';
        document.getElementById('email').value = '';
        document.getElementById('password').value = '';
        document.getElementById('loginError').textContent = '';
    }).catch(function (err) { console.error('Logout error:', err); });
}

// â”€â”€â”€ Page Navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€ Global Search â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const searchIndex = [
    { text: 'Dashboard Overview', page: 'overview', navId: 'nav-overview', icon: 'ðŸ“Š', desc: 'System summary & stats' },
    { text: 'Smart Bin Management', page: 'bins', navId: 'nav-bins', icon: 'ðŸ¤–', desc: 'Premium IoT bins' },
    { text: 'Basic Bin Scheduled', page: 'manual_bin', navId: 'nav-manual_bin', icon: 'ðŸ—‘ï¸', desc: 'Manual collection bins' },
    { text: 'Collections Log', page: 'collections', navId: 'nav-collections', icon: 'ðŸš›', desc: 'Completed & active collections' },
    { text: 'Route Management', page: 'routes', navId: 'nav-routes', icon: 'ðŸ—ºï¸', desc: 'Collection routes' },
    { text: 'User Management', page: 'users', navId: 'nav-users', icon: 'ðŸ‘¥', desc: 'All users & collectors' },
    { text: 'Collection Requests', page: 'requests', navId: 'nav-requests', icon: 'ðŸ“‹', desc: 'Pending & resolved requests' },
    { text: 'Transactions', page: 'transactions', navId: 'nav-transactions', icon: 'ðŸ’³', desc: 'Payments & subscriptions' },
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

// â”€â”€â”€ Table Filter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€ Action Button Handlers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
document.addEventListener('DOMContentLoaded', function () {
    document.addEventListener('click', function (e) {
        const btn = e.target.closest('button');
        if (!btn) return;
        const text = btn.textContent.trim();

        if (btn.classList.contains('btn-primary') && text === 'View') {
            const row = btn.closest('tr');
            alert(`ðŸ“‹ Viewing details for: ${row ? row.cells[0].textContent.trim() : 'item'}`);
        }
        if (btn.classList.contains('btn-success') && text === 'Collect') {
            const row = btn.closest('tr');
            const label = row ? row.cells[0].textContent.trim() : 'bin';
            if (confirm(`ðŸš› Schedule collection for ${label}?`)) alert(`âœ… Collection scheduled for ${label}`);
        }
        if (btn.classList.contains('btn-success') && text === 'Assign') {
            const row = btn.closest('tr');
            const reqId = row ? row.cells[0].textContent.trim() : 'request';
            if (confirm(`Assign a collector to ${reqId}?`)) {
                row.remove(); updateRequestBadge();
                alert(`âœ… Collector assigned to ${reqId}`);
            }
        }
        if (btn.classList.contains('btn-danger') && text === 'Delete') {
            const row = btn.closest('tr');
            const name = row ? row.cells[0].textContent.trim() : 'user';
            if (confirm(`âš ï¸ Are you sure you want to delete ${name}?`)) {
                row.remove(); alert(`ðŸ—‘ï¸ ${name} has been removed.`);
            }
        }
        if (btn.classList.contains('btn-danger') && text === 'Cancel') {
            const row = btn.closest('tr');
            const reqId = row ? row.cells[0].textContent.trim() : 'request';
            if (confirm(`Cancel ${reqId}?`)) {
                row.remove(); updateRequestBadge();
                alert(`âŒ ${reqId} has been cancelled.`);
            }
        }
        if (btn.classList.contains('btn-primary') && text === 'Edit') {
            const row = btn.closest('tr');
            const name = row ? row.cells[0].textContent.trim() : 'user';
            alert(`âœï¸ Editing profile for: ${name}\n(Full editor coming soon!)`);
        }
        if (btn.classList.contains('btn-warning') && text === 'Report') {
            const row = btn.closest('tr');
            alert(`ðŸ“Š Generating report for ${row ? row.cells[0].textContent.trim() : 'item'}â€¦`);
        }
        if (btn.classList.contains('btn-warning') && text === 'Edit') {
            const row = btn.closest('tr');
            alert(`ðŸ—ºï¸ Opening route editor for ${row ? row.cells[0].textContent.trim() : 'route'}â€¦`);
        }
        if (btn.classList.contains('btn-primary') && text === 'View Map') {
            const row = btn.closest('tr');
            const name = row ? row.cells[1].textContent.trim() : 'route';
            alert(`ðŸ—ºï¸ Opening map for: ${name}\n(Map integration coming soon!)`);
        }
    });
});

// â”€â”€â”€ Request Badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function updateRequestBadge() {
    const remaining = document.querySelectorAll('#requestsTable tbody tr:not(.loading-row)').length;
    const badge = document.getElementById('requestsBadge');
    if (badge) badge.textContent = remaining;
}


// --- Firestore Live Data ---------------------------------------------------
function initFirebaseData() {

    // ── Helpers ──────────────────────────────────────────────────────────────

    const getFillColor = l => l >= 80 ? '#ef4444' : l >= 60 ? '#f59e0b' : '#10b981';

    function fmt(ts) {
        if (!ts) return '-';
        if (ts.toDate) return ts.toDate().toLocaleDateString('en-GB');
        if (typeof ts === 'string') return ts;
        if (ts.seconds) return new Date(ts.seconds * 1000).toLocaleDateString('en-GB');
        return '-';
    }

    function setLoading(tbodyId, cols) {
        const el = document.getElementById(tbodyId);
        if (!el) return null;
        const tbody = el.tagName === 'TBODY' ? el : el.querySelector('tbody');
        if (tbody) tbody.innerHTML = `<tr class="loading-row"><td colspan="${cols}">Loading from Firestore…</td></tr>`;
        return tbody;
    }

    function listenCollection(collectionName, tbodyId, cols, rowBuilder) {
        const tbody = setLoading(tbodyId, cols);
        db.collection(collectionName).onSnapshot(snapshot => {
            if (!tbody) return;
            tbody.innerHTML = '';
            if (snapshot.empty) {
                tbody.innerHTML = `<tr class="loading-row"><td colspan="${cols}">No records found in Firestore.</td></tr>`;
                return;
            }
            snapshot.forEach(doc => {
                const tr = rowBuilder(doc.id, doc.data());
                if (tr) tbody.appendChild(tr);
            });
        }, err => {
            console.error(`[${collectionName}]`, err);
            if (tbody) tbody.innerHTML = `<tr class="loading-row"><td colspan="${cols}">⚠ ${err.message}</td></tr>`;
        });
    }

    function setStat(id, val) {
        const el = document.getElementById(id);
        if (el) el.textContent = (val !== undefined && val !== null) ? val : '-';
    }

    function statusClass(s) {
        const sl = (s || '').toLowerCase();
        if (sl === 'active' || sl === 'approved' || sl === 'online'  || sl === 'completed' || sl === 'success') return 'online';
        if (sl === 'pending' || sl === 'assigned') return 'pending';
        return 'offline';
    }

    // ── 1. Smart Bins (smart_bins) ──────────────────────────────────────────
    db.collection('smart_bins').onSnapshot(snapshot => {
        setStat('statTotalSmartBins', snapshot.size.toLocaleString());
        setStat('statTotalSmartBinsChange', snapshot.size + ' smart bins registered');

        // Overview — Recent Smart Bin Activity
        const activityTbody = document.getElementById('binActivityTable');
        if (activityTbody) {
            activityTbody.innerHTML = '';
            if (snapshot.empty) {
                activityTbody.innerHTML = '<tr class="loading-row"><td colspan="5">No smart bin activity yet.</td></tr>';
            } else {
                snapshot.forEach(doc => {
                    const bin = doc.data();
                    const fillLvl = bin.fillLevel || bin.fill_level || 0;
                    const fillHTML = `<div class="fill-bar"><div class="fill-inner" style="width:${fillLvl}%;background:${getFillColor(fillLvl)}"></div><span>${fillLvl}%</span></div>`;
                    const sc = bin.status === 'Online' || bin.status === 'online' ? 'online' : 'offline';
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td>${bin.binId || bin.id || doc.id}</td>
                        <td>${bin.location || bin.address || 'Unknown'}</td>
                        <td>${fillHTML}</td>
                        <td><span class="status ${sc}">${bin.status || 'Unknown'}</span></td>
                        <td>${fmt(bin.lastUpdated || bin.last_updated)}</td>`;
                    activityTbody.appendChild(tr);
                });
            }
        }
    }, err => console.error('[smart_bins]', err));

    // ── 2. User-facing bins (bins) ─────────────────────────────────────────
    db.collection('bins').onSnapshot(snapshot => {
        setStat('statUserBinsCount', snapshot.size.toLocaleString());
    }, err => console.warn('[bins]', err.message));

    // ── 3. Pro Users (Smart page table + stat cards) ───────────────────────
    const smartTbody = setLoading('smartBinsTable', 7);
    db.collection('users').onSnapshot(snapshot => {
        if (!smartTbody) return;
        smartTbody.innerHTML = '';
        let proCount = 0, activeProCount = 0;
        const proUsers = [];
        snapshot.forEach(doc => {
            const u = doc.data();
            const planL = (u.plan || u.subscription || '').toLowerCase();
            if (planL === 'pro' || planL === 'premium') {
                proCount++;
                const sl = (u.status || '').toLowerCase();
                if (sl === 'active' || sl === 'approved') activeProCount++;
                proUsers.push({ id: doc.id, data: u });
            }
        });
        setStat('statProUsers', proCount.toLocaleString());
        setStat('statActiveProUsers', activeProCount.toLocaleString());
        if (proUsers.length === 0) {
            smartTbody.innerHTML = '<tr class="loading-row"><td colspan="7">No Pro plan users found.</td></tr>';
            return;
        }
        proUsers.forEach(({ data: u }) => {
            const dateStr = u.joined || fmt(u.created_at) || '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${u.name || '-'}</td>
                <td>${u.email || '-'}</td>
                <td>${u.phone || u.phone_number || '-'}</td>
                <td><span class="badge-label" style="border-color:#7c3aed;color:#7c3aed">★ Pro</span></td>
                <td><span class="status ${statusClass(u.status)}">${u.status || '-'}</span></td>
                <td>${dateStr}</td>
                <td>
                    <button class="btn btn-warning">Edit</button>
                    <button class="btn btn-danger">Delete</button>
                </td>`;
            smartTbody.appendChild(tr);
        });
    }, err => {
        console.error('[pro users]', err);
        if (smartTbody) smartTbody.innerHTML = `<tr class="loading-row"><td colspan="7">⚠ ${err.message}</td></tr>`;
    });

    // ── 4. Free Users (Basic page table + stat cards) ─────────────────────
    const normalTbody = setLoading('normalBinsTable', 6);
    db.collection('users').onSnapshot(snapshot => {
        if (!normalTbody) return;
        normalTbody.innerHTML = '';
        let freeCount = 0, activeFreeCount = 0, inactiveFreeCount = 0;
        const freeUsers = [];
        snapshot.forEach(doc => {
            const u = doc.data();
            const planL = (u.plan || u.subscription || '').toLowerCase();
            if (planL === 'free' || planL === '') {
                freeCount++;
                const sl = (u.status || '').toLowerCase();
                if (sl === 'active' || sl === 'approved') activeFreeCount++;
                else inactiveFreeCount++;
                freeUsers.push({ id: doc.id, data: u });
            }
        });
        setStat('statFreeUsers', freeCount.toLocaleString());
        setStat('statActiveFreeUsers', activeFreeCount.toLocaleString());
        setStat('statInactiveFreeUsers', inactiveFreeCount.toLocaleString());
        if (freeUsers.length === 0) {
            normalTbody.innerHTML = '<tr class="loading-row"><td colspan="6">No Free plan users found.</td></tr>';
            return;
        }
        freeUsers.forEach(({ data: u }) => {
            const dateStr = u.joined || fmt(u.created_at) || '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${u.name || '-'}</td>
                <td>${u.email || '-'}</td>
                <td>${u.phone || u.phone_number || '-'}</td>
                <td><span class="badge-label">Free</span></td>
                <td>${dateStr}</td>
                <td>
                    <button class="btn btn-warning">Edit</button>
                    <button class="btn btn-danger">Delete</button>
                </td>`;
            normalTbody.appendChild(tr);
        });
    }, err => {
        console.error('[free users]', err);
        if (normalTbody) normalTbody.innerHTML = `<tr class="loading-row"><td colspan="6">⚠ ${err.message}</td></tr>`;
    });

    // ── 5. Collectors (Collections page) ───────────────────────────────────
    const collLogTbody = setLoading('collectionsTableBody', 8);
    db.collection('collectors').onSnapshot(snapshot => {
        setStat('statCollInProgress', snapshot.size.toLocaleString());
        if (!collLogTbody) return;
        collLogTbody.innerHTML = '';
        if (snapshot.empty) {
            collLogTbody.innerHTML = '<tr class="loading-row"><td colspan="8">No collectors found.</td></tr>';
            return;
        }
        snapshot.forEach(doc => {
            const u = doc.data();
            const vehicleType = (u.vehicle && u.vehicle.vehicle_type)
                ? u.vehicle.vehicle_type.replace(/_/g, ' ')
                : (u.vehicle_type ? u.vehicle_type.replace(/_/g, ' ') : '-');
            const rating  = u.rating   !== undefined ? u.rating         : '-';
            const pickups = u.total_pickups !== undefined ? u.total_pickups : '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${u.name || '-'}</td>
                <td>${u.email || '-'}</td>
                <td>${u.phone || u.phone_number || '-'}</td>
                <td>${u.city || u.zone || u.location || '-'}</td>
                <td>${rating}</td>
                <td>${pickups}</td>
                <td>${vehicleType}</td>
                <td>
                    <button class="btn btn-primary">View</button>
                    <button class="btn btn-warning">Edit</button>
                </td>`;
            collLogTbody.appendChild(tr);
        });
    }, err => {
        console.error('[collectors]', err);
        if (collLogTbody) collLogTbody.innerHTML = `<tr class="loading-row"><td colspan="8">⚠ ${err.message}</td></tr>`;
    });

    // ── 6. Routes ──────────────────────────────────────────────────────────
    listenCollection('routes', 'routesTable', 8, (id, item) => {
        const tr = document.createElement('tr');
        const s = item.status === 'Active' ? 'online' : item.status === 'In Progress' ? 'pending' : 'offline';
        tr.innerHTML = `
            <td>${item.id || id}</td>
            <td>${item.name || '-'}</td>
            <td>${item.zone || '-'}</td>
            <td>${item.bins || 0}</td>
            <td>${item.distance || 0}</td>
            <td>${item.assignedCollector || item.assigned_collector || '-'}</td>
            <td><span class="status ${s}">${item.status || 'Idle'}</span></td>
            <td>
                <button class="btn btn-primary">View Map</button>
                <button class="btn btn-warning">Edit</button>
            </td>`;
        return tr;
    });

    // ── 7. All Users (Users Management page) ───────────────────────────────
    const usersTbody = setLoading('usersTableBody', 7);
    db.collection('users').onSnapshot(snapshot => {
        if (!usersTbody) return;
        usersTbody.innerHTML = '';
        let total = 0, freeCount = 0, premium = 0;
        const allUsers = [];
        snapshot.forEach(doc => allUsers.push({ id: doc.id, data: doc.data() }));
        const planRank = p => (p === 'pro' || p === 'premium') ? 0 : 1;
        allUsers.sort((a, b) => planRank((a.data.plan || a.data.subscription || '').toLowerCase())
                               - planRank((b.data.plan || b.data.subscription || '').toLowerCase()));
        if (allUsers.length === 0) {
            usersTbody.innerHTML = '<tr class="loading-row"><td colspan="7">No users found.</td></tr>';
        }
        allUsers.forEach(({ id, data: u }) => {
            const planL = (u.plan || u.subscription || '').toLowerCase();
            total++;
            if (planL === 'free' || planL === '') freeCount++;
            if (planL === 'premium' || planL === 'pro') premium++;
            const planDisplay = (planL === 'premium' || planL === 'pro') ? '★ Pro' : 'Free';
            const dateStr = u.joined || fmt(u.created_at) || '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${u.name || '-'}</td>
                <td>${u.email || '-'}</td>
                <td>${u.role || 'user'}</td>
                <td>${planDisplay}</td>
                <td><span class="status ${statusClass(u.status)}">${u.status || '-'}</span></td>
                <td>${dateStr}</td>
                <td>
                    <button class="btn btn-warning">Edit</button>
                    <button class="btn btn-danger">Delete</button>
                </td>`;
            usersTbody.appendChild(tr);
        });
        setStat('statTotalUsers', total.toLocaleString());
        setStat('statActiveUsers', freeCount.toLocaleString());   // Basic Plan count
        setStat('statPremiumUsers', premium.toLocaleString());
    }, err => {
        console.error('[users]', err);
        if (usersTbody) usersTbody.innerHTML = `<tr class="loading-row"><td colspan="7">⚠ ${err.message}</td></tr>`;
    });

    // ── 8. Pickup Requests (Requests page) ─────────────────────────────────
    const reqTbody = setLoading('requestsTableBody', 8);
    db.collection('pickupRequests').onSnapshot(snapshot => {
        let total = 0, pending = 0, assigned = 0, completed = 0;
        if (reqTbody) reqTbody.innerHTML = '';
        if (snapshot.empty && reqTbody) {
            reqTbody.innerHTML = '<tr class="loading-row"><td colspan="8">No pickup requests found.</td></tr>';
        }
        snapshot.forEach(doc => {
            const r = doc.data();
            total++;
            const sl = (r.status || '').toLowerCase();
            if (sl === 'pending') pending++;
            else if (sl === 'assigned') assigned++;
            else if (sl === 'completed') completed++;

            if (!reqTbody) return;
            const reqId = r.requestId || r.request_id || doc.id.slice(0, 8).toUpperCase();
            const location = r.address || r.location ||
                (r.coordinates ? `${r.coordinates.lat?.toFixed(4)}, ${r.coordinates.lng?.toFixed(4)}` : '-');
            const wasteType = r.wasteType || r.waste_type || r.type || '-';
            const reqBy    = r.userName  || r.user_name  || r.userEmail || r.user_email || '-';
            const assignedTo = r.collectorName || r.collector_name || r.collectorId || '-';
            const dateStr  = fmt(r.scheduledDate || r.scheduled_date || r.createdAt || r.created_at);
            const sc       = sl === 'completed' ? 'online' : sl === 'pending' ? 'pending' : sl === 'assigned' ? 'pending' : 'offline';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${reqId}</td>
                <td>${location}</td>
                <td>${wasteType}</td>
                <td>${reqBy}</td>
                <td>${assignedTo}</td>
                <td><span class="status ${sc}">${r.status || '-'}</span></td>
                <td>${dateStr}</td>
                <td>
                    <button class="btn btn-success">Assign</button>
                    <button class="btn btn-danger">Cancel</button>
                </td>`;
            if (reqTbody) reqTbody.appendChild(tr);
        });
        setStat('statTotalRequests', total.toLocaleString());
        setStat('statPendingRequests', pending.toLocaleString());
        setStat('statAssignedRequests', assigned.toLocaleString());
        setStat('statCompletedRequests', completed.toLocaleString());
        const badge = document.getElementById('requestsBadge');
        if (badge) badge.textContent = pending + assigned;
    }, err => {
        console.error('[pickupRequests]', err);
        if (reqTbody) reqTbody.innerHTML = `<tr class="loading-row"><td colspan="8">⚠ ${err.message}</td></tr>`;
    });

    // ── 9. Resolved Requests ───────────────────────────────────────────────
    listenCollection('resolved_requests', 'resolvedRequestsTable', 5, (id, r) => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${r.requestId || r.request_id || id.slice(0, 8).toUpperCase()}</td>
            <td>${r.address || r.location || '-'}</td>
            <td>${r.collectorName || r.collector_name || '-'}</td>
            <td>${fmt(r.resolvedAt || r.resolved_at || r.updatedAt)}</td>
            <td><span class="status online">Resolved</span></td>`;
        return tr;
    });

    // ── 10. Transactions ───────────────────────────────────────────────────
    const txTbody = setLoading('txHistoryTable', 7);
    db.collection('transactions').onSnapshot(snapshot => {
        if (!txTbody) return;
        txTbody.innerHTML = '';
        if (snapshot.empty) {
            txTbody.innerHTML = '<tr class="loading-row"><td colspan="7">No transactions found.</td></tr>';
            return;
        }
        const txList = [];
        snapshot.forEach(doc => txList.push({ id: doc.id, data: doc.data() }));
        txList.sort((a, b) => {
            const da = a.data.createdAt?.seconds || a.data.date || 0;
            const db2 = b.data.createdAt?.seconds || b.data.date || 0;
            return db2 - da;
        });
        txList.forEach(({ id, data: t }) => {
            const sc = statusClass(t.status);
            const amount = t.amount !== undefined ? '₹' + Number(t.amount).toLocaleString('en-IN') : '-';
            const dateStr = fmt(t.date || t.createdAt || t.created_at);
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${t.txnId || t.transaction_id || id.slice(0, 10).toUpperCase()}</td>
                <td>${t.userName || t.user_name || '-'}</td>
                <td>${t.userEmail || t.user_email || '-'}</td>
                <td>${t.type || t.transaction_type || '-'}</td>
                <td><span class="status ${sc}">${t.status || '-'}</span></td>
                <td>${amount}</td>
                <td>${dateStr}</td>`;
            txTbody.appendChild(tr);
        });
    }, err => {
        console.error('[transactions]', err);
        if (txTbody) txTbody.innerHTML = `<tr class="loading-row"><td colspan="7">⚠ ${err.message}</td></tr>`;
    });

    // ── 11. Subscriptions ──────────────────────────────────────────────────
    const subTbody = setLoading('subscriptionsTable', 7);
    db.collection('subscriptions').onSnapshot(snapshot => {
        if (!subTbody) return;
        subTbody.innerHTML = '';
        if (snapshot.empty) {
            subTbody.innerHTML = '<tr class="loading-row"><td colspan="7">No subscriptions found.</td></tr>';
            return;
        }
        snapshot.forEach(doc => {
            const s = doc.data();
            const sc   = statusClass(s.status);
            const plan = s.plan || s.planName || s.plan_name || '-';
            const amount = s.amount !== undefined ? '₹' + Number(s.amount).toLocaleString('en-IN') + '/mo' : '-';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${s.subId || s.subscription_id || doc.id.slice(0, 8).toUpperCase()}</td>
                <td>${s.userName || s.user_name || s.userId || '-'}</td>
                <td>${plan}</td>
                <td>${fmt(s.startDate || s.start_date || s.createdAt)}</td>
                <td><span class="status ${sc}">${s.status || '-'}</span></td>
                <td>${fmt(s.renewalDate || s.renewal_date || s.expiryDate)}</td>
                <td>${amount}</td>`;
            subTbody.appendChild(tr);
        });
    }, err => {
        console.error('[subscriptions]', err);
        if (subTbody) subTbody.innerHTML = `<tr class="loading-row"><td colspan="7">⚠ ${err.message}</td></tr>`;
    });

    // ── 12. Overview — Recent Normal Bin Collections (recently joined users) ─
    const overviewNormalTbody = document.getElementById('overviewNormalBinsTable');
    db.collection('users').onSnapshot(snapshot => {
        if (!overviewNormalTbody) return;
        overviewNormalTbody.innerHTML = '';
        const recent = [];
        snapshot.forEach(doc => recent.push({ id: doc.id, data: doc.data() }));
        recent.sort((a, b) => {
            const da = a.data.createdAt?.seconds || 0;
            const db2 = b.data.createdAt?.seconds || 0;
            return db2 - da;
        });
        recent.slice(0, 10).forEach(({ data: u }) => {
            const planL = (u.plan || u.subscription || '').toLowerCase();
            const planDisplay = (planL === 'premium' || planL === 'pro') ? '★ Pro' : 'Free';
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${u.name || '-'}</td>
                <td>${u.email || '-'}</td>
                <td>${planDisplay}</td>
                <td><span class="status ${statusClass(u.status)}">${u.status || '-'}</span></td>
                <td>${u.joined || fmt(u.createdAt || u.created_at)}</td>`;
            overviewNormalTbody.appendChild(tr);
        });
        if (recent.length === 0) {
            overviewNormalTbody.innerHTML = '<tr class="loading-row"><td colspan="5">No users yet.</td></tr>';
        }
    }, err => console.error('[overview users]', err));

} // end initFirebaseData