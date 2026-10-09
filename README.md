# EKS Project — Production-Grade Kubernetes on AWS

A production-grade Kubernetes cluster on Amazon EKS, running IT-Tools over HTTPS with GitOps, monitoring, and full CI/CD automation.

**Live URL:** https://eks.ismaaeelahmed.co.uk *(demo — infrastructure destroyed after submission to avoid AWS charges)*

---

## Architecture

```mermaid
graph TB
    User([User Browser])
    
    User -->|HTTPS| CF[Cloudflare DNS<br/>eks.ismaaeelahmed.co.uk]
    CF -->|CNAME| NLB[AWS Network<br/>Load Balancer]
    
    subgraph AWS["AWS Cloud - eu-west-2"]
        subgraph VPC["VPC 10.0.0.0/16"]
            subgraph PublicSubnets["Public Subnets"]
                NLB
            end
            subgraph PrivateSubnets["Private Subnets"]
                subgraph EKS["EKS Cluster - k8s 1.31"]
                    Ingress[NGINX Ingress<br/>Controller]
                    ITTools[IT-Tools Pods<br/>2 replicas]
                    CertMgr[CertManager]
                    ExtDNS[ExternalDNS]
                    ArgoCD[ArgoCD]
                    Prom[Prometheus]
                    Graf[Grafana]
                end
                Nodes[Worker Nodes<br/>4x t3.small]
            end
            ECR[(ECR Repository<br/>it-tools)]
            KMS[KMS Key<br/>Secrets encryption]
        end
    end
    
    subgraph GitHub["GitHub"]
        Repo[eks-project repo]
        Actions[GitHub Actions]
        OIDC[OIDC Provider]
    end
    
    NLB --> Ingress
    Ingress --> ITTools
    CertMgr -.->|SSL certs| Ingress
    ExtDNS -.->|DNS records| CF
    ArgoCD -.->|GitOps sync| ITTools
    Prom --> Graf
    Prom -.->|scrapes| Ingress
    Prom -.->|scrapes| ITTools
    ECR -.->|pulls image| ITTools
    KMS -.->|encrypts| EKS
    
    Actions -->|build + push| ECR
    Actions -->|terraform apply| AWS
    Actions -->|kubectl deploy| EKS
    OIDC -.->|auth| Actions
    Repo --> ArgoCD
```

---

## Project Board

