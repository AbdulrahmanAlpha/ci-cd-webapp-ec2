# EC2 setup (Ubuntu) — One-shot bootstrap

1. Launch an EC2 instance (Ubuntu 22.04) in the same region as ECR.
   - Security group: allow SSH (22) from your IP, and optionally port 80 if you want the app public.
   - (Optional) Attach IAM role with AmazonEC2ContainerRegistryReadOnly permission so EC2 can pull from ECR without storing AWS creds.

2. SSH into the instance:
   ssh -i path/to/key.pem ubuntu@<EC2_PUBLIC_IP>

3. Install Docker:
   sudo apt-get update
   sudo apt-get install -y docker.io
   sudo systemctl enable --now docker
   sudo usermod -aG docker $USER

4. Install curl & jq:
   sudo apt-get install -y curl jq

5. Create deploy script directory and set up remote-deploy script:
   mkdir -p ~/deploy_state
   # Upload remote-deploy.sh from repo or paste its contents into /home/ubuntu/remote-deploy.sh and chmod +x

6. Test pulling images (if IAM role or aws creds available):
   docker pull <ECR_REGISTRY>/<ECR_REPOSITORY>:<tag>

7. (Optional) To allow non-root docker use without re-login:
   newgrp docker
