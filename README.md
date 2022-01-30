# izanagi

## TOC
1. [About](#about)
    - [Built With](#built-with)
    - [Directory structure](#directory-structure)
2. [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
3. [Usage](#usage)
4. [License](#license)
5. [Contact](#contact)

## About
Create standard web application platform.

### Built With
- [Terraform](https://www.terraform.io/)

### Directory Structure
```
├── LICENSE
├── README.md
└── terraform
    ├── components
    │   └── network
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    └── modules
        └── module1
            ├── README.md
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
```

## Getting Started
### Prerequisites
- Terraform >= 1.1.3
  ```
  brew install terraform
  ```

- AWS cli >= 2.4.9
  ```
  brew install awscli
  ```

### Installation
- Clone the repo
  ```
  git clone git@github.com:tanavel/izanagi.git
  ```

## Usage
### Create S3 backend
- Create S3 backend
  ```
  aws --profile {{ AWS_PROFILE }} --region us-east-1 s3api create-bucket
    --bucket {{ S3_BUCKET_NAME }} \
    --create-bucket-configuration '{
      "LocationConstraint": "{{ AWS_REGION }}"
    }'
  ```

- Put S3 bucket protect rules
  ```
  aws --profile {{ AWS_PROFILE }} --region us-east-1 s3api put-public-access-block \
    --bucket {{ S3_BUCKET_NAME }} \
    --public-access-block-configuration '{
      "BlockPublicAcls": true,
      "IgnorePublicAcls": true,
      "BlockPublicPolicy": true,
      "RestrictPublicBuckets": true
  }'
  ```

### Execute terraform
- Move target component directory
  ```
  cd {{ TARGET_COMPONENT_DIR }}
  ```

- Export default credential and region
  ```
  export AWS_PROFILE={{ AWS_PROFILE }}
  export AWS_REGION={{ AWS_REGION }}
  ```

- Init component
  ```
  terraform init -backend-config "bucket={{ S3_BUCKET_NAME }}"
  ```

- Create (or Select) env
  ```
  terraform workspace new {{ ENV }}
  # if already created
  terraform workspace select {{ ENV }}
  ```

- Execute terraform apply
  ```
  terraform apply
  ```

## Contact
tanavel - [@tanavel1118](https://twitter.com/T4n4V3l) - tanavel1118@gmail.com
