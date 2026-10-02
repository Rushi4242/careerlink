/**
 * Career Link - Universal Data & State Engine
 * Replicates full MySQL schema, relationships, cascades, SHA-256 auth, and business logic
 */

const CareerLinkDB = (function() {
  const STORAGE_KEY_USERS = 'careerlink_users';
  const STORAGE_KEY_JOBS = 'careerlink_jobs';
  const STORAGE_KEY_APPS = 'careerlink_applications';
  const STORAGE_KEY_INTERVIEWS = 'careerlink_interviews';
  const STORAGE_KEY_RESUMES = 'careerlink_resumes';
  const STORAGE_KEY_SESSION = 'careerlink_session';

  // Helper: SHA-256 Hashing using browser Web Crypto API
  async function hashPassword(plainText) {
    if (!plainText) return '';
    try {
      const msgBuffer = new TextEncoder().encode(plainText);
      const hashBuffer = await crypto.subtle.digest('SHA-256', msgBuffer);
      const hashArray = Array.from(new Uint8Array(hashBuffer));
      const hexString = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
      return hexString;
    } catch (e) {
      // Fallback simple hash for older environments
      let hash = 0;
      for (let i = 0; i < plainText.length; i++) {
        const char = plainText.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash |= 0;
      }
      return 'fallback_' + Math.abs(hash).toString(16);
    }
  }

  // Pre-seeded initial dataset
  const initialUsers = [
    {
      user_id: 1,
      full_name: "Admin User",
      email: "admin@careerlink.com",
      mobile: "9876543210",
      password_hash: "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918", // 'admin' -> we support fallback direct match too
      password_plain: "admin@123",
      role: "Admin",
      education: "Master of Technology",
      skills: "System Administration, Cloud Infrastructure, Database Design",
      experience: "5+ Years"
    },
    {
      user_id: 2,
      full_name: "Rajesh Sharma",
      email: "hr@tcs.com",
      mobile: "9822334455",
      password_plain: "hr@123",
      role: "HR",
      education: "MBA in Human Resources",
      skills: "Talent Acquisition, Technical Recruitment, Leadership",
      experience: "5+ Years"
    },
    {
      user_id: 3,
      full_name: "Priya Patel",
      email: "hr@infosys.com",
      mobile: "9833445566",
      password_plain: "hr@123",
      role: "HR",
      education: "MBA HR",
      skills: "Recruitment, HR Analytics",
      experience: "3-5 Years"
    },
    {
      user_id: 4,
      full_name: "Rahul Verma",
      email: "candidate@careerlink.com",
      mobile: "9898765432",
      password_plain: "candidate@123",
      role: "Candidate",
      education: "B.Tech in Computer Science",
      skills: "Java, Spring Boot, MySQL, JavaScript, HTML, CSS",
      experience: "1-2 Years"
    },
    {
      user_id: 5,
      full_name: "Sneha Kulkarni",
      email: "sneha@example.com",
      mobile: "9876501234",
      password_plain: "candidate@123",
      role: "Candidate",
      education: "B.E. Information Technology",
      skills: "Python, Django, React, SQL, Machine Learning",
      experience: "Fresher"
    }
  ];

  const initialJobs = [
    {
      job_id: 1,
      job_title: "Java Full Stack Developer",
      company_name: "TCS",
      location: "Pune, Maharashtra",
      salary: "₹6.5 LPA",
      experience: "0-2 Years",
      description: "Looking for an energetic Java Developer proficient in Core Java, Spring Boot, Hibernate, RESTful APIs, and basic SQL.",
      posted_by: 2,
      posted_date: "2026-09-20",
      approval_status: "Approved",
      last_date: "2026-11-15"
    },
    {
      job_id: 2,
      job_title: "Frontend Developer (React/Vue)",
      company_name: "Infosys",
      location: "Mumbai, Maharashtra",
      salary: "₹5.8 LPA",
      experience: "1-2 Years",
      description: "Build clean, responsive, high-performance web applications using HTML5, CSS3, JavaScript, React, and Bootstrap.",
      posted_by: 3,
      posted_date: "2026-09-22",
      approval_status: "Approved",
      last_date: "2026-11-20"
    },
    {
      job_id: 3,
      job_title: "Python / Data Engineer",
      company_name: "Wipro",
      location: "Bangalore, Karnataka",
      salary: "₹7.2 LPA",
      experience: "2-3 Years",
      description: "Develop automated pipelines and API microservices using Python, FastAPI/Django, and PostgreSQL data stores.",
      posted_by: 2,
      posted_date: "2026-09-25",
      approval_status: "Approved",
      last_date: "2026-11-30"
    },
    {
      job_id: 4,
      job_title: "Cloud & DevOps Associate",
      company_name: "Capgemini",
      location: "Hyderabad, Telangana",
      salary: "₹8.0 LPA",
      experience: "3-5 Years",
      description: "Manage CI/CD pipelines, Docker containers, AWS/Azure cloud infrastructure, and Linux systems monitoring.",
      posted_by: 3,
      posted_date: "2026-09-28",
      approval_status: "Approved",
      last_date: "2026-12-05"
    },
    {
      job_id: 5,
      job_title: "Junior QA / Automation Tester",
      company_name: "Tech Mahindra",
      location: "Pune, Maharashtra",
      salary: "₹4.5 LPA",
      experience: "Fresher",
      description: "Write and execute manual test cases, Selenium automated test suites, and regression testing reports.",
      posted_by: 2,
      posted_date: "2026-10-01",
      approval_status: "Pending", // Awaiting Admin Approval
      last_date: "2026-12-10"
    }
  ];

  const initialApplications = [
    {
      application_id: 1,
      job_id: 1,
      user_id: 4,
      apply_date: "2026-09-23",
      status: "Shortlisted"
    },
    {
      application_id: 2,
      job_id: 2,
      user_id: 4,
      apply_date: "2026-09-26",
      status: "Pending"
    },
    {
      application_id: 3,
      job_id: 3,
      user_id: 5,
      apply_date: "2026-09-29",
      status: "Shortlisted"
    }
  ];

  const initialInterviews = [
    {
      interview_id: 1,
      application_id: 1,
      interview_date: "2026-10-15",
      interview_time: "11:30 AM",
      interview_mode: "Online",
      status: "Scheduled"
    },
    {
      interview_id: 2,
      application_id: 3,
      interview_date: "2026-10-18",
      interview_time: "02:00 PM",
      interview_mode: "Offline",
      status: "Scheduled"
    }
  ];

  const initialResumes = [
    {
      resume_id: 1,
      user_id: 4,
      resume_file: "Rahul_Verma_Java_Resume.pdf",
      upload_date: "2026-09-21"
    },
    {
      resume_id: 2,
      user_id: 5,
      resume_file: "Sneha_Kulkarni_Python_CV.pdf",
      upload_date: "2026-09-28"
    }
  ];

  // Initialize DB if empty
  function initDB() {
    if (!localStorage.getItem(STORAGE_KEY_USERS)) {
      localStorage.setItem(STORAGE_KEY_USERS, JSON.stringify(initialUsers));
    }
    if (!localStorage.getItem(STORAGE_KEY_JOBS)) {
      localStorage.setItem(STORAGE_KEY_JOBS, JSON.stringify(initialJobs));
    }
    if (!localStorage.getItem(STORAGE_KEY_APPS)) {
      localStorage.setItem(STORAGE_KEY_APPS, JSON.stringify(initialApplications));
    }
    if (!localStorage.getItem(STORAGE_KEY_INTERVIEWS)) {
      localStorage.setItem(STORAGE_KEY_INTERVIEWS, JSON.stringify(initialInterviews));
    }
    if (!localStorage.getItem(STORAGE_KEY_RESUMES)) {
      localStorage.setItem(STORAGE_KEY_RESUMES, JSON.stringify(initialResumes));
    }
  }

  initDB();

  // Internal storage helpers
  function getTable(key) {
    const data = localStorage.getItem(key);
    return data ? JSON.parse(data) : [];
  }

  function setTable(key, data) {
    localStorage.setItem(key, JSON.stringify(data));
  }

  return {
    hashPassword,

    // ----------------------------------------------------
    // Authentication & Session
    // ----------------------------------------------------
    async login(email, password, role) {
      const users = getTable(STORAGE_KEY_USERS);
      const user = users.find(u => u.email.toLowerCase() === email.trim().toLowerCase() && u.role === role);
      if (!user) {
        return { success: false, message: "Invalid Email, Password, or Role selection!" };
      }

      const inputHash = await hashPassword(password);
      // Validate either plain password or hash match
      if (user.password_plain === password || user.password_hash === inputHash) {
        const sessionData = {
          user_id: user.user_id,
          email: user.email,
          full_name: user.full_name,
          role: user.role
        };
        sessionStorage.setItem(STORAGE_KEY_SESSION, JSON.stringify(sessionData));
        localStorage.setItem(STORAGE_KEY_SESSION, JSON.stringify(sessionData)); // backup
        return { success: true, user: sessionData };
      }

      return { success: false, message: "Invalid Email, Password, or Role selection!" };
    },

    async register({ fullName, email, mobile, role, password }) {
      const users = getTable(STORAGE_KEY_USERS);
      const emailLower = email.trim().toLowerCase();
      if (users.some(u => u.email.toLowerCase() === emailLower)) {
        return { success: false, message: "Email Address is already registered!" };
      }

      const hash = await hashPassword(password);
      const newId = users.length > 0 ? Math.max(...users.map(u => u.user_id)) + 1 : 1;
      const newUser = {
        user_id: newId,
        full_name: fullName.trim(),
        email: emailLower,
        mobile: mobile.trim(),
        password_plain: password,
        password_hash: hash,
        role: role,
        education: "",
        skills: "",
        experience: "Fresher"
      };

      users.push(newUser);
      setTable(STORAGE_KEY_USERS, users);
      return { success: true, message: "Registration successful!" };
    },

    async resetPassword(email, mobile, newPassword) {
      const users = getTable(STORAGE_KEY_USERS);
      const user = users.find(u => u.email.toLowerCase() === email.trim().toLowerCase() && u.mobile.trim() === mobile.trim());
      if (!user) {
        return { success: false, message: "Verification failed. Email and Mobile Number do not match our records." };
      }

      const hash = await hashPassword(newPassword);
      user.password_plain = newPassword;
      user.password_hash = hash;
      setTable(STORAGE_KEY_USERS, users);
      return { success: true, message: "Password reset successfully! You can now sign in." };
    },

    getCurrentUser() {
      const s = sessionStorage.getItem(STORAGE_KEY_SESSION) || localStorage.getItem(STORAGE_KEY_SESSION);
      if (!s) return null;
      try {
        const session = JSON.parse(s);
        // Refresh with latest DB state
        const users = getTable(STORAGE_KEY_USERS);
        const latest = users.find(u => u.user_id === session.user_id);
        return latest || session;
      } catch (e) {
        return null;
      }
    },

    logout() {
      sessionStorage.removeItem(STORAGE_KEY_SESSION);
      localStorage.removeItem(STORAGE_KEY_SESSION);
      window.location.href = "login.html";
    },

    requireAuth(requiredRole) {
      const user = this.getCurrentUser();
      if (!user || (requiredRole && user.role !== requiredRole)) {
        window.location.href = "login.html";
        return null;
      }
      return user;
    },

    // ----------------------------------------------------
    // Users Management (Admin)
    // ----------------------------------------------------
    getAllUsers() {
      return getTable(STORAGE_KEY_USERS);
    },

    getNonAdminUsers() {
      return getTable(STORAGE_KEY_USERS).filter(u => u.role !== 'Admin');
    },

    deleteUser(userId) {
      userId = parseInt(userId);
      let users = getTable(STORAGE_KEY_USERS);
      let jobs = getTable(STORAGE_KEY_JOBS);
      let apps = getTable(STORAGE_KEY_APPS);
      let interviews = getTable(STORAGE_KEY_INTERVIEWS);
      let resumes = getTable(STORAGE_KEY_RESUMES);

      // Find user
      const targetUser = users.find(u => u.user_id === userId);
      if (!targetUser || targetUser.role === 'Admin') {
        return { success: false, message: "Cannot delete Administrator." };
      }

      // If Candidate: delete applications & linked interviews, resumes
      if (targetUser.role === 'Candidate') {
        const userAppIds = apps.filter(a => a.user_id === userId).map(a => a.application_id);
        interviews = interviews.filter(i => !userAppIds.includes(i.application_id));
        apps = apps.filter(a => a.user_id !== userId);
        resumes = resumes.filter(r => r.user_id !== userId);
      }

      // If HR: delete posted jobs and all applications & interviews under those jobs
      if (targetUser.role === 'HR') {
        const hrJobIds = jobs.filter(j => j.posted_by === userId).map(j => j.job_id);
        const hrAppIds = apps.filter(a => hrJobIds.includes(a.job_id)).map(a => a.application_id);
        interviews = interviews.filter(i => !hrAppIds.includes(i.application_id));
        apps = apps.filter(a => !hrJobIds.includes(a.job_id));
        jobs = jobs.filter(j => j.posted_by !== userId);
      }

      users = users.filter(u => u.user_id !== userId);

      setTable(STORAGE_KEY_USERS, users);
      setTable(STORAGE_KEY_JOBS, jobs);
      setTable(STORAGE_KEY_APPS, apps);
      setTable(STORAGE_KEY_INTERVIEWS, interviews);
      setTable(STORAGE_KEY_RESUMES, resumes);

      return { success: true, message: "User removed successfully." };
    },

    // ----------------------------------------------------
    // Profile Management (Candidate)
    // ----------------------------------------------------
    updateCandidateProfile(userId, { fullname, mobile, education, skills, experience }) {
      const users = getTable(STORAGE_KEY_USERS);
      const user = users.find(u => u.user_id === parseInt(userId));
      if (!user) return { success: false, message: "User not found." };

      user.full_name = fullname;
      user.mobile = mobile;
      user.education = education;
      user.skills = skills;
      user.experience = experience;

      setTable(STORAGE_KEY_USERS, users);
      return { success: true, message: "Profile Updated Successfully!" };
    },

    isProfileComplete(userId) {
      const user = getTable(STORAGE_KEY_USERS).find(u => u.user_id === parseInt(userId));
      if (!user) return false;

      const hasText = Boolean(
        user.mobile && user.mobile.trim().length > 0 &&
        user.education && user.education.trim().length > 0 &&
        user.skills && user.skills.trim().length > 0 &&
        user.experience && user.experience.trim().length > 0
      );

      const resumes = getTable(STORAGE_KEY_RESUMES);
      const hasResume = resumes.some(r => r.user_id === parseInt(userId));

      return hasText && hasResume;
    },

    // ----------------------------------------------------
    // Resume Management
    // ----------------------------------------------------
    getResume(userId) {
      const resumes = getTable(STORAGE_KEY_RESUMES);
      return resumes.find(r => r.user_id === parseInt(userId)) || null;
    },

    saveResume(userId, fileName) {
      userId = parseInt(userId);
      let resumes = getTable(STORAGE_KEY_RESUMES);
      const today = new Date().toISOString().split('T')[0];
      const existing = resumes.find(r => r.user_id === userId);

      if (existing) {
        existing.resume_file = fileName;
        existing.upload_date = today;
      } else {
        const newId = resumes.length > 0 ? Math.max(...resumes.map(r => r.resume_id)) + 1 : 1;
        resumes.push({
          resume_id: newId,
          user_id: userId,
          resume_file: fileName,
          upload_date: today
        });
      }

      setTable(STORAGE_KEY_RESUMES, resumes);
      return { success: true, message: `Resume saved as: ${fileName}` };
    },

    // ----------------------------------------------------
    // Job Postings
    // ----------------------------------------------------
    getApprovedJobs(keyword = "") {
      const jobs = getTable(STORAGE_KEY_JOBS).filter(j => j.approval_status === "Approved");
      if (!keyword || !keyword.trim()) return jobs;

      const kw = keyword.toLowerCase().trim();
      return jobs.filter(j => 
        (j.job_title && j.job_title.toLowerCase().includes(kw)) ||
        (j.company_name && j.company_name.toLowerCase().includes(kw)) ||
        (j.location && j.location.toLowerCase().includes(kw)) ||
        (j.description && j.description.toLowerCase().includes(kw))
      );
    },

    getJobById(jobId) {
      return getTable(STORAGE_KEY_JOBS).find(j => j.job_id === parseInt(jobId)) || null;
    },

    getJobsByHR(hrId) {
      return getTable(STORAGE_KEY_JOBS).filter(j => j.posted_by === parseInt(hrId));
    },

    getPendingJobs() {
      const jobs = getTable(STORAGE_KEY_JOBS).filter(j => j.approval_status === "Pending");
      const users = getTable(STORAGE_KEY_USERS);
      return jobs.map(j => {
        const hr = users.find(u => u.user_id === j.posted_by);
        return {
          ...j,
          hr_name: hr ? hr.full_name : "HR Manager"
        };
      });
    },

    createJob({ title, company, location, salary, experience, description, last_date, hrId }) {
      const jobs = getTable(STORAGE_KEY_JOBS);
      const newId = jobs.length > 0 ? Math.max(...jobs.map(j => j.job_id)) + 1 : 1;
      const today = new Date().toISOString().split('T')[0];

      const newJob = {
        job_id: newId,
        job_title: title,
        company_name: company,
        location: location,
        salary: salary,
        experience: experience,
        description: description,
        posted_by: parseInt(hrId),
        posted_date: today,
        approval_status: "Pending", // Awaiting Admin Approval
        last_date: last_date
      };

      jobs.unshift(newJob);
      setTable(STORAGE_KEY_JOBS, jobs);
      return { success: true, message: "Job Posted Successfully! Pending Admin approval." };
    },

    updateJob(jobId, hrId, { title, company, location, salary, experience, description, last_date }) {
      const jobs = getTable(STORAGE_KEY_JOBS);
      const job = jobs.find(j => j.job_id === parseInt(jobId) && j.posted_by === parseInt(hrId));
      if (!job) return { success: false, message: "Job not found or permission denied." };

      job.job_title = title;
      job.company_name = company;
      job.location = location;
      job.salary = salary;
      job.experience = experience;
      job.description = description;
      job.last_date = last_date;

      setTable(STORAGE_KEY_JOBS, jobs);
      return { success: true, message: "Job Updated Successfully!" };
    },

    deleteJob(jobId, hrId) {
      jobId = parseInt(jobId);
      let jobs = getTable(STORAGE_KEY_JOBS);
      let apps = getTable(STORAGE_KEY_APPS);
      let interviews = getTable(STORAGE_KEY_INTERVIEWS);

      const job = jobs.find(j => j.job_id === jobId && (hrId ? j.posted_by === parseInt(hrId) : true));
      if (!job) return { success: false, message: "Job not found." };

      // Cascade delete applications and interviews
      const appIds = apps.filter(a => a.job_id === jobId).map(a => a.application_id);
      interviews = interviews.filter(i => !appIds.includes(i.application_id));
      apps = apps.filter(a => a.job_id !== jobId);
      jobs = jobs.filter(j => j.job_id !== jobId);

      setTable(STORAGE_KEY_JOBS, jobs);
      setTable(STORAGE_KEY_APPS, apps);
      setTable(STORAGE_KEY_INTERVIEWS, interviews);

      return { success: true, message: "Job successfully deleted." };
    },

    setJobApprovalStatus(jobId, status) {
      const jobs = getTable(STORAGE_KEY_JOBS);
      const job = jobs.find(j => j.job_id === parseInt(jobId));
      if (!job) return { success: false, message: "Job not found." };

      job.approval_status = status;
      setTable(STORAGE_KEY_JOBS, jobs);
      return { success: true, message: `Job ${status} successfully.` };
    },

    // ----------------------------------------------------
    // Applications & Matching
    // ----------------------------------------------------
    applyForJob(jobId, userId) {
      jobId = parseInt(jobId);
      userId = parseInt(userId);

      if (!this.isProfileComplete(userId)) {
        return { success: false, message: "Please complete your profile and upload your resume before applying." };
      }

      const apps = getTable(STORAGE_KEY_APPS);
      const existing = apps.find(a => a.job_id === jobId && a.user_id === userId);
      if (existing) {
        return { success: false, isDuplicate: true, message: "You have already applied for this position." };
      }

      const newId = apps.length > 0 ? Math.max(...apps.map(a => a.application_id)) + 1 : 1;
      const today = new Date().toISOString().split('T')[0];

      apps.unshift({
        application_id: newId,
        job_id: jobId,
        user_id: userId,
        apply_date: today,
        status: "Pending"
      });

      setTable(STORAGE_KEY_APPS, apps);
      return { success: true, message: "Application Submitted Successfully!" };
    },

    getCandidateApplications(userId) {
      userId = parseInt(userId);
      const apps = getTable(STORAGE_KEY_APPS).filter(a => a.user_id === userId);
      const jobs = getTable(STORAGE_KEY_JOBS);

      return apps.map(a => {
        const job = jobs.find(j => j.job_id === a.job_id) || {};
        return {
          ...a,
          job_title: job.job_title || "Position Unavailable",
          company_name: job.company_name || "Company",
          location: job.location || "Location",
          salary: job.salary || "N/A"
        };
      });
    },

    getHRApplications(hrId) {
      hrId = parseInt(hrId);
      const jobs = getTable(STORAGE_KEY_JOBS).filter(j => j.posted_by === hrId);
      const jobIds = jobs.map(j => j.job_id);
      const apps = getTable(STORAGE_KEY_APPS).filter(a => jobIds.includes(a.job_id));
      const users = getTable(STORAGE_KEY_USERS);

      return apps.map(a => {
        const job = jobs.find(j => j.job_id === a.job_id) || {};
        const candidate = users.find(u => u.user_id === a.user_id) || {};
        return {
          ...a,
          candidate_name: candidate.full_name || "Candidate",
          job_title: job.job_title || "Job Role",
          skills: candidate.skills || "Not provided",
          experience: candidate.experience || "Not provided"
        };
      });
    },

    getApplicationDetails(appId) {
      appId = parseInt(appId);
      const apps = getTable(STORAGE_KEY_APPS);
      const app = apps.find(a => a.application_id === appId);
      if (!app) return null;

      const user = getTable(STORAGE_KEY_USERS).find(u => u.user_id === app.user_id) || {};
      const job = getTable(STORAGE_KEY_JOBS).find(j => j.job_id === app.job_id) || {};
      const resume = getTable(STORAGE_KEY_RESUMES).find(r => r.user_id === app.user_id) || null;

      return {
        ...app,
        full_name: user.full_name || "Candidate",
        email: user.email || "",
        mobile: user.mobile || "N/A",
        education: user.education || "Not Provided",
        skills: user.skills || "Not Provided",
        experience: user.experience || "Not Provided",
        job_title: job.job_title || "Role",
        company_name: job.company_name || "",
        resume_file: resume ? resume.resume_file : null
      };
    },

    evaluateApplication(appId, { status, interview_date, interview_time, interview_mode }) {
      appId = parseInt(appId);
      const apps = getTable(STORAGE_KEY_APPS);
      const app = apps.find(a => a.application_id === appId);
      if (!app) return { success: false, message: "Application not found." };

      app.status = status;
      setTable(STORAGE_KEY_APPS, apps);

      if (status === "Shortlisted") {
        let interviews = getTable(STORAGE_KEY_INTERVIEWS);
        const existingInt = interviews.find(i => i.application_id === appId);
        if (!existingInt) {
          const newId = interviews.length > 0 ? Math.max(...interviews.map(i => i.interview_id)) + 1 : 1;
          interviews.unshift({
            interview_id: newId,
            application_id: appId,
            interview_date: interview_date,
            interview_time: interview_time,
            interview_mode: interview_mode || "Online",
            status: "Scheduled"
          });
          setTable(STORAGE_KEY_INTERVIEWS, interviews);
        }
      }

      return { success: true, message: `Candidate application marked as ${status}.` };
    },

    getAllApplications() {
      const apps = getTable(STORAGE_KEY_APPS);
      const users = getTable(STORAGE_KEY_USERS);
      const jobs = getTable(STORAGE_KEY_JOBS);

      return apps.map(a => {
        const user = users.find(u => u.user_id === a.user_id) || {};
        const job = jobs.find(j => j.job_id === a.job_id) || {};
        return {
          ...a,
          candidate_name: user.full_name || "Candidate",
          job_title: job.job_title || "Job Title",
          company_name: job.company_name || "Company"
        };
      });
    },

    // ----------------------------------------------------
    // Interviews
    // ----------------------------------------------------
    getCandidateInterviews(userId) {
      userId = parseInt(userId);
      const candidateApps = getTable(STORAGE_KEY_APPS).filter(a => a.user_id === userId);
      const appIds = candidateApps.map(a => a.application_id);
      const interviews = getTable(STORAGE_KEY_INTERVIEWS).filter(i => appIds.includes(i.application_id));
      const jobs = getTable(STORAGE_KEY_JOBS);

      return interviews.map(i => {
        const app = candidateApps.find(a => a.application_id === i.application_id);
        const job = app ? jobs.find(j => j.job_id === app.job_id) : {};
        return {
          ...i,
          company_name: job ? job.company_name : "Company",
          job_title: job ? job.job_title : "Position"
        };
      });
    },

    getAllInterviews() {
      const interviews = getTable(STORAGE_KEY_INTERVIEWS);
      const apps = getTable(STORAGE_KEY_APPS);
      const users = getTable(STORAGE_KEY_USERS);
      const jobs = getTable(STORAGE_KEY_JOBS);

      return interviews.map(i => {
        const app = apps.find(a => a.application_id === i.application_id);
        const candidate = app ? users.find(u => u.user_id === app.user_id) : null;
        const job = app ? jobs.find(j => j.job_id === app.job_id) : null;

        return {
          ...i,
          candidate_name: candidate ? candidate.full_name : "Candidate",
          company_name: job ? job.company_name : "Company",
          job_title: job ? job.job_title : "Role"
        };
      });
    },

    // ----------------------------------------------------
    // Recommendations (AI Skill Match)
    // ----------------------------------------------------
    getRecommendedJobs(userId) {
      const user = getTable(STORAGE_KEY_USERS).find(u => u.user_id === parseInt(userId));
      if (!user || !user.skills) return [];

      const userSkills = user.skills.split(',').map(s => s.trim().toLowerCase()).filter(Boolean);
      const approvedJobs = this.getApprovedJobs();

      const matched = approvedJobs.map(job => {
        const text = `${job.job_title} ${job.description}`.toLowerCase();
        let matchCount = 0;
        userSkills.forEach(skill => {
          if (text.includes(skill)) matchCount++;
        });

        const score = userSkills.length > 0 ? Math.min(99, Math.max(65, Math.round((matchCount / userSkills.length) * 100) + 15)) : 70;
        return {
          ...job,
          matchScore: matchCount > 0 ? score : 65,
          matchedSkill: userSkills.find(skill => text.includes(skill)) || userSkills[0]
        };
      }).filter(job => job.matchScore >= 65);

      return matched.sort((a, b) => b.matchScore - a.matchScore);
    },

    // ----------------------------------------------------
    // Analytics & Metrics
    // ----------------------------------------------------
    getMetrics() {
      const users = getTable(STORAGE_KEY_USERS);
      const jobs = getTable(STORAGE_KEY_JOBS);
      const apps = getTable(STORAGE_KEY_APPS);
      const interviews = getTable(STORAGE_KEY_INTERVIEWS);

      const candidates = users.filter(u => u.role === 'Candidate');
      const hrs = users.filter(u => u.role === 'HR');

      const pendingApps = apps.filter(a => a.status === 'Pending').length;
      const shortlistedApps = apps.filter(a => a.status === 'Shortlisted' || a.status === 'Accepted').length;
      const rejectedApps = apps.filter(a => a.status === 'Rejected').length;

      const totalUsers = candidates.length + hrs.length;
      const totalApps = apps.length;

      return {
        totalUsers: users.length,
        totalCandidates: candidates.length,
        totalHR: hrs.length,
        candPct: totalUsers > 0 ? ((candidates.length / totalUsers) * 100).toFixed(1) : "0.0",
        hrPct: totalUsers > 0 ? ((hrs.length / totalUsers) * 100).toFixed(1) : "0.0",
        totalJobs: jobs.length,
        activeJobs: jobs.filter(j => j.approval_status === 'Approved').length,
        pendingJobs: jobs.filter(j => j.approval_status === 'Pending').length,
        totalApplications: totalApps,
        pendingApps,
        acceptedApps: shortlistedApps,
        rejectedApps,
        pendingPct: totalApps > 0 ? ((pendingApps / totalApps) * 100).toFixed(1) : "0.0",
        acceptedPct: totalApps > 0 ? ((shortlistedApps / totalApps) * 100).toFixed(1) : "0.0",
        rejectedPct: totalApps > 0 ? ((rejectedApps / totalApps) * 100).toFixed(1) : "0.0",
        totalInterviews: interviews.length
      };
    },

    getHRMetrics(hrId) {
      hrId = parseInt(hrId);
      const hrJobs = getTable(STORAGE_KEY_JOBS).filter(j => j.posted_by === hrId);
      const hrJobIds = hrJobs.map(j => j.job_id);
      const hrApps = getTable(STORAGE_KEY_APPS).filter(a => hrJobIds.includes(a.job_id));
      const hrAppIds = hrApps.map(a => a.application_id);
      const hrInterviews = getTable(STORAGE_KEY_INTERVIEWS).filter(i => hrAppIds.includes(i.application_id));

      return {
        totalJobs: hrJobs.length,
        totalApplications: hrApps.length,
        totalInterviews: hrInterviews.length
      };
    }
  };
})();

// Attach to window object
window.CareerLinkDB = CareerLinkDB;
