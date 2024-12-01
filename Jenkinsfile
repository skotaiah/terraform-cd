pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/skotaiah/terraform-cd.git'
            }
        }

        stage('Run Terraform') {
            steps {
                script {
                    docker.image('hashicorp/terraform:1.6.0').inside {
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform plan -out=tfplan'

                        // Conditionally apply based on autoApprove parameter
                        if (params.autoApprove) {
                            sh 'terraform apply -auto-approve tfplan'
                        } else {
                            input message: 'Approve Terraform Apply?', ok: 'Yes'
                            sh 'terraform apply tfplan'
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
