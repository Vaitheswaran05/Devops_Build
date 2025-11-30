pipeline {
  agent any

  environment {
    DOCKER_CREDS = 'Doc_hub'          // your Jenkins credential ID for Docker Hub
    EC2_SSH_CRED = 'ec2-ssh'          // Jenkins SSH credential ID (private key)
    EC2_USER = 'ubuntu'
    EC2_HOST = '13.203.76.212'        // your EC2 public IP (replace if different)
    DEV_IMAGE = 'vaith/dev:latest'
    PROD_IMAGE = 'vaith/prod:latest'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build Image') {
      steps {
        sh 'docker build -t vaith/devops-build-react-app:latest .'
      }
    }

    stage('Push Dev Image') {
      when { expression { env.BRANCH_NAME == 'dev' } }
      steps {
        withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDS}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh '''
            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
            docker tag vaith/devops-build-react-app:latest ${DEV_IMAGE}
            docker push ${DEV_IMAGE}
          '''
        }
      }
    }

    stage('Push Prod & Deploy') {
      when { expression { env.BRANCH_NAME == 'main' } }
      steps {
        withCredentials([
            usernamePassword(credentialsId: "${DOCKER_CREDS}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS'),
            sshUserPrivateKey(credentialsId: "${EC2_SSH_CRED}", keyFileVariable: 'EC2_KEY')
          ]) {
          sh '''
            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
            docker tag vaith/devops-build-react-app:latest ${PROD_IMAGE}
            docker push ${PROD_IMAGE}

            # Deploy to EC2
            ssh -o StrictHostKeyChecking=no -i "$EC2_KEY" ${EC2_USER}@${EC2_HOST} "
              sudo docker pull ${PROD_IMAGE} || true
              sudo docker rm -f react-prod || true
              sudo docker run -d -p 80:80 --name react-prod ${PROD_IMAGE}
              sudo docker ps -a
            "
          '''
        }
      }
    }
  }

  post {
    always {
      sh 'docker image prune -f || true'
    }
  }
}