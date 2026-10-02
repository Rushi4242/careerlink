# 🚀 Career Link - Assisted Online Job Portal System

![Career Link Banner](https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=1200&auto=format&fit=crop)

A modern, full-featured, assisted online job portal system engineered with high-fidelity glassmorphism UI, role-based workflows (Candidate, HR Manager, System Administrator), AI skill matching, interview scheduling, interactive Chart.js analytics, and full **Vercel deployability**.

---

## 🌟 Key Features

### 👤 1. Candidate Portal
- **Dashboard**: Real-time status overview, dynamic profile completeness banner, quick action cards.
- **Profile Management**: Profile editor for education, skills, and experience with live auto-save.
- **Resume Upload**: Upload, preview, and replace resume files (.pdf, .doc, .docx).
- **Job Search**: Instant keyword search by title, company, or location with experience badges.
- **AI Skill Matches**: Dynamic matching algorithm comparing candidate skills to job requirements with match percentage badges (e.g., 98% Match).
- **Application Tracking**: Live status badges (*Pending Review*, *Shortlisted*, *Rejected*).
- **Interview Schedule**: Schedule viewer with date, time, and meeting format (*Online*, *In-Office*, *Phone Call*).

### 🏢 2. HR / Employer Portal
- **Dashboard**: Key performance indicators (*Active Jobs*, *Applications Received*, *Interviews Scheduled*).
- **Post New Job**: Create comprehensive job listings with salary packages, experience requirements, and application deadlines (sent for Admin approval).
- **Manage Job Postings**: Table of posted jobs, Admin approval statuses, and cascade job deletion.
- **Edit Job Postings**: Pre-filled update interface for active vacancies.
- **Candidate Applications**: Filterable applicant table with candidate skills, experience, and application dates.
- **Candidate Evaluation & Scheduling**: Full profile review, resume viewer, and 1-click decision making (*Shortlist & Schedule Interview* or *Reject*).

### 🛡️ 3. Admin Command Center
- **System Overview**: Platform-wide metrics (*Total Users*, *Active Jobs*, *Applications*, *Interviews*).
- **Manage Users**: Role-based user directory with cascade user deletion protection for Admin accounts.
- **Job Approval System**: 1-click *Approve* or *Reject* workflow for newly submitted HR job listings.
- **Platform-wide Monitoring**: Track every job application and scheduled interview across all companies.
- **Visual Reports & Analytics**:
  - Interactive **Chart.js User Distribution Pie Chart** with percentage breakdowns.
  - Interactive **Chart.js Application Status Doughnut Chart** with custom tooltips.
  - Built-in **Export / Print System Report (PDF)** feature.

---

## 🔑 Demo Login Credentials

You can use the **1-Click Quick Demo Login** buttons on the sign-in page or enter these credentials manually:

| Role | Email Address | Password | Role Dropdown Selection |
| :--- | :--- | :--- | :--- |
| **System Administrator** | `admin@careerlink.com` | `admin@123` | **System Administrator** |
| **HR Manager (TCS)** | `hr@tcs.com` | `hr@123` | **HR Manager** |
| **HR Manager (Infosys)** | `hr@infosys.com` | `hr@123` | **HR Manager** |
| **Candidate** | `candidate@careerlink.com` | `candidate@123` | **Candidate** |

---

## 🚀 How to Deploy to Vercel

This project is 100% pre-configured for instant zero-configuration deployment to [Vercel](https://vercel.com).

### Option A: Deploy via Vercel Web Dashboard (Recommended)

1. **Push your code to GitHub / GitLab / Bitbucket**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit - Career Link Vercel deployable"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/careerlink.git
   git push -u origin main
   ```
2. Go to [vercel.com](https://vercel.com) and log in.
3. Click **"Add New..."** > **"Project"**.
4. Import your `careerlink` repository.
5. Keep default settings (**Framework Preset: Other**, **Root Directory: ./**).
6. Click **Deploy**.
7. 🎉 Your portal will be live on a `*.vercel.app` URL in less than 15 seconds!

### Option B: Deploy via Vercel CLI

1. Install the Vercel CLI globally (if not already installed):
   ```bash
   npm i -g vercel
   ```
2. In the project root directory (`c:/careerlink`), run:
   ```bash
   vercel
   ```
3. Follow the CLI prompts (accept defaults).
4. For production deployment, run:
   ```bash
   vercel --prod
   ```

---

## 💻 Running Locally

You can test and run the application locally on your computer in two easy ways:

### Option 1: Using Node.js
```bash
npx serve .
# Or
npm start
```
Open your browser and navigate to `http://localhost:3000`.

### Option 2: Direct File Open
Simply double-click `index.html` to open it in any modern web browser (Chrome, Edge, Firefox, Safari).

---

## 📁 Project Architecture

```
careerlink/
│
├── vercel.json                  # Vercel routing, clean URLs & security headers
├── package.json                 # Project scripts and configuration
├── .gitignore                   # Git ignore specifications
├── README.md                    # Project documentation & deployment guide
│
├── index.html                   # Public Homepage with featured jobs & hiring partners
├── login.html                   # Role-based sign-in with 1-click demo chips
├── register.html                # Account registration with password validation
├── forgot-password.html         # Double-factor password recovery
├── test.html                    # System & database diagnostics
│
├── candidate-dashboard.html     # Candidate command center
├── candidate-profile.html       # Candidate profile editor
├── upload-resume.html           # Candidate resume upload & viewer
├── search-jobs.html             # Job search with live filters & apply
├── recommended-jobs.html        # AI skill matching recommendations
├── apply-job.html               # Application confirmation handler
├── my-applications.html         # Application status tracking table
├── interview-status.html        # Scheduled interviews table
│
├── hr-dashboard.html            # HR employer command center
├── post-job.html                # Create new job listing
├── hr-manage-jobs.html          # Manage & delete HR job postings
├── hr-edit-job.html             # Edit job posting details
├── hr-view-applications.html    # View candidate applicants
├── hr-review-application.html   # Evaluate applicant & schedule interview
│
├── admin-dashboard.html         # Admin system overview
├── manage-users.html            # User directory & cleanup
├── admin-approve-jobs.html      # Job approval & verification queue
├── admin-all-applications.html  # Platform-wide application tracker
├── admin-all-interviews.html    # Platform-wide interview schedule
├── admin-reports.html           # Chart.js analytics & PDF export
│
├── css/
│   └── style.css                # Unified design system & responsive layout
└── js/
    ├── app-data.js              # Database engine, SHA-256 hashing & CRUD
    └── sidebar.js               # Responsive sidebar & mobile navigation
```

---

## 📜 Technology Stack

- **Frontend & Structure**: Semantic HTML5, CSS3, JavaScript (ES6+)
- **Styling & Framework**: Vanilla CSS Design Tokens, Glassmorphism, Bootstrap 5.3.3, Bootstrap Icons 1.11.3
- **Data Visualization**: Chart.js
- **Security & Data Layer**: Web Crypto API (SHA-256 Hashing), Session Storage & Local Storage Database Engine
- **Hosting & Cloud**: Vercel Edge Cloud Platform
