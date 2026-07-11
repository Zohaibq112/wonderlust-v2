@Library('Shared') _
pipeline {
    agent any
    
    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: '', description: 'Frontend Docker tag of the image built by the CI job')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: '', description: 'Backend Docker tag of the image built by the CI job')
    }

    stages {

        stage("Validate Parameters") {
            steps {
                script {
                    if (params.FRONTEND_DOCKER_TAG == '' || params.BACKEND_DOCKER_TAG == '') {
                        error("FRONTEND_DOCKER_TAG and BACKEND_DOCKER_TAG must be provided.")
                    }
                }
            }
        }

        stage("Workspace cleanup") {
            steps {
                script {
                    cleanWs()
                }
            }
        }
        
        stage('Git: Code Checkout') {
            steps {
                script {
                    code_checkout("https://github.com/Zohaibq112/wonderlust-v2.git","main")
                }
            }
        }

        stage('Terraform: Provision EC2') {
            steps {
                script {
                    dir('terraform') {
                        terraform_action("apply")
                    }
                }
            }
        }

        stage('Get EC2 Public IP') {
            steps {
                script {
                    dir('terraform') {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                          credentialsId: 'AWS-cred',
                                          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                            def ec2Ip = sh(
                                script: "terraform output -raw instance_public_ip",
                                returnStdout: true
                            ).trim()
                            echo "EC2 Instance IP: ${ec2Ip}"
                            env.EC2_PUBLIC_IP = ec2Ip
                        }
                    }
                }
            }
        }
        
        stage('Verify: Docker Image Tags') {
            steps {
                script {
                    echo "FRONTEND_DOCKER_TAG: ${params.FRONTEND_DOCKER_TAG}"
                    echo "BACKEND_DOCKER_TAG: ${params.BACKEND_DOCKER_TAG}"
                    echo "Deploying to EC2: ${env.EC2_PUBLIC_IP}"
                }
            }
        }

        stage("Update: Kubernetes manifests") {
            steps {
                script {
                    dir('kubernetes') {
                        sh """
                            sed -i 's|wanderlust-backend-beta:.*|wanderlust-backend-beta:${params.BACKEND_DOCKER_TAG}|g' backend.yaml
                        """
                    }
                    dir('kubernetes') {
                        sh """
                            sed -i 's|wanderlust-frontend-beta:.*|wanderlust-frontend-beta:${params.FRONTEND_DOCKER_TAG}|g' frontend.yaml
                        """
                    }
                }
            }
        }
        
       stage("Git: Code update and push to GitHub") {
            steps {
                script {
                    withCredentials([gitUsernamePassword(credentialsId: 'Github-cred', gitToolName: 'Default')]) {
                        sh '''
                            echo "Checking repository status:"
                            git status

                            echo "Adding changes to git:"
                            git add .

                            echo "Committing changes:"
                            git diff --cached --quiet && echo "No changes to commit" || git commit -m "Updated Docker image tags to latest version"

                            echo "Pushing changes to GitHub:"
                            git push https://github.com/Zohaibq112/wonderlust-v2.git HEAD:main || echo "Nothing new to push"
                        '''
                    }
                }
            }
        }

        stage('Deploy: Copy files to EC2') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(
                            credentialsId: 'EC2-SSH-PRIVATE-KEY',
                            keyFileVariable: 'SSH_KEY'
                        )
                    ]) {
                        sh """
                            echo "Copying docker-compose file to EC2..."
                            scp -i \$SSH_KEY \
                                -o StrictHostKeyChecking=no \
                                docker-compose.yml \
                                ubuntu@${env.EC2_PUBLIC_IP}:/home/ubuntu/

                            echo "Deploying application on EC2..."
                            ssh -i \$SSH_KEY \
                                -o StrictHostKeyChecking=no \
                                ubuntu@${env.EC2_PUBLIC_IP} '
                                    echo "Pulling latest Docker images..."
                                    docker-compose down || true
                                    docker-compose pull
                                    docker-compose up -d
                                    echo "Deployment complete!"
                                    docker ps
                                '
                        """
                    }
                }
            }
        }

        stage('Verify: Application is running') {
            steps {
                script {
                    withCredentials([
                        sshUserPrivateKey(
                            credentialsId: 'EC2-SSH-PRIVATE-KEY',
                            keyFileVariable: 'SSH_KEY'
                        )
                    ]) {
                        sh """
                            ssh -i \$SSH_KEY \
                                -o StrictHostKeyChecking=no \
                                ubuntu@${env.EC2_PUBLIC_IP} '
                                    echo "Running containers:"
                                    docker ps
                                    echo "Application URL: http://${env.EC2_PUBLIC_IP}:3000"
                                '
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                emailext attachLog: true,
                from: 'zohaibqazi941@gmail.com',
                subject: "Wanderlust Application Deployed Successfully - '${currentBuild.result}'",
                body: """
                    <html>
                    <body>
                        <div style="background-color: #FFA07A; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Project: ${env.JOB_NAME}</p>
                        </div>
                        <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Build Number: ${env.BUILD_NUMBER}</p>
                        </div>
                        <div style="background-color: #87CEEB; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Build URL: ${env.BUILD_URL}</p>
                        </div>
                        <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Application URL: http://${env.EC2_PUBLIC_IP}:3000</p>
                        </div>
                    </body>
                    </html>
                """,
                to: 'qzohaib234@gmail.com',
                mimeType: 'text/html'
            }
        }
        failure {
            script {
                emailext attachLog: true,
                from: 'zohaibqazi941@gmail.com',
                subject: "Wanderlust CD Pipeline Failed - '${currentBuild.result}'",
                body: """
                    <html>
                    <body>
                        <div style="background-color: #FF6347; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">CD Pipeline Failed</p>
                        </div>
                        <div style="background-color: #FFA07A; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Project: ${env.JOB_NAME}</p>
                        </div>
                        <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Build Number: ${env.BUILD_NUMBER}</p>
                        </div>
                        <div style="background-color: #87CEEB; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Build URL: ${env.BUILD_URL}</p>
                        </div>
                    </body>
                    </html>
                """,
                to: 'qzohaib234@gmail.com',
                mimeType: 'text/html'
            }
        }
    }
}