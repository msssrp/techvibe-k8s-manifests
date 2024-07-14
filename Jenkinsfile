pipeline {
    agent none
    stages {
        stage('Check out') {
            agent any
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/msssrp/tech-vibe']])
                stash includes: '**', name: 'source'
            }
        }
        stage('Check Eslint'){
            agent { label "node-agent"}
            steps{
                unstash 'source'
                sh '''
                    npm i && npm run lint
                '''
            }
        }
        stage('Build image & Push to dockerhub') {
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: kaniko
                            image: gcr.io/kaniko-project/executor:debug
                            command:
                            - sleep
                            args:
                            - 999999
                            tty: true
                            volumeMounts:
                            - name: jenkins-docker-cfg
                              mountPath: /kaniko/.docker
                          volumes:
                          - name: jenkins-docker-cfg
                            secret:
                              secretName: docker-credentials
                              items:
                                - key: .dockerconfigjson
                                  path: config.json
                    """
                }
            }
            environment {
                TechVibe_env = credentials('TECHVIBE-ENV')
            }
            steps {
                unstash 'source'
                script {
                    container(name: 'kaniko', shell: '/busybox/sh') {
                        sh '''
                        #!/busybox/sh
                        /kaniko/executor --compressed-caching=false --skip-unused-stages --cache-run-layers=false --single-snapshot --build-arg=ENV_FILE="$(cat $TechVibe_env)" --dockerfile `pwd`/Dockerfile --context `pwd` --destination siripoom/techvibe:beta${currentBuild.number}
                        '''
                    }
                }
            }
        }
        stage('Update TechVibe deployment manifest'){
            agent any
            environment {
                GIT_REPO_NAME = "techvibe-k8s-manifests"
                GIT_USER_NAME = "msssrp"
            }
            steps{
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[credentialsId: 'git_credentials', url: "https://github.com/${GIT_USER_NAME}/${GIT_REPO_NAME}.git"]]])
                script { 
                    withCredentials([usernamePassword(credentialsId: 'git_credentials', passwordVariable: 'GITHUB_TOKEN', usernameVariable: 'GITHUB_USERNAME')]) {
                    sh '''
                        #!/bin/bash
                        git config user.email "siripoomcontact@gmail.com"
                        git config user.name "msssrp"
                        BUILD_NUMBER=${currentBuild.number}
                        sed -i "s/techvibe:beta[^ ]*/techvibe:beta${BUILD_NUMBER}/g" techvibe-namespace/techvibe-deployment.yaml
                        git add techvibe-namespace/techvibe-deployment.yaml
                        git commit -m "update: update techvibe image version to ${BUILD_NUMBER}"
                        git push https://${GIT_USER_NAME}:${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                    '''
                    }
                }
            }
        }
    }
}