Tracked progress via [GitHub Projects](https://github.com/users/ismaaeelahmed11/projects/1):

![Project board](screenshots/30-github-project-board.png)

---

## Overview

| Component | What it does |
|-----------|-------------|
| **EKS Cluster** | Managed Kubernetes control plane (v1.31) |
| **Worker Nodes** | 4× t3.small EC2 instances in private subnets |
| **VPC** | Custom network with public (LB) and private (nodes) subnets |
| **NGINX Ingress** | Routes external HTTP/HTTPS traffic into the cluster |
| **CertManager** | Auto-issues SSL certificates from Let's Encrypt |
| **ExternalDNS** | Auto-creates DNS records in Cloudflare |
| **ArgoCD** | GitOps — syncs cluster state to Git |
| **Prometheus + Grafana** | Monitoring and dashboards |
| **IT-Tools** | The app — a collection of developer utilities |
| **GitHub Actions** | CI/CD for Terraform and app deployment |

---

## The Big Four

### What is this app?

**IT-Tools** is an open-source collection of handy utilities for developers — JSON formatters, hash generators, regex testers, subnet calculators, and 80+ other tools. It's a real production container used by thousands of developers.

I chose it because the EKS project focuses on **infrastructure and orchestration**, not app development. Deploying a real, useful container demonstrates platform engineering skills better than a custom "Hello World".

### Why this application?

- **Real production tool** — used by developers daily, not a toy demo
- **No database, no complexity** — pure infrastructure focus
- **Static web app** — easy to expose via Ingress + SSL
- **Lightweight** — small footprint, quick to scale
- **Realistic** — this is what you'd deploy in a real DevOps environment

### Why EKS? Why not ECS or a simpler option?

**Why not ECS:** I already built a production-grade ECS project earlier in the bootcamp — it taught me container orchestration at the service level. EKS is the natural next step: managed Kubernetes is the industry standard for orchestration at scale, and it teaches portable skills.

**Why not Vercel/Netlify:** They don't teach Kubernetes. This project is about learning production Kubernetes: Ingress, CertManager, ExternalDNS, ArgoCD, Prometheus, IRSA, and more.

**Why EKS specifically:**
- AWS-native managed Kubernetes — used in real DevOps roles
- Teaches portable skills (Kubernetes runs anywhere)
- Integrates cleanly with the rest of AWS (IAM, VPC, ECR)
- Prepares for multi-cloud and hybrid environments

### How many users are expected?

This is a portfolio project, so no real users. But the architecture is production-ready:

- **Multi-AZ** — 4 worker nodes across availability zones
- **2 replicas** of IT-Tools for high availability
- **Auto-sync + self-heal** via ArgoCD
- **Horizontal scaling** — bump replicas or add nodes as needed
- **HTTPS** with auto-renewing Let's Encrypt certs

If real traffic hit it, I'd increase replicas or node group size in Terraform. The platform is designed to scale.

---

## Project Structure

```
eks-project/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── backend.tf
│   └── modules/
│       ├── vpc/
│       ├── eks/
│       ├── irsa/
│       └── oidc/
├── helm/
│   ├── ingress-nginx/
│   ├── cert-manager/
│   ├── external-dns/
│   ├── argocd/
│   └── monitoring/
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── cluster-issuer.yaml
├── argocd/
│   └── applications/
│       └── it-tools.yaml
├── .github/
│   └── workflows/
│       ├── terraform-apply.yml
│       ├── terraform-destroy.yml
│       └── app-deploy.yml
├── screenshots/
├── docs/
└── README.md
```

---

## Getting Started

### Prerequisites

- AWS account with CLI configured
- Terraform 1.11+
- kubectl
- Helm 3+
- A domain in Cloudflare

### Deploy the infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This creates:
- VPC with public and private subnets
- EKS cluster with managed node group
- IAM roles for EKS, nodes, GitHub Actions, EBS CSI

### Configure kubectl

```bash
aws eks update-kubeconfig --name eks-project-cluster --region eu-west-2
kubectl get nodes
```

### Install cluster add-ons

```bash
# NGINX Ingress
cd helm/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace --values values.yaml

# CertManager
cd ../cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace --values values.yaml

# ExternalDNS (requires Cloudflare API token secret)
kubectl create namespace external-dns
kubectl create secret generic cloudflare-api-token \
  --namespace external-dns --from-literal=api-token=YOUR_TOKEN
cd ../external-dns
helm install external-dns external-dns/external-dns \
  --namespace external-dns --values values.yaml
```

### Deploy the app

```bash
kubectl apply -f k8s/
```

### Set up ArgoCD

```bash
cd helm/argocd
helm install argocd argo/argo-cd \
  --namespace argocd --create-namespace --values values.yaml

kubectl apply -f argocd/applications/it-tools.yaml
```

### Install monitoring

```bash
cd helm/monitoring
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace --values values.yaml
```

### Access the app

```
https://eks.ismaaeelahmed.co.uk
```

---

## CI/CD Pipelines

| Pipeline | Trigger | What it does |
|----------|---------|-------------|
| **Terraform Apply** | Push to `terraform/**` | Provisions EKS, VPC, IAM via OIDC |
| **Terraform Destroy** | Manual (confirm "destroy") | Tears down all infrastructure |
| **App Build, Scan & Deploy** | Push to `k8s/**` | Checkov scan → Trivy scan → push ECR → deploy to EKS |

All pipelines use **OIDC** — no static AWS keys.

---

## What I Learned

- **EKS architecture** — control plane vs worker nodes, managed node groups
- **IRSA** (IAM Roles for Service Accounts) — pods assuming AWS roles via OIDC
- **Ingress + CertManager + ExternalDNS** — the trio that automates external access
- **GitOps with ArgoCD** — cluster state follows Git, self-heals drift
- **Prometheus + Grafana** — real observability with custom dashboards
- **OIDC authentication** — no more static AWS credentials in CI/CD
- **Node capacity planning** — t3.small limits, EBS CSI driver, pod scheduling
- **Debugging EKS** — access entries, kubectl auth, PVC binding

---

## Troubleshooting Journey

**Issue 1: Container port conflicts**
Non-root containers can't bind to privileged ports. Fixed by using 8080 for the container and 443 at the load balancer.

**Issue 2: OIDC trust policy**
GitHub's immutable subject claims broke the trust policy. Fixed by adding both old and new formats to `sub` conditions.

**Issue 3: Pods stuck Pending**
Node capacity limit on t3.small (~11 pods per node). Fixed by scaling to 4 nodes.

**Issue 4: PVCs stuck Pending**
EBS CSI driver wasn't installed. Then it crashed without an IAM role. Fixed by adding IRSA + the driver as an EKS add-on.

**Issue 5: EKS access entries conflict**
Module's `cluster_creator` auto-admin clashed with explicit access entries. Fixed by disabling auto-admin and managing entries explicitly.

---

## Cost Management

EKS is expensive to run continuously:

- Control plane: ~$2.40/day
- 4× t3.small nodes: ~$2.40/day
- NAT Gateway: ~$1.08/day
- Load balancer: ~$0.50/day
- **Total: ~$6.50/day (~£45/week)**

Destroyed after submission. Screenshots and code preserved in this repo.

---

## Screenshots

### Infrastructure Setup
![Repo structure](screenshots/01-repo-structure.png)
![S3 state bucket](screenshots/02-tfstate-bucket.png)
![Terraform init](screenshots/04-terraform-init.png)
![Terraform plan VPC](screenshots/05-terraform-plan-vpc.png)
![Terraform apply VPC](screenshots/06-terraform-apply-vpc.png)
![Terraform plan EKS](screenshots/08-terraform-plan-eks.png)
![Terraform apply EKS](screenshots/09-terraform-apply-eks.png)

### Cluster Running
![EKS nodes running](screenshots/10-eks-nodes-running.png)
![NGINX Ingress installed](screenshots/11-nginx-ingress-installed.png)
![CertManager installed](screenshots/12-certmanager-installed.png)
![ClusterIssuer ready](screenshots/13-clusterissuer-ready.png)
![ExternalDNS installed](screenshots/14-externaldns-installed.png)

### Application Deployment
![IT-Tools pushed to ECR](screenshots/15-it-tools-pushed-to-ecr.png)
![IT-Tools deployed](screenshots/16-it-tools-deployed.png)
![IT-Tools live HTTPS](screenshots/17-it-tools-live-https.png)

### CI/CD Pipelines
![Terraform Apply pipeline green](screenshots/20-terraform-pipeline-green.png)
![OIDC trust policy](screenshots/20a-oidc-trust-policy.png)
![App Deploy pipeline green](screenshots/21-app-deploy-pipeline-green.png)

### GitOps with ArgoCD
![ArgoCD installed](screenshots/23-argocd-installed.png)
![ArgoCD synced](screenshots/24-argocd-synced.png)
![ArgoCD UI tree](screenshots/29-argocd-ui.png)

### Monitoring
![Monitoring pending (debug)](screenshots/25-monitoring-debug-pending-pods.png)
![Monitoring running](screenshots/26-monitoring-running.png)
![Grafana dashboard](screenshots/27-grafana-dashboard.png)

### Project Management
![GitHub Project board](screenshots/30-github-project-board.png)

---

*Built with Terraform, Helm, EKS, ArgoCD, Prometheus, and GitHub Actions.*