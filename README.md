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
Create standard cloud platform.

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
- terraform
  ```
  brew install terraform
  ```

### Installation
- Clone the repo
  ```
  git clone git@github.com:tanavel/izanagi.git
  ```

## Usage
- Execute terraform
  ```
  cd {target_component_dir}
  terraform apply
  ```

## Contact
tanavel - [@tanavel1118](https://twitter.com/tanavel1118) - tanavel1118@gmail.com
