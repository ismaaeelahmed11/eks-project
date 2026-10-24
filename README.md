# AWS EKS — End-to-End Production-Grade Kubernetes, GitOps & Monitoring

**AWS · Terraform · Kubernetes · Helm · Argo CD · GitHub Actions · Prometheus · Grafana**

Built and deployed an end-to-end Kubernetes platform on **Amazon EKS**, applying **production-grade engineering practices** across infrastructure as code, automated CI/CD, GitOps, HTTPS, monitoring and security scanning.

The project covers the full deployment process: provisioning AWS infrastructure with Terraform, configuring networking and Kubernetes add-ons, deploying a containerised application, automating delivery and troubleshooting operational issues.

**Project outcome:** Four EKS worker nodes across two Availability Zones, two IT-Tools replicas, HTTPS access, Argo CD GitOps reconciliation, Prometheus/Grafana monitoring and successful GitHub Actions workflows.

> **Deployment status:** The project was successfully deployed and demonstrated at `https://eks.ismaaeelahmed.co.uk`. AWS resources were subsequently destroyed to avoid ongoing costs. The URL is retained as a record of the deployment, not as a currently available service. Source code, architecture diagrams, pipeline runs and screenshots are preserved in this repository.

---

## Project Walkthrough

A technical walkthrough covering the EKS architecture, Terraform provisioning, Kubernetes application deployment, Argo CD, monitoring, CI/CD and troubleshooting.

