# Terragrunt Infrastructure as Code

Đây là một cấu trúc Terragrunt được thiết kế để quản lý infrastructure trên AWS một cách có tổ chức và scalable.

## 📁 Cấu trúc thư mục

```
labs01/
├── _env/                          # Terraform modules (reusable components)
│   ├── VPC/                       # VPC module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── SG/                        # Security Group module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── EC2/                       # EC2 module
│       ├── main.tf
│       └── variables.tf
├── live/                          # Environment-specific configurations
│   ├── develop/                   # Development environment
│   │   └── VPC/
│   │       └── terragrunt.hcl
│   ├── staging/                   # Staging environment
│   │   └── terragrunt.hcl
│   └── production/                # Production environment
│       └── terragrunt.hcl
├── terragrunt.hcl                 # Root configuration (backend, common settings)
└── README.md
```

## 🏗️ Kiến trúc

### 1. **Modules (_env/)**
- Chứa các Terraform modules có thể tái sử dụng
- Mỗi module có `main.tf`, `variables.tf`, và `outputs.tf`
- Được thiết kế để độc lập và có thể sử dụng cho nhiều environment

### 2. **Environments (live/)**
- `develop/`: Môi trường phát triển
- `staging/`: Môi trường staging
- `production/`: Môi trường production
- Mỗi environment có thể có các modules khác nhau tùy theo nhu cầu

### 3. **Backend Configuration**
- Sử dụng AWS S3 để lưu trữ state files
- DynamoDB table để quản lý state locking
- Tự động generate `backend.tf` cho mỗi module

## 🚀 Cách sử dụng

### Prerequisites

1. **Cài đặt Terraform**
   ```bash
   # Windows (PowerShell)
   choco install terraform
   
   # macOS
   brew install terraform
   
   # Linux
   sudo apt-get update && sudo apt-get install terraform
   ```

2. **Cài đặt Terragrunt**
   ```bash
   # Windows (PowerShell)
   choco install terragrunt
   
   # macOS
   brew install terragrunt
   
   # Linux
   wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.50.17/terragrunt_linux_amd64
   chmod +x terragrunt_linux_amd64
   sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
   ```

3. **Cấu hình AWS CLI**
   ```bash
   aws configure
   ```

4. **Tạo S3 Bucket và DynamoDB Table**
   ```bash
   # Tạo S3 bucket
   aws s3 mb s3://terraform-backend-bucket-khiemnd --region ap-southeast-1
   
   # Tạo DynamoDB table
   aws dynamodb create-table \
     --table-name st-point-terraform-lock-table \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
     --region ap-southeast-1
   ```

### Commands cơ bản

#### 1. **Plan (xem trước thay đổi)**
```bash
# Plan cho VPC module trong develop environment
tfg plan --terragrunt-working-dir .\live\develop\VPC

# Plan cho tất cả modules trong develop environment
tfg run-all plan --terragrunt-working-dir .\live\develop
```

#### 2. **Apply (triển khai infrastructure)**
```bash
# Apply VPC module
tfg apply --terragrunt-working-dir .\live\develop\VPC

# Apply với auto-approve
tfg apply --terragrunt-working-dir .\live\develop\VPC --auto-approve

# Apply tất cả modules
tfg run-all apply --terragrunt-working-dir .\live\develop
```

#### 3. **Destroy (xóa infrastructure)**
```bash
# Destroy VPC module
tfg destroy --terragrunt-working-dir .\live\develop\VPC

# Destroy tất cả modules
tfg run-all destroy --terragrunt-working-dir .\live\develop
```

#### 4. **Output (xem outputs)**
```bash
# Xem outputs của VPC module
tfg output --terragrunt-working-dir .\live\develop\VPC
```

## 📋 Workflow thực tế

### 1. **Tạo module mới**
```bash
# Tạo thư mục module
mkdir _env\NewModule

# Tạo các file cần thiết
touch _env\NewModule\main.tf
touch _env\NewModule\variables.tf
touch _env\NewModule\outputs.tf
```

### 2. **Sử dụng module trong environment**
```bash
# Tạo thư mục cho module trong environment
mkdir live\develop\NewModule

# Tạo terragrunt.hcl
cat > live\develop\NewModule\terragrunt.hcl << EOF
include "backend" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../_env/NewModule"
}

inputs = {
  # Cấu hình inputs cho module
}
EOF
```

### 3. **Thêm dependency giữa các modules**
```hcl
# Trong terragrunt.hcl của module phụ thuộc
dependency "vpc" {
  config_path = "../VPC"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.public_subnets[0]
}
```

## 🔧 Cấu hình Backend

### S3 Backend Configuration
```hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-backend-bucket-khiemnd"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "st-point-terraform-lock-table"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
```

### State File Structure
```
terraform-backend-bucket-khiemnd/
├── live/develop/VPC/terraform.tfstate
├── live/develop/SG/terraform.tfstate
├── live/develop/EC2/terraform.tfstate
├── live/staging/VPC/terraform.tfstate
└── live/production/VPC/terraform.tfstate
```

## 🛡️ Best Practices

### 1. **Naming Convention**
- Modules: PascalCase (VD: `VPC`, `SecurityGroup`)
- Environments: lowercase (VD: `develop`, `staging`, `production`)
- Resources: kebab-case với prefix (VD: `khiemnd-develop-vpc`)

### 2. **State Management**
- Luôn sử dụng remote state (S3)
- Không commit state files vào Git
- Sử dụng DynamoDB để lock state

### 3. **Security**
- Sử dụng IAM roles thay vì access keys khi có thể
- Enable encryption cho S3 bucket
- Sử dụng least privilege principle

### 4. **Dependencies**
- Định nghĩa dependencies rõ ràng giữa các modules
- Apply modules theo thứ tự dependency (VPC → SG → EC2)

## 🐛 Troubleshooting

### 1. **State không được lưu trên S3**
```bash
# Kiểm tra backend configuration
tfg init --terragrunt-working-dir .\live\develop\VPC

# Migrate state từ local sang S3
tfg init --terragrunt-working-dir .\live\develop\VPC -migrate-state
```

### 2. **Dependency errors**
```bash
# Apply dependencies trước
tfg apply --terragrunt-working-dir .\live\develop\VPC
tfg apply --terragrunt-working-dir .\live\develop\SG

# Sau đó apply module phụ thuộc
tfg apply --terragrunt-working-dir .\live\develop\EC2
```

### 3. **Clear cache**
```bash
# Xóa Terragrunt cache
Remove-Item -Recurse -Force .\live\develop\VPC\.terragrunt-cache
```

## 📚 Tài liệu tham khảo

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform AWS Modules](https://registry.terraform.io/namespaces/terraform-aws-modules)

## 👥 Contributing

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Tạo Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

**Lưu ý**: Thay đổi tên S3 bucket và DynamoDB table trong `terragrunt.hcl` để phù hợp với project của bạn.
