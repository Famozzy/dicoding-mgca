## Guide

### 1. Terraform initialization

First of all, you need to initialize the terraform configuration.

```bash
terraform init
```

### 2. Change terraform variables

edit the `terraform.tfvars` file and change the `project_id` variable to your project id.

```hcl
project_id = "your_project_id"
```

### 3. Apply the terraform configuration

```bash
terraform apply
```

it will take 10-15 minutes to create the resources.

### 4. Clone the notes API repository

```bash
git clone https://github.com/dicodingacademy/a332-google-cloud-architect-labs app
```

### 5. Build and push the docker image

```bash
export PROJECT_ID=your_project_id
```

```bash
docker build -t asia-southeast2-docker.pkg.dev/$PROJECT_ID/repo/notes-api:latest app
```

```bash
docker push asia-southeast2-docker.pkg.dev/$PROJECT_ID/repo/notes-api:latest
```

### 6. Deploy the app to GKE using kubectl

```bash
sed -i 's/YOUR_PROJECT_ID/$PROJECT_ID/g' k8s/deployment.yaml
```

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
