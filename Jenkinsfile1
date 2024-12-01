pipeline {
    agent any

    environment {
        TF_WORKSPACE = 'default' // Specify the Terraform workspace
        TF_VAR_CREDENTIALS = credentials('e83ccc16-3ac5-40b6-9758-aba79d02090e') // Use Jenkins credentials for AWS or other provider
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Clone the repository and use the branch if required
                git branch: 'main', 
                    url: 'https://github.com/skotaiah/Devop.git', 
                    credentialsId: 'f0bd0d81-f141-40c9-b7fd-50a379232a04'
            }
        }

        stage('Run Terraform') {
            steps {
                script {
                    // Use Docker image with Terraform pre-installed
                    docker.image('hashicorp/terraform:1.6.0').inside {
                        // Change directory to the specified subfolder
                        dir('ci cd aws') { // Ensure the folder exists in the repo
                            sh '''
                                terraform init          # Initialize Terraform
                                terraform validate     # Validate configuration
                                terraform plan -out=tfplan # Generate execution plan
                            '''
                            
                            // Optional approval before applying the plan
                            input message: 'Apply the Terraform plan?', ok: 'Yes'

                            sh 'terraform apply -auto-approve tfplan' // Apply the execution plan
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution complete.'
        }
        success {
            echo 'Terraform execution successful.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}