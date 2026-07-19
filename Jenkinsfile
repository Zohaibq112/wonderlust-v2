@Library('Shared') _
pipeline {
    agent any
    
    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: '', description: 'Frontend Docker tag')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: '', description: 'Backend Docker tag')
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

        stage('Set EC2 Public IP') {
            steps {
                script {
                    env.EC2_PUBLIC_IP = "54.89.157.241"
                    echo "Deploying to EC2: ${env.EC2_PUBLIC_IP}"
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
                            git config user.email "zohaibqazi941@gmail.com"
                            git config user.name "Zohaibq112"
                            git status
                            git add .
                            git diff --cached --quiet && echo "No changes to commit" || git commit -m "Updated Docker image tags to latest version"
                            git push https://github.com/Zohaibq112/wonderlust-v2.git HEAD:main || echo "Nothing to push"
                        '''
                    }
                }
            }
        }

        stage('Deploy: Copy files to EC2') {
            steps {
                script {
                    sh """
                        echo "Copying files to EC2..."
                        
                        scp -i /var/jenkins_home/.ssh/terra-key \
                            -o StrictHostKeyChecking=no \
                            -o IdentitiesOnly=yes \
                            docker-compose.yml \
                            ubuntu@${env.EC2_PUBLIC_IP}:/home/ubuntu/

                        scp -i /var/jenkins_home/.ssh/terra-key \
                            -o StrictHostKeyChecking=no \
                            -o IdentitiesOnly=yes \
                            backend/.env.docker \
                            ubuntu@${env.EC2_PUBLIC_IP}:/home/ubuntu/backend.env.docker

                        scp -i /var/jenkins_home/.ssh/terra-key \
                            -o StrictHostKeyChecking=no \
                            -o IdentitiesOnly=yes \
                            frontend/.env.docker \
                            ubuntu@${env.EC2_PUBLIC_IP}:/home/ubuntu/frontend.env.docker

                        echo "Deploying application on EC2..."
                        ssh -i /var/jenkins_home/.ssh/terra-key \
                            -o StrictHostKeyChecking=no \
                            -o IdentitiesOnly=yes \
                            ubuntu@${env.EC2_PUBLIC_IP} '
                                cd /home/ubuntu
                                sudo docker-compose down || true
                                sudo docker-compose pull
                                sudo docker-compose up -d
                                echo "Deployment complete!"
                                docker ps
                            '
                    """
                }
            }
        }
        stage('Verify: Application is running') {
            steps {
                script {
                    sh """
                        ssh -i /var/jenkins_home/.ssh/terra-key \
                            -o StrictHostKeyChecking=no \
                            ubuntu@${env.EC2_PUBLIC_IP} '
                                echo "Running containers:"
                                docker ps
                                echo "Application URL: http://${env.EC2_PUBLIC_IP}:5173"
                            '
                    """
                }
            }
        }
    }

    post {
        success {
            script {
                emailext attachLog: true,
                from: 'zohaibqazi941@gmail.com',
                subject: "Wanderlust Deployed Successfully - Build #${env.BUILD_NUMBER}",
                body: """
                    <html>
                    <body>
                        <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">✅ Deployment Successful!</p>
                        </div>
                        <div style="background-color: #FFA07A; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Project: ${env.JOB_NAME}</p>
                        </div>
                        <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Build Number: ${env.BUILD_NUMBER}</p>
                        </div>
                        <div style="background-color: #87CEEB; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Application URL: http://54.89.157.241:5173</p>
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
                subject: "Wanderlust CD Failed - Build #${env.BUILD_NUMBER}",
                body: """
                    <html>
                    <body>
                        <div style="background-color: #FF6347; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">❌ CD Pipeline Failed</p>
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