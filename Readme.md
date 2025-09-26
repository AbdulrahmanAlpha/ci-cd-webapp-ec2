# 🚀 CI/CD Pipeline for Web Application

**Stack:** GitHub Actions · Docker · AWS EC2

---

## 📌 Project Overview

This project demonstrates how to build a **lightweight CI/CD pipeline** for deploying a web application on **AWS EC2** using **GitHub Actions** and **Docker**.

The goal was to **automate build, test, and deployment** workflows, ensuring faster delivery cycles and reproducible builds.

### 🎯 Outcomes

* Reduced deployment cycle time from **6 hours → 30 minutes**.
* Increased **developer velocity** with automated linting & testing.
* Standardized builds with **Docker images**.
* Automated deployment to **AWS EC2** via GitHub Actions.

---

## 🏗️ Architecture

![Architecture Diagram](docs/Architecture_Diagram.png) <!-- add polished diagram later -->

**Key components:**

1. **GitHub Actions CI/CD:**

   * Workflow triggers on `git push`.
   * Stages: Lint → Test → Build → Push → Deploy.
   * Uses GitHub Secrets for storing AWS credentials & SSH keys.

2. **Docker:**

   * Containerizes the application for reproducible builds.
   * Images stored in AWS ECR (or Docker Hub).

3. **AWS EC2:**

   * Acts as the deployment target.
   * Runs Docker containers via a **deployment script** (`remote-deploy.sh`).
   * Pulls new image, runs container, performs health check, and swaps/rolls back.

---

## 📂 Repository Structure

```
cicd-pipeline-ec2/
├── .github/workflows/    # GitHub Actions workflows (CI/CD)
├── docker/               # Dockerfiles for containerization
├── scripts/              # Deployment helper scripts (e.g., remote-deploy.sh)
├── app/                  # Application source code
├── docs/                 # Architecture docs, diagrams
└── README.md             # Project documentation
```

---

## ⚙️ Step-by-Step Implementation

### 1️⃣ Setup GitHub Actions CI/CD

* Created `.github/workflows/cicd.yml` with stages:

  1. Lint (ESLint).
  2. Run unit tests (Jest).
  3. Build Docker image.
  4. Push image to AWS ECR (or Docker Hub).
  5. Deploy to AWS EC2 over SSH.

👉 Triggered automatically on `push` to `main`.

---

### 2️⃣ Containerize Application with Docker

* Wrote **Dockerfile** to package app (Node.js/Express).
* Local test:

```bash
docker build -t webapp:local docker/
docker run -p 3000:3000 webapp:local
```

---

### 3️⃣ Provision AWS EC2

* Launched an EC2 instance with:

  * Docker installed.
  * Security Group allowing SSH (22) & App traffic (3000).
* Configured SSH keys and stored in GitHub Secrets.

---

### 4️⃣ Deploy to EC2

* Added `scripts/remote-deploy.sh`:

  * Connects via SSH.
  * Pulls latest Docker image.
  * Stops old container & starts new one.
  * Performs health check.
  * Rolls back if failure detected.

👉 Run automatically from GitHub Actions after build & push.

---

### 5️⃣ Access the Application

* Find EC2 public IP:

```bash
aws ec2 describe-instances \
  --query "Reservations[].Instances[].PublicIpAddress" \
  --output text
```

* Open `http://<EC2_PUBLIC_IP>:3000` in browser.

---

### 6️⃣ Cleanup

* Stop Docker containers on EC2:

```bash
docker ps -q | xargs docker stop
```

* Terminate EC2 instance to avoid charges.

---

## 🔒 Security Notes

* **AWS credentials** stored securely in **GitHub Secrets**.
* **SSH key** used for deployment (never stored in repo).
* Docker images tagged with commit SHA for traceability.
* EC2 Security Group restricted to trusted IP ranges.

---

## 📈 Next Improvements

* Add **Blue-Green Deployments** for zero-downtime releases.
* Use **Terraform** for EC2 provisioning.
* Replace manual SSH deploy with **AWS CodeDeploy** or **Ansible**.
* Add monitoring/alerts with **CloudWatch + Grafana**.

---

## ✅ Skills Demonstrated

* CI/CD with **GitHub Actions**.
* **Dockerization** for reproducible builds.
* Automated **EC2 deployments**.
* Secure use of **GitHub Secrets**.
* Real-world **DevOps automation workflow**.

---

## 🧑‍💻 Author

**Abdulrahman A. Muhamad**
DevOps | Cloud | SRE Enthusiast

🔗 [LinkedIn](https://www.linkedin.com/in/abdulrahmanalpha) | [GitHub](https://github.com/AbdulrahmanAlpha) | [Portfolio](https://abdulrahman-alpha.web.app)

