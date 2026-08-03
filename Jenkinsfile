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

        stage("Update: Kubernetes manifests") {
            steps {
                script {
                    dir('kubernetes') {
                        sh """
                            sed -i 's|wanderlust-backend-beta:.*|wanderlust-backend-beta:${params.BACKEND_DOCKER_TAG}|g' backend-rollout.yaml
                        """
                    }
                    dir('kubernetes') {
                        sh """
                            sed -i 's|wanderlust-frontend-beta:.*|wanderlust-frontend-beta:${params.FRONTEND_DOCKER_TAG}|g' frontend-rollout.yaml
                        """
                    }
                }
            }
        }
        
        stage("Git: Push updated manifests") {
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

        stage("ArgoCD: Sync triggered via Git") {
            steps {
                script {
                    echo "✅ Manifests pushed to GitHub"
                    echo "✅ ArgoCD will detect change and trigger canary deployment"
                    echo "✅ Argo Rollouts will gradually shift traffic"
                    echo "Frontend: 10% → 30% → 60% → 100%"
                    echo "Backend:  10% → 30% → 60% → 100%"
                }
            }
        }
    }

    post {
        success {
            script {
                emailext attachLog: true,
                from: 'zohaibqazi941@gmail.com',
                subject: "Wanderlust CD Completed - Build #${env.BUILD_NUMBER}",
                body: """
                    <html>
                    <body>
                        <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">✅ CD Pipeline Successful!</p>
                        </div>
                        <div style="background-color: #FFA07A; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Project: ${env.JOB_NAME}</p>
                        </div>
                        <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">Build: ${env.BUILD_NUMBER}</p>
                        </div>
                        <div style="background-color: #87CEEB; padding: 10px; margin-bottom: 10px;">
                            <p style="color: black; font-weight: bold;">ArgoCD is deploying via canary rollout</p>
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
                            <p style="color: black; font-weight: bold;">Build: ${env.BUILD_NUMBER}</p>
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