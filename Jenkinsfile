pipeline {
    agent any

    environment {
        DOCKER_CREDS = 'Doc_hub'
    }

    stages {

        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t vaith/dev:latest .'
            }
        }

        stage('Push Dev Image') {
            when { branch "dev" }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push vaith/dev:latest
                    '''
                }
            }
        }

        stage('Push Prod Image') {
            when { branch "main" }
            steps {
                sh 'docker tag vaith/dev:latest vaith/prod:latest'

                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push vaith/prod:latest
                    '''
                }
            }
        }
    }
}