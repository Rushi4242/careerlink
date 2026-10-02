/**
 * Career Link - Dynamic Sidebar & Top Navigation Component
 */

document.addEventListener('DOMContentLoaded', () => {
  const currentPath = window.location.pathname.split('/').pop() || 'index.html';
  const currentUser = CareerLinkDB.getCurrentUser();

  // Find sidebar container if present
  const sidebarNav = document.getElementById('sidebarNav');
  if (sidebarNav && currentUser) {
    renderSidebar(sidebarNav, currentUser.role, currentPath);
  }

  // Populate User Display Names in top navbar
  const userNameElements = document.querySelectorAll('.display-user-name');
  userNameElements.forEach(el => {
    if (currentUser) {
      el.textContent = currentUser.full_name || currentUser.email;
    }
  });

  // Populate Current Formatted Date
  const dateElements = document.querySelectorAll('.display-current-date');
  const now = new Date();
  const formattedDate = now.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
  dateElements.forEach(el => {
    el.textContent = formattedDate;
  });

  // Setup Mobile Nav Toggle
  setupMobileNav();
});

function renderSidebar(container, role, currentPath) {
  let portalTitle = 'Portal';
  let portalIcon = 'bi-layers-fill';
  let navItems = [];

  if (role === 'Candidate') {
    portalTitle = 'Candidate Portal';
    portalIcon = 'bi-layers-fill';
    navItems = [
      { href: 'candidate-dashboard.html', icon: 'bi-grid-1x2-fill', label: 'Dashboard' },
      { href: 'candidate-profile.html', icon: 'bi-person-vcard', label: 'My Profile' },
      { href: 'search-jobs.html', icon: 'bi-search', label: 'Search Jobs' },
      { href: 'recommended-jobs.html', icon: 'bi-stars', label: 'AI Skill Matches' },
      { href: 'upload-resume.html', icon: 'bi-file-earmark-arrow-up', label: 'Upload Resume' },
      { href: 'my-applications.html', icon: 'bi-card-list', label: 'My Applications' },
      { href: 'interview-status.html', icon: 'bi-calendar-check', label: 'Interviews' }
    ];
  } else if (role === 'HR') {
    portalTitle = 'HR Portal';
    portalIcon = 'bi-buildings-fill';
    navItems = [
      { href: 'hr-dashboard.html', icon: 'bi-grid-1x2-fill', label: 'HR Dashboard' },
      { href: 'post-job.html', icon: 'bi-plus-circle-fill', label: 'Post New Job' },
      { href: 'hr-manage-jobs.html', icon: 'bi-gear-fill', label: 'Manage Jobs' },
      { href: 'hr-view-applications.html', icon: 'bi-file-earmark-person-fill', label: 'Applications' }
    ];
  } else if (role === 'Admin') {
    portalTitle = 'Admin Portal';
    portalIcon = 'bi-shield-lock-fill';
    navItems = [
      { href: 'admin-dashboard.html', icon: 'bi-grid-1x2-fill', label: 'System Overview' },
      { href: 'manage-users.html', icon: 'bi-people-fill', label: 'Manage Users' },
      { href: 'admin-approve-jobs.html', icon: 'bi-briefcase-fill', label: 'Review Jobs' },
      { href: 'admin-all-applications.html', icon: 'bi-file-earmark-text-fill', label: 'All Applications' },
      { href: 'admin-all-interviews.html', icon: 'bi-calendar-event-fill', label: 'All Interviews' },
      { href: 'admin-reports.html', icon: 'bi-bar-chart-fill', label: 'View Reports' }
    ];
  }

  const itemsHtml = navItems.map(item => {
    const isActive = currentPath === item.href ? 'active' : '';
    return `<li><a href="${item.href}" class="${isActive}"><i class="bi ${item.icon}"></i> ${item.label}</a></li>`;
  }).join('');

  container.innerHTML = `
    <div class="sidebar-header">
      <h4><i class="bi ${portalIcon} me-2"></i>Career Link</h4>
      <div class="portal-badge">${portalTitle}</div>
    </div>
    <ul class="flex-grow-1">
      ${itemsHtml}
    </ul>
    <div class="sidebar-footer">
      <button onclick="CareerLinkDB.logout()" class="btn btn-outline-danger w-100 rounded-pill py-2">
        <i class="bi bi-power me-2"></i>Logout
      </button>
    </div>
  `;
}

function setupMobileNav() {
  const toggleBtn = document.getElementById('mobileNavToggle');
  const sidebar = document.getElementById('sidebarNav');
  
  if (!toggleBtn || !sidebar) return;

  let backdrop = document.querySelector('.sidebar-backdrop');
  if (!backdrop) {
    backdrop = document.createElement('div');
    backdrop.className = 'sidebar-backdrop';
    document.body.appendChild(backdrop);
  }

  toggleBtn.addEventListener('click', () => {
    sidebar.classList.toggle('show');
    backdrop.classList.toggle('show');
  });

  backdrop.addEventListener('click', () => {
    sidebar.classList.remove('show');
    backdrop.classList.remove('show');
  });
}