[![Watch the AWS EKS Project Walkthrough](https://img.youtube.com/vi/RDmnaTi2auE/hqdefault.jpg)](https://youtu.be/RDmnaTi2auE)

**[▶ Watch the AWS EKS Project Walkthrough (2:29)](https://youtu.be/RDmnaTi2auE)**

---

## Architecture

![AWS EKS Architecture](screenshots/31-architecture-drawio.png)

### How the platform works

**Application traffic**

1. A user accesses `eks.ismaaeelahmed.co.uk` over HTTPS.
2. Cloudflare DNS resolves the application hostname.
3. An AWS Network Load Balancer exposes the NGINX Ingress Controller.
4. NGINX Ingress routes requests to the IT-Tools Kubernetes Service.
5. The Service distributes traffic to the two IT-Tools application replicas.

**Infrastructure and deployment**

- **Terraform** provisions the VPC, EKS cluster, managed node group and supporting AWS resources.
- **Helm** installs and configures Kubernetes add-ons.
- **GitHub Actions** automates infrastructure changes, security scans and application deployment workflows.
- **AWS OIDC authentication** allows GitHub Actions to assume IAM roles without long-lived AWS access keys.

**Kubernetes platform services**

- **cert-manager** manages TLS certificates issued by Let's Encrypt.
- **ExternalDNS** manages application DNS records through Cloudflare.
- **Argo CD** monitors Git and reconciles Kubernetes application resources.
- **Prometheus** collects metrics from the Kubernetes environment.
- **Grafana** provides dashboards for cluster resource usage and monitoring.

The EKS managed control plane runs in AWS, while the application workloads and supporting services run on EC2 worker nodes in private subnets.

---

## Deployment Evidence — At a Glance

These four screenshots show the main deployment outcomes without requiring you to expand the detailed evidence gallery below.

### EKS worker nodes Ready

Four EKS worker nodes running across two Availability Zones.

![Four EKS worker nodes in Ready state](screenshots/10-eks-nodes-running.png)

### CI/CD pipeline successful

GitHub Actions Terraform Apply pipeline completed successfully using AWS OIDC authentication.

![GitHub Actions Terraform Apply pipeline successful](screenshots/20-terraform-pipeline-green.png)

### Argo CD Synced and Healthy

The IT-Tools application reconciled successfully through Argo CD GitOps.

![Argo CD application Synced and Healthy](screenshots/24-argocd-synced.png)

### Grafana monitoring dashboard

Grafana showing Kubernetes CPU, memory and namespace-level metrics captured from the running cluster.

![Grafana Kubernetes monitoring dashboard](screenshots/27-grafana-dashboard.png)

For the complete infrastructure, application, security and troubleshooting evidence, see [Implementation Evidence](#implementation-evidence).

---

## Infrastructure Overview

| Component | Implementation |
| --- | --- |
| **Cloud Provider** | AWS — `eu-west-2` (London) |
| **Kubernetes Platform** | Amazon EKS |
| **Kubernetes Version** | v1.31 (v1.31.14 shown in deployment evidence) |
| **Worker Nodes** | 4 × `t3.small` EC2 instances |
| **Availability Zones** | Two |
| **Networking** | VPC with public and private subnets |
| **Ingress** | NGINX Ingress Controller with AWS Network Load Balancer |
| **TLS Certificates** | cert-manager and Let's Encrypt |
| **DNS** | ExternalDNS and Cloudflare |
| **Container Registry** | Amazon ECR |
| **Application** | IT-Tools — 2 replicas |
| **GitOps** | Argo CD |
| **Monitoring** | Prometheus and Grafana |
| **Infrastructure as Code** | Terraform |
| **CI/CD** | GitHub Actions with AWS OIDC |
| **Security Scanning** | Checkov and Trivy |
| **Persistent Storage** | Amazon EBS CSI Driver |

The platform applies **production-grade engineering practices** such as modular infrastructure as code, multi-AZ worker nodes, GitOps, monitoring and automated security checks. It was a time-limited portfolio deployment rather than a commercially operated or fully production-validated service.

---

## Engineering Decisions

### Why IT-Tools?

[IT-Tools](https://github.com/CorentinTh/it-tools) is an open-source collection of developer utilities, including JSON formatters, hash generators, regex testers and subnet calculators.

I chose an existing application because the main objective was to build and operate the infrastructure around it rather than focus on application development.

This allowed me to work directly with:

- Kubernetes application deployments and services
- Container registry integration
- Ingress routing and HTTPS
- Multiple application replicas
- GitOps reconciliation
- CI/CD automation
- Resource monitoring and troubleshooting

Using an existing application gave me a realistic workload to deploy without introducing unnecessary application or database complexity.

### Why Amazon EKS?

I had previously built an end-to-end AWS ECS Fargate deployment and wanted to take the next step into Kubernetes platform engineering.

ECS provided experience with AWS-native container orchestration. EKS introduced additional responsibilities around Kubernetes networking, ingress controllers, Helm, GitOps, persistent storage, cluster capacity and workload management.

I chose EKS because it combines managed AWS infrastructure with standard Kubernetes tooling.

### Why four worker nodes?

The original worker-node configuration encountered capacity constraints as additional platform components were deployed.

NGINX Ingress, Argo CD, cert-manager, ExternalDNS and the monitoring stack all require resources alongside the IT-Tools application.

Some workloads remained in `Pending` while the cluster lacked sufficient capacity.

I investigated pod scheduling and node resource availability before increasing the managed node group to four `t3.small` instances.

This was a practical exercise in understanding Kubernetes scheduling and infrastructure capacity rather than simply increasing replicas without investigating the underlying issue.

### Availability and scaling

The environment was configured with:

- Four worker nodes across two Availability Zones
- Two IT-Tools application replicas
- Kubernetes readiness and liveness probes
- Resource requests and limits
- Argo CD automated reconciliation
- HTTPS with certificate management

These choices provide useful resilience and operational practices for the lab.

I did not conduct formal load testing, disaster recovery exercises or long-term production availability testing, so the project is not presented as production-proven.

---

## Project Structure

```text
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
│
├── helm/
│   ├── ingress-nginx/
│   ├── cert-manager/
│   ├── external-dns/
│   ├── argocd/
│   └── monitoring/
│
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── cluster-issuer.yaml
│
├── argocd/
│   └── applications/
│       └── it-tools.yaml
│
├── .github/
│   └── workflows/
│       ├── terraform-apply.yml
│       ├── terraform-destroy.yml
│       └── app-deploy.yml
│
├── screenshots/
├── .gitignore
└── README.md
```

The repository separates AWS infrastructure, Helm configuration, application manifests, GitOps resources, CI/CD workflows and deployment evidence.

---

## Infrastructure Provisioning with Terraform

Terraform was used to provision and manage the AWS infrastructure instead of manually configuring each service through the AWS Console.

The infrastructure includes:

- VPC networking
- Public and private subnets
- Internet connectivity and NAT
- EKS cluster and managed worker nodes
- IAM roles and permissions
- OIDC integration
- Supporting Kubernetes add-on permissions

### Remote Terraform state

The project uses an Amazon S3 backend for Terraform state.

The state bucket was configured with versioning, encryption and public access blocked.

Remote state allows the infrastructure configuration to be managed consistently between local development and GitHub Actions workflows.

The project also uses S3 native state locking to reduce the risk of conflicting Terraform operations.

### Infrastructure workflow

The core provisioning process was:

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply
```

The first Terraform plan provisioned 14 VPC-related resources.

The EKS infrastructure plan subsequently included 33 additional resources.

Terraform outputs were used to obtain infrastructure identifiers and cluster connection details.

**Deployment evidence**

- [Terraform initialisation](screenshots/04-terraform-init.png)
- [VPC Terraform plan](screenshots/05-terraform-plan-vpc.png)
- [VPC Terraform apply](screenshots/06-terraform-apply-vpc.png)
- [EKS Terraform plan](screenshots/08-terraform-plan-eks.png)
- [EKS Terraform apply](screenshots/09-terraform-apply-eks.png)

---

## Kubernetes Application Deployment

### Connecting to EKS

After provisioning the cluster, I configured `kubectl` using the AWS CLI:

```bash
aws eks update-kubeconfig \
  --name eks-project-cluster \
  --region eu-west-2

kubectl get nodes
```

The deployment evidence shows four Kubernetes worker nodes in the `Ready` state.

### Deploying IT-Tools

The IT-Tools container image was pulled from Docker Hub, tagged and published to Amazon ECR.

Kubernetes manifests were then used to define the application resources.

These included:

- Namespace
- Deployment
- ClusterIP Service
- Ingress
- ClusterIssuer

The application was configured with two replicas.

```bash
kubectl apply -f k8s/

kubectl get deployments -A
kubectl get pods -A
kubectl get ingress -A
```

These commands are run from the repository root.

### Application networking

NGINX Ingress was installed through Helm and exposed externally using an AWS Network Load Balancer.

ExternalDNS was configured to manage Cloudflare DNS records based on Kubernetes resources.

cert-manager used Let's Encrypt to issue the TLS certificate.

This allowed the application to be accessed over HTTPS at:

`https://eks.ismaaeelahmed.co.uk`

**Deployment evidence**

- [EKS worker nodes](screenshots/10-eks-nodes-running.png)
- [NGINX Ingress](screenshots/11-nginx-ingress-installed.png)
- [cert-manager](screenshots/12-certmanager-installed.png)
- [ClusterIssuer](screenshots/13-clusterissuer-ready.png)
- [ExternalDNS](screenshots/14-externaldns-installed.png)
- [IT-Tools deployment](screenshots/16-it-tools-deployed.png)
- [Application over HTTPS](screenshots/17-it-tools-live-https.png)

---

## GitOps with Argo CD

Argo CD was implemented to manage Kubernetes application resources declaratively through Git.

Instead of relying only on manual `kubectl apply` commands, the application definition was stored in the repository and connected to Argo CD.

### How it works

1. The desired Kubernetes configuration is stored in Git.
2. Argo CD monitors the configured repository path.
3. Changes are detected and reconciled against the cluster.
4. Argo CD reports application synchronisation and health status.
5. Automated reconciliation can restore resources that drift from the desired configuration.

The IT-Tools application was successfully shown as **Synced** and **Healthy**.

This provided direct experience with managing Kubernetes application state through Git rather than relying entirely on manual changes.

**Evidence**

- [Argo CD installed](screenshots/23-argocd-installed.png)
- [Application synced and healthy](screenshots/24-argocd-synced.png)
- [Argo CD resource tree](screenshots/29-argocd-ui.png)

---

## CI/CD with GitHub Actions

Three GitHub Actions workflows were used to automate infrastructure management and application delivery.

| Workflow | Trigger | Responsibility |
| --- | --- | --- |
| **Terraform Apply** | Changes pushed to `terraform/**` | Terraform plan and infrastructure apply |
| **Terraform Destroy** | Manual confirmation | Infrastructure teardown |
| **App Build, Scan & Deploy** | Changes pushed to `k8s/**` | Security scanning, container publishing and application deployment |

### Infrastructure automation

The Terraform Apply workflow authenticates to AWS using OIDC, then executes the Terraform deployment process.

This removes the need to store long-lived AWS access keys in GitHub Actions secrets.

### Application delivery

The application workflow includes:

1. Checkov scanning for Terraform configuration.
2. Container image preparation.
3. Trivy container security scanning.
4. Publishing the image to Amazon ECR.
5. Deploying the application to Amazon EKS.

### Security considerations

The workflows use AWS IAM roles and OIDC federation.

This limits reliance on permanent credentials and supports role-based access from the CI/CD environment.

The project also uses:

- IAM permissions
- HTTPS/TLS
- Checkov infrastructure scanning
- Trivy image scanning
- Private networking for worker nodes

These controls demonstrate practical security considerations, although they do not represent a complete enterprise security review.

**Evidence**

- [Terraform Apply workflow](screenshots/20-terraform-pipeline-green.png)
- [OIDC IAM trust policy](screenshots/20a-oidc-trust-policy.png)
- [Application deployment workflow](screenshots/21-app-deploy-pipeline-green.png)

---

## Monitoring and Observability

Prometheus and Grafana were deployed using the `kube-prometheus-stack` Helm chart.

The monitoring environment provided visibility into cluster and workload resource usage.

The deployment included:

- Prometheus
- Grafana
- Alertmanager
- Node exporters
- Kubernetes monitoring components

### Metrics captured

Grafana dashboards displayed:

- Cluster CPU utilisation
- Cluster memory utilisation
- Namespace-level resource usage
- Resource consumption across platform services
- Live Kubernetes resource metrics

The captured dashboard showed approximately **3.54% CPU utilisation** and **52.1% memory utilisation** at the time of observation.

These figures represent a deployment snapshot, not a long-term performance benchmark.

### Monitoring deployment issue

The monitoring stack initially failed because workloads requiring persistent volumes could not schedule successfully.

Investigating this issue led to configuring the Amazon EBS CSI Driver and its required AWS permissions.

Once the storage and node-capacity issues were resolved, the monitoring workloads reached the `Running` state.

**Evidence**

- [Monitoring pods initially Pending](screenshots/25-monitoring-debug-pending-pods.png)
- [Monitoring workloads Running](screenshots/26-monitoring-running.png)
- [Grafana monitoring dashboard](screenshots/27-grafana-dashboard.png)

---

## Troubleshooting and Root Cause Analysis

Several technical issues arose during the project. Rather than leaving them out, I've documented what failed, what I investigated and how each issue was resolved.

### 1. Container port configuration

**Problem:** The container's port configuration conflicted with the intended non-root runtime configuration.

**Investigation:** Reviewed the container's listening port and the relationship between the application, Service and external HTTPS entry point.

**Resolution:** Configured the application to use port `8080` internally while exposing HTTPS through the ingress/load-balancing layer.

**Takeaway:** Container ports, Kubernetes Services and external listeners are separate parts of the traffic path and need to be configured consistently.

### 2. GitHub Actions OIDC trust policy

**Problem:** GitHub Actions could not authenticate to AWS as expected.

**Investigation:** Examined the IAM role trust policy and OIDC subject claim conditions.

**Resolution:** Updated the trust policy conditions to support the subject claim formats encountered during the deployment.

**Takeaway:** OIDC authentication depends on matching token claims and IAM trust policy conditions. Authentication problems require inspecting both sides.

### 3. Pods stuck in `Pending`

**Problem:** Kubernetes workloads remained in the `Pending` state after deploying additional platform components.

**Investigation:** Inspected pod scheduling, node capacity and the resource requirements of the Kubernetes add-ons.

**Root cause:** The existing `t3.small` worker nodes could not accommodate the growing number of workloads.

**Resolution:** Adjusted the EKS managed node group to four worker nodes.

**Takeaway:** Platform components consume cluster resources too. Capacity planning needs to account for ingress, GitOps, monitoring and other supporting services, not just the application.

### 4. PersistentVolumeClaims stuck in `Pending`

**Problem:** Prometheus and other monitoring workloads could not successfully provision persistent storage.

**Investigation:** Checked the PVCs, storage provisioning and EBS CSI Driver configuration.

**Root cause:** The EBS CSI Driver was initially missing. After installation, it also required the appropriate IAM permissions.

**Resolution:** Configured the EBS CSI Driver as an EKS add-on and provided the required IAM role through IRSA.

**Takeaway:** Kubernetes storage depends on correctly configured CSI drivers and cloud permissions. A running cluster does not automatically guarantee working persistent storage.

### 5. EKS cluster access conflicts

**Problem:** Kubernetes access configuration encountered conflicts during EKS setup.

**Investigation:** Reviewed the Terraform EKS module's cluster creator administration settings alongside explicitly managed access entries.

**Root cause:** Automatic cluster creator administrator configuration conflicted with the explicit access configuration.

**Resolution:** Disabled the conflicting automatic configuration and managed the EKS access entries explicitly.

**Takeaway:** Cluster access should have a clear source of configuration to avoid conflicting IAM and Kubernetes authentication behaviour.

### What these issues demonstrated

The most valuable part of the project was understanding why systems failed.

Troubleshooting involved working across several layers:

- Terraform infrastructure configuration
- AWS IAM and OIDC
- Kubernetes scheduling
- Persistent storage
- Container networking
- EKS access management
- GitHub Actions workflows

Each incident helped connect the infrastructure configuration to the behaviour of the running platform.

---

## Deployment Guide

This section outlines how the environment was deployed.

**Important:** The original AWS resources have been destroyed. Recreating the environment incurs AWS charges and requires valid AWS credentials, Cloudflare configuration, IAM permissions and review of the current Terraform and Helm dependencies.

The configuration was built against EKS Kubernetes v1.31. Review version compatibility and AWS support before attempting a fresh deployment.

### Prerequisites

- AWS account with suitable IAM permissions
- AWS CLI configured
- Terraform compatible with the repository
- `kubectl`
- Helm 3
- Cloudflare-managed domain
- Appropriate DNS and API token configuration
- GitHub Actions OIDC configuration for automated workflows

### 1. Clone the repository

```bash
git clone https://github.com/ismaaeelahmed11/eks-project.git

cd eks-project
```

### 2. Review Terraform configuration

Before deploying, review:

```text
terraform/
```

Check AWS region, cluster configuration, backend settings, networking, worker-node configuration and IAM permissions.

The remote state backend must be correctly configured and available before running `terraform init`.

### 3. Provision infrastructure

From the repository root:

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply

cd ..
```

Review the Terraform plan before approving infrastructure changes.

### 4. Configure Kubernetes access

```bash
aws eks update-kubeconfig \
  --name eks-project-cluster \
  --region eu-west-2

kubectl get nodes
kubectl get pods -A
```

### 5. Configure cluster add-ons

The project uses Helm configurations under:

```text
helm/ingress-nginx/
helm/cert-manager/
helm/external-dns/
helm/argocd/
helm/monitoring/
```

The original deployment installed NGINX Ingress, cert-manager, ExternalDNS, Argo CD and the Prometheus monitoring stack.

Helm repositories, chart versions, namespace configuration, custom values and cloud credentials should be checked before installation.

ExternalDNS also requires a Cloudflare API token with appropriate permissions.

Do not commit API tokens or other credentials to the repository.

### 6. Deploy application manifests

From the repository root:

```bash
kubectl apply -f k8s/

kubectl get deployments -A
kubectl get pods -A
kubectl get services -A
kubectl get ingress -A
```

The application configuration includes two IT-Tools replicas and a Kubernetes Service exposed through NGINX Ingress.

### 7. Configure Argo CD

The Argo CD application manifest is stored at:

```text
argocd/applications/it-tools.yaml
```

Once Argo CD is installed and configured, apply the application definition:

```bash
kubectl apply -f argocd/applications/it-tools.yaml
```

Verify that the application reaches `Synced` and `Healthy`.

### 8. Validate the deployment

Useful validation commands include:

```bash
kubectl get nodes

kubectl get pods -A

kubectl get ingress -A

kubectl get certificates -A

kubectl get pvc -A
```

Check the application through its configured HTTPS hostname and inspect Grafana dashboards and GitHub Actions workflow results.

### 9. Infrastructure teardown

A manually triggered GitHub Actions teardown workflow was created for removing AWS infrastructure after the demonstration.

Always review Terraform plans and destroy operations carefully. Resources such as state backends, persistent storage, load balancers or externally managed DNS records may require separate handling.

Destroying the EKS cluster does not automatically guarantee that every associated AWS resource has been removed.

---

## Cost Management

Amazon EKS and its supporting AWS infrastructure incur ongoing charges, even when the application receives no traffic.

The original project estimate was approximately **$6.50 per day**, including the EKS control plane, EC2 worker nodes, NAT Gateway and load-balancing resources.

This was a historical estimate for the demonstration configuration, **not a current AWS pricing quotation**. Actual charges depend on service pricing, Kubernetes support tier, region, resource usage and other factors.

To manage costs, I:

- Used a defined demonstration environment.
- Included infrastructure teardown in the GitHub Actions workflows.
- Removed the AWS resources after completing the project.
- Preserved screenshots, source code, architecture diagrams and pipeline evidence.

This kept the portfolio available for review without leaving paid infrastructure running indefinitely.

---

## Implementation Evidence

The 21 screenshots below provide detailed supporting evidence. Four key deployment screenshots are displayed above in [Deployment Evidence — At a Glance](#deployment-evidence--at-a-glance).

They capture both successful configurations and the problems encountered during implementation.

<details>
<summary><strong>1. Infrastructure & Terraform — 7 screenshots</strong></summary>

### Repository Structure

Terraform modules, Helm configuration, Kubernetes manifests, CI/CD workflows and project documentation.

![Repository Structure](screenshots/01-repo-structure.png)

### S3 Remote State

S3 bucket configured for Terraform state storage, versioning, encryption and blocked public access.

![S3 Terraform State](screenshots/02-tfstate-bucket.png)

### Terraform Initialisation

Terraform initialised against the configured S3 backend.

![Terraform Init](screenshots/04-terraform-init.png)

### Terraform VPC Plan

The VPC plan included 14 resources for networking and supporting infrastructure.

![VPC Terraform Plan](screenshots/05-terraform-plan-vpc.png)

### Terraform VPC Apply

Terraform successfully provisioned the VPC resources and generated outputs.

![VPC Terraform Apply](screenshots/06-terraform-apply-vpc.png)

### Terraform EKS Plan

Terraform planned the EKS infrastructure, including cluster components, IAM roles, security groups and add-ons.

![EKS Terraform Plan](screenshots/08-terraform-plan-eks.png)

### Terraform EKS Apply

EKS infrastructure was provisioned successfully.

![EKS Terraform Apply](screenshots/09-terraform-apply-eks.png)

</details>

<details>
<summary><strong>2. Kubernetes, Networking & HTTPS — 7 screenshots</strong></summary>

### NGINX Ingress

NGINX Ingress Controller deployed through Helm with an external AWS Network Load Balancer.

![NGINX Ingress](screenshots/11-nginx-ingress-installed.png)

### cert-manager

cert-manager controller components running.

![cert-manager](screenshots/12-certmanager-installed.png)

### ClusterIssuer

Let's Encrypt ClusterIssuer configured and reporting `Ready`.

![ClusterIssuer](screenshots/13-clusterissuer-ready.png)

### ExternalDNS

ExternalDNS running and configured for Cloudflare DNS management.

![ExternalDNS](screenshots/14-externaldns-installed.png)

### IT-Tools Container Image

IT-Tools image pushed to Amazon ECR.

![IT-Tools ECR](screenshots/15-it-tools-pushed-to-ecr.png)

### IT-Tools Deployment

Two application replicas, Service and Ingress resources deployed.

![IT-Tools Deployment](screenshots/16-it-tools-deployed.png)

### HTTPS Application Access

IT-Tools successfully accessed through the configured HTTPS hostname.

![IT-Tools HTTPS](screenshots/17-it-tools-live-https.png)

</details>

<details>
<summary><strong>3. CI/CD & AWS Authentication — 2 screenshots</strong></summary>

### AWS OIDC Trust Policy

IAM trust policy used by GitHub Actions for AWS authentication.

![OIDC Trust Policy](screenshots/20a-oidc-trust-policy.png)

### Application Build, Scan & Deploy

GitHub Actions workflow showing successful scanning and application delivery.

![Application CI/CD](screenshots/21-app-deploy-pipeline-green.png)

</details>

<details>
<summary><strong>4. Argo CD GitOps — 2 screenshots</strong></summary>

### Argo CD Installation

Argo CD components running in the Kubernetes cluster.

![Argo CD Installation](screenshots/23-argocd-installed.png)

### Argo CD Resource Tree

Kubernetes resources displayed through Argo CD's application view.

![Argo CD Application Tree](screenshots/29-argocd-ui.png)

</details>

<details>
<summary><strong>5. Monitoring & Troubleshooting — 2 screenshots</strong></summary>

### Initial Monitoring Failure

Monitoring pods stuck in `Pending` while persistent storage dependencies were unresolved.

![Monitoring Pods Pending](screenshots/25-monitoring-debug-pending-pods.png)

### Monitoring Workloads Running

Prometheus, Grafana and supporting workloads running after resolving storage and node-capacity issues.

![Monitoring Running](screenshots/26-monitoring-running.png)

</details>

<details>
<summary><strong>6. Project Tracking — 1 screenshot</strong></summary>

### GitHub Projects Board

Tracked work across infrastructure provisioning, Kubernetes add-ons, CI/CD, monitoring, troubleshooting and documentation.

![GitHub Project Board](screenshots/30-github-project-board.png)

</details>

---

## Project Planning

I used GitHub Projects to track tasks across the deployment, including infrastructure setup, Kubernetes configuration, automation, monitoring, troubleshooting and documentation.

[**View GitHub Project Board →**](https://github.com/users/ismaaeelahmed11/projects/1)

---

## What This Project Demonstrates

This project brought together infrastructure automation and Kubernetes platform operations in one end-to-end deployment.

The main areas of engineering work were:

- **AWS infrastructure:** Provisioning EKS, VPC networking, IAM and supporting resources with Terraform.
- **Kubernetes:** Managing application deployments, Services, Ingress, storage dependencies, health probes and workload capacity.
- **CI/CD:** Automating Terraform and application delivery through GitHub Actions.
- **GitOps:** Managing application state through Argo CD reconciliation.
- **Monitoring:** Deploying and troubleshooting Prometheus/Grafana.
- **Security:** Using IAM roles, OIDC, HTTPS and automated configuration/image scanning.
- **Troubleshooting:** Diagnosing real configuration, authentication, storage and scheduling problems.

The biggest takeaway was seeing how the different layers interact. A Kubernetes deployment problem can originate in AWS permissions, node capacity, networking or storage rather than in the application itself.

Understanding those dependencies and working through the failures was as important as getting the environment deployed.

---

## Project Context

This project was completed as part of my **CoderCo DevOps Engineering programme (January–October 2026)**.

It is an end-to-end AWS engineering project built with real cloud infrastructure and **production-grade engineering practices**. It was not operated as a commercial production service, and it has not been validated against every production-readiness requirement.

The environment was removed after completion to manage costs. The repository remains available as evidence of the infrastructure configuration, implementation, CI/CD workflows, monitoring and troubleshooting.

For related projects:

- [AWS ECS Fargate — End-to-End Production-Grade Infrastructure & CI/CD](https://github.com/ismaaeelahmed11/devops-learning/tree/main/ecs-project)
- [Self-Managed Kubernetes — kubeadm & Cluster Operations](https://github.com/ismaaeelahmed11/kubeadm-kubernetes-lab)
- [Main DevOps Engineering Portfolio](https://github.com/ismaaeelahmed11)

---

## Connect

**Ismaaeel Ahmed** — DevOps & Cloud Engineering

[LinkedIn](https://www.linkedin.com/in/ismaaeelahmed) · [GitHub](https://github.com/ismaaeelahmed11) · [Email](mailto:ismaaeelahmed11@gmail.com)
